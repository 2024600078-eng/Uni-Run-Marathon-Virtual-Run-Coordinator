<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="dao.ResultDAO"%>
<%@page import="model.Result"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    The finisher certificate for one approved result.

    The result and the finishing position both come from ResultDAO. This page
    contains no SQL; it checks the answer it was given and lays out the
    document.
--%>
<%
    boolean viewerIsAdmin = "admin".equals(session.getAttribute("role"));

    int resultId;
    try {
        resultId = Integer.parseInt(request.getParameter("resultId"));
    } catch (NumberFormatException | NullPointerException e) {
        response.sendRedirect("viewResultStatus.jsp?error=invalid");
        return;
    }

    Result result;
    int position;

    try {
        ResultDAO resultDAO = new ResultDAO();
        result = resultDAO.findForCertificate(resultId);

        if (result == null) {
            response.sendRedirect("viewResultStatus.jsp?error=notfound");
            return;
        }

        // Ownership check: without this, changing the number in the address
        // bar would show somebody else's certificate.
        if (!viewerIsAdmin && result.getOwnerUserId() != currentUserId) {
            response.sendRedirect("viewResultStatus.jsp?error=notfound");
            return;
        }

        if (!result.isApproved()) {
            response.sendRedirect("viewResultStatus.jsp?error=notapproved");
            return;
        }

        position = resultDAO.findPositionInEvent(result.getEventId(), result.getDurationSeconds());

    } catch (Exception e) {
        application.log("Loading certificate for result " + resultId, e);
        response.sendRedirect("viewResultStatus.jsp?error=db");
        return;
    }

    String issuedOn = result.getSubmissionDate() == null
            ? ""
            : new SimpleDateFormat("d MMMM yyyy").format(result.getSubmissionDate());

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

            <p class="certificate-name"><%= Web.esc(result.getParticipantName()) %></p>

            <p class="certificate-event">
                for successfully completing<br>
                <strong><%= Web.esc(result.getEventName()) %></strong>
            </p>

            <div class="certificate-facts">
                <div class="certificate-fact">
                    <strong><%= result.getDistanceAchieved() %> km</strong>
                    <span>Distance</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= Web.esc(result.getDuration()) %></strong>
                    <span>Finish Time</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= positionLabel %></strong>
                    <span>Position</span>
                </div>

                <div class="certificate-fact">
                    <strong><%= Web.esc(result.getEventDate()) %></strong>
                    <span>Event Date</span>
                </div>
            </div>

            <div class="certificate-footer">
                <div>
                    <div class="certificate-signature">Race Director</div>
                </div>

                <div>
                    Issued <%= Web.esc(issuedOn) %><br>
                    Certificate reference UR-<%= result.getResultId() %>
                </div>
            </div>

        </div>

    </div>

</body>
</html>
