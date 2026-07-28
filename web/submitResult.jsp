<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // When the participant arrives from the "Resubmit" button on their result
    // list, the event they are correcting is preselected.
    String preselect = request.getParameter("registrationId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Submit Race Result</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="events.jsp">Events</a>
            <a class="text-white me-3 text-decoration-none" href="leaderboard.jsp">Leaderboard</a>
            <a class="text-white me-3 text-decoration-none" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <a href="dashboard.jsp" class="btn btn-outline-secondary mb-3">&larr; Back</a>

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">Submit Your Race Result</h2>
            <p class="text-muted mb-0">
                Choose an event you have registered for and upload the proof of your run.
            </p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= Web.esc((String) request.getAttribute("error")) %>
            </div>
        <% } %>

        <div class="bg-white p-4 shadow-sm rounded">
            <%
                // An event can be chosen when no result has been sent for it
                // yet, or when the result that was sent has been rejected and
                // may now be corrected.
                String sql = "SELECT reg.registration_id, e.event_name, res.approval_status "
                           + "FROM registrations reg "
                           + "JOIN events e ON reg.event_id = e.event_id "
                           + "LEFT JOIN results res ON res.registration_id = reg.registration_id "
                           + "WHERE reg.user_id = ? "
                           + "AND (res.result_id IS NULL OR res.approval_status = 'Rejected') "
                           + "ORDER BY e.event_date";

                StringBuilder options = new StringBuilder();
                boolean hasEvents = false;
                boolean anyResubmission = false;
                boolean loadFailed = false;

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {

                    ps.setInt(1, currentUserId);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            hasEvents = true;

                            int registrationId = rs.getInt("registration_id");
                            boolean rejected =
                                    "Rejected".equalsIgnoreCase(rs.getString("approval_status"));

                            if (rejected) {
                                anyResubmission = true;
                            }

                            options.append("<option value=\"")
                                   .append(registrationId)
                                   .append("\"");

                            if (String.valueOf(registrationId).equals(preselect)) {
                                options.append(" selected");
                            }

                            options.append(">")
                                   .append(Web.esc(rs.getString("event_name")))
                                   .append(rejected ? " (correcting a rejected result)" : "")
                                   .append("</option>");
                        }
                    }

                } catch (Exception e) {
                    loadFailed = true;
                    application.log("Loading submittable events for user " + currentUserId, e);
                }

                if (loadFailed) {
            %>
                <p class="text-danger">Sorry, your events could not be loaded right now.</p>
            <%
                } else if (!hasEvents) {
            %>
                <p class="text-muted">
                    You have no events waiting for a result. Either you have not registered
                    for an event yet, or every result you sent is already under review or approved.
                </p>
                <a href="events.jsp" class="btn btn-primary">Browse Events</a>
            <%
                } else {

                    if (anyResubmission) {
            %>
                <div class="alert alert-warning">
                    One or more of your results was rejected. Choosing it below replaces
                    the earlier submission and sends it for review again.
                </div>
            <%
                    }
            %>
            <form action="ResultSubmissionServlet" method="post" enctype="multipart/form-data">

                <div class="mb-3">
                    <label class="form-label fw-bold" for="registrationId">Select Event</label>
                    <select name="registrationId" id="registrationId" class="form-select" required>
                        <%= options.toString() %>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold" for="distanceAchieved">Distance Achieved (km)</label>
                    <input type="number" step="0.01" min="0.01" name="distanceAchieved"
                           id="distanceAchieved" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold" for="duration">Duration</label>
                    <input type="text" name="duration" id="duration" class="form-control"
                           placeholder="hh:mm:ss" pattern="\d{1,2}:[0-5]\d:[0-5]\d"
                           title="Enter the duration as hh:mm:ss, for example 01:23:45" required>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold" for="proofImage">Proof Image</label>
                    <input type="file" name="proofImage" id="proofImage" class="form-control"
                           accept=".jpg,.jpeg,.png" required>
                    <div class="form-text">JPG or PNG only, up to 5 MB.</div>
                </div>

                <button type="submit" class="btn btn-primary w-100 fw-bold">Submit Result</button>
            </form>
            <%
                }
            %>
        </div>

        <div class="text-center mt-3">
            <a href="viewResultStatus.jsp">View my result status</a>
        </div>

    </div>
</body>
</html>
