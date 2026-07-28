<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // A certificate exists only for an approved result. A participant may see
    // their own; an administrator may see any.
    boolean viewerIsAdmin = "admin".equals(session.getAttribute("role"));

    int resultId;
    try {
        resultId = Integer.parseInt(request.getParameter("resultId"));
    } catch (NumberFormatException | NullPointerException e) {
        response.sendRedirect("viewResultStatus.jsp?error=invalid");
        return;
    }

    String runnerName = null;
    String eventName = null;
    String eventDate = null;
    String duration = null;
    double distanceAchieved = 0;
    java.sql.Timestamp submittedOn = null;
    int position = 0;

    String detailSql =
          "SELECT u.full_name, u.user_id, e.event_id, e.event_name, e.event_date, "
        + "r.distance_achieved, r.duration, r.approval_status, r.submission_date, "
        + "TIME_TO_SEC(r.duration) AS seconds "
        + "FROM results r "
        + "JOIN registrations reg ON r.registration_id = reg.registration_id "
        + "JOIN users u ON reg.user_id = u.user_id "
        + "JOIN events e ON reg.event_id = e.event_id "
        + "WHERE r.result_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(detailSql)) {

        ps.setInt(1, resultId);

        try (ResultSet rs = ps.executeQuery()) {

            if (!rs.next()) {
                response.sendRedirect("viewResultStatus.jsp?error=notfound");
                return;
            }

            // Ownership check: without this, changing the number in the address
            // bar would show somebody else's certificate.
            if (!viewerIsAdmin && rs.getInt("user_id") != currentUserId) {
                response.sendRedirect("viewResultStatus.jsp?error=notfound");
                return;
            }

            if (!"Approved".equalsIgnoreCase(rs.getString("approval_status"))) {
                response.sendRedirect("viewResultStatus.jsp?error=notapproved");
                return;
            }

            runnerName = rs.getString("full_name");
            eventName = rs.getString("event_name");
            eventDate = rs.getString("event_date");
            duration = rs.getString("duration");
            distanceAchieved = rs.getDouble("distance_achieved");
            submittedOn = rs.getTimestamp("submission_date");

            int eventId = rs.getInt("event_id");
            long seconds = rs.getLong("seconds");

            // Finishing position: how many approved runners in this event were
            // faster, plus one.
            String rankSql =
                  "SELECT COUNT(*) + 1 AS position FROM results r2 "
                + "JOIN registrations reg2 ON r2.registration_id = reg2.registration_id "
                + "WHERE reg2.event_id = ? AND r2.approval_status = 'Approved' "
                + "AND TIME_TO_SEC(r2.duration) < ?";

            try (PreparedStatement rankPs = conn.prepareStatement(rankSql)) {
                rankPs.setInt(1, eventId);
                rankPs.setLong(2, seconds);

                try (ResultSet rankRs = rankPs.executeQuery()) {
                    if (rankRs.next()) {
                        position = rankRs.getInt("position");
                    }
                }
            }
        }

    } catch (Exception e) {
        application.log("Loading certificate for result " + resultId, e);
        response.sendRedirect("viewResultStatus.jsp?error=db");
        return;
    }

    String issuedOn = submittedOn == null
            ? ""
            : new SimpleDateFormat("d MMMM yyyy").format(submittedOn);

    String positionLabel;
    if (position == 1) {
        positionLabel = "1st";
    } else if (position == 2) {
        positionLabel = "2nd";
    } else if (position == 3) {
        positionLabel = "3rd";
    } else {
        positionLabel = position + "th";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Certificate of Completion</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>
<body class="bg-light">

    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="leaderboard.jsp">Leaderboard</a>
            <a class="text-white me-3 text-decoration-none"
               href="<%= viewerIsAdmin ? "approveResults.jsp" : "viewResultStatus.jsp" %>">
                Results
            </a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="d-flex justify-content-between align-items-center mb-4 no-print">
            <a href="<%= viewerIsAdmin ? "approveResults.jsp" : "viewResultStatus.jsp" %>"
               class="btn btn-outline-secondary">&larr; Back</a>

            <button type="button" class="btn btn-primary" onclick="window.print();">
                &#128424; Print or Save as PDF
            </button>
        </div>

        <div class="certificate">

            <div class="certificate-seal">&#127942;</div>

            <p class="certificate-brand">Uni-Run</p>
            <h1 class="certificate-title">Certificate of Completion</h1>
            <p class="certificate-subtitle">This is presented to</p>

            <p class="certificate-name"><%= Web.esc(runnerName) %></p>

            <p class="certificate-event">
                for successfully completing<br>
                <strong><%= Web.esc(eventName) %></strong>
            </p>

            <div class="certificate-facts">
                <div class="certificate-fact">
                    <strong><%= distanceAchieved %> km</strong>
                    <span>Distance</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= Web.esc(duration) %></strong>
                    <span>Finish Time</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= positionLabel %></strong>
                    <span>Position</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= Web.esc(eventDate) %></strong>
                    <span>Event Date</span>
                </div>
            </div>

            <div class="certificate-footer">
                <div>
                    <div class="certificate-signature">Race Director</div>
                </div>

                <div>
                    Issued <%= Web.esc(issuedOn) %><br>
                    Certificate reference UR-<%= resultId %>
                </div>
            </div>

        </div>

    </div>

</body>
</html>
