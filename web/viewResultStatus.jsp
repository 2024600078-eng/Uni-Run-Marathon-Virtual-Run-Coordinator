<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.ResultDAO"%>
<%@page import="model.Result"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    Lists the results this participant has submitted and their approval state.
    The rows come from ResultDAO; this page contains no SQL.
--%>
<%
    List<Result> results = null;
    boolean loadFailed = false;

    try {
        results = new ResultDAO().findByUser(currentUserId);
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading results for user " + currentUserId, e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | My Race Results</title>
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
            <h2 class="fw-bold text-dark">My Race Results</h2>
            <p class="text-muted mb-0">Check the status of the results you have submitted.</p>
        </div>

        <%
            String status = request.getParameter("status");
            if ("submitted".equals(status)) {
        %>
            <div class="alert alert-success">
                <strong>Thank you.</strong> Your result has been submitted and is waiting for approval.
            </div>
        <%
            } else if ("resubmitted".equals(status)) {
        %>
            <div class="alert alert-success">
                <strong>Thank you.</strong> Your corrected result has replaced the rejected one
                and is waiting for approval again.
            </div>
        <%
            }

            String error = request.getParameter("error");
            if (error != null) {
                String message;
                if ("notapproved".equals(error)) {
                    message = "A certificate is only available once your result has been approved.";
                } else if ("notfound".equals(error)) {
                    message = "That result could not be found.";
                } else if ("invalid".equals(error)) {
                    message = "That request was not valid.";
                } else {
                    message = "Sorry, something went wrong. Please try again.";
                }
        %>
            <div class="alert alert-warning"><%= Web.esc(message) %></div>
        <%
            }
        %>

        <div class="table-responsive bg-white p-3 shadow-sm rounded">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-primary">
                    <tr>
                        <th>Event</th>
                        <th>Distance (km)</th>
                        <th>Duration</th>
                        <th>Proof</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (loadFailed) {
                %>
                    <tr>
                        <td colspan="6" class="text-danger text-center py-4">
                            Sorry, your results could not be loaded right now.
                        </td>
                    </tr>
                <%
                    } else if (results.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">
                            You have not submitted any results yet.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Result result : results) {

                            // The Model decides what the status means; the page
                            // only chooses the colour to show it in.
                            String badgeClass = "bg-secondary";
                            if (result.isApproved()) {
                                badgeClass = "bg-success";
                            } else if (result.isPending()) {
                                badgeClass = "bg-warning text-dark";
                            } else if (result.isRejected()) {
                                badgeClass = "bg-danger";
                            }
                %>
                    <tr>
                        <td class="fw-bold"><%= Web.esc(result.getEventName()) %></td>
                        <td><%= result.getDistanceAchieved() %></td>
                        <td><%= Web.esc(result.getDuration()) %></td>
                        <td>
                            <%-- Images are served by a servlet that checks the
                                 viewer, because the upload folder sits outside
                                 the application. --%>
                            <% if (result.hasProofImage()) { %>
                                <img src="proof?file=<%= Web.esc(result.getProofImage()) %>"
                                     alt="Proof of run" width="80" class="rounded">
                            <% } else { %>
                                <span class="text-muted">No image</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= Web.esc(result.getApprovalStatus()) %>
                            </span>
                        </td>
                        <td>
                            <% if (result.isRejected()) { %>
                                <a class="btn btn-primary btn-sm"
                                   href="submitResult.jsp?registrationId=<%= result.getRegistrationId() %>">
                                    Resubmit
                                </a>
                            <% } else if (result.isApproved()) { %>
                                <a class="btn btn-success btn-sm"
                                   href="certificate.jsp?resultId=<%= result.getResultId() %>">
                                    &#127942; Certificate
                                </a>
                            <% } else { %>
                                <span class="text-muted">&ndash;</span>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>

        <div class="text-center mt-3">
            <a href="submitResult.jsp" class="btn btn-primary">Submit New Result</a>
        </div>

    </div>
</body>
</html>
