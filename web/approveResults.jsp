<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.ResultDAO"%>
<%@page import="model.Result"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    The administrator's approval queue. Rows come from ResultDAO already
    sorted with the Pending submissions first; this page contains no SQL.
--%>
<%
    List<Result> submissions = null;
    boolean loadFailed = false;

    try {
        submissions = new ResultDAO().findAllForApproval();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading result submissions for an administrator", e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Approve Results</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-primary px-4">
    <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

    <div>
        <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
        <a class="text-white me-3 text-decoration-none fw-bold" href="approveResults.jsp">Approve Results</a>
        <a class="text-white me-3 text-decoration-none" href="manageParticipants.jsp">Participants</a>
        <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
    </div>
</nav>

<div class="container my-5">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="text-primary fw-bold mb-0">Result Approval</h2>
        <a href="export?type=results" class="btn btn-success btn-sm">&#11015; Export CSV</a>
    </div>

    <%
        String status = request.getParameter("status");
        if ("approved".equals(status) || "rejected".equals(status)) {
    %>
        <div class="alert alert-success">
            The submission has been marked as <%= Web.esc(status) %>.
        </div>
    <%
        }

        String error = request.getParameter("error");
        if (error != null) {
            String message;
            if ("notfound".equals(error)) {
                message = "That submission no longer exists.";
            } else if ("invalid".equals(error)) {
                message = "That request was not valid.";
            } else {
                message = "Sorry, the submission could not be updated. Please try again.";
            }
    %>
        <div class="alert alert-danger"><%= Web.esc(message) %></div>
    <%
        }
    %>

    <div class="filter-bar">
        <input type="text" class="filter-input" data-filter="tbody .result-row"
               placeholder="Search by participant, event or status...">
        <span class="filter-count"></span>
    </div>

    <table class="table table-bordered table-hover bg-white align-middle">

        <thead class="table-primary">
            <tr>
                <th>ID</th>
                <th>Participant</th>
                <th>Event</th>
                <th>Distance</th>
                <th>Duration</th>
                <th>Proof</th>
                <th>Status</th>
                <th width="190">Action</th>
            </tr>
        </thead>

        <tbody>
        <%
            if (loadFailed) {
        %>
            <tr>
                <td colspan="8" class="text-danger text-center py-4">
                    Sorry, the submissions could not be loaded right now.
                </td>
            </tr>
        <%
            } else if (submissions.isEmpty()) {
        %>
            <tr>
                <td colspan="8" class="text-center text-muted py-4">
                    No participant submissions found.
                </td>
            </tr>
        <%
            } else {
                for (Result submission : submissions) {

                    String badgeClass = "bg-secondary";
                    if (submission.isApproved()) {
                        badgeClass = "bg-success";
                    } else if (submission.isPending()) {
                        badgeClass = "bg-warning text-dark";
                    } else if (submission.isRejected()) {
                        badgeClass = "bg-danger";
                    }
        %>
            <tr class="result-row">
                <td><%= submission.getResultId() %></td>
                <td><%= Web.esc(submission.getParticipantName()) %></td>
                <td><%= Web.esc(submission.getEventName()) %></td>
                <td><%= submission.getDistanceAchieved() %> KM</td>
                <td><%= Web.esc(submission.getDuration()) %></td>
                <td>
                    <% if (submission.hasProofImage()) { %>
                        <a href="proof?file=<%= Web.esc(submission.getProofImage()) %>" target="_blank">
                            <img src="proof?file=<%= Web.esc(submission.getProofImage()) %>"
                                 alt="Proof of run" width="70" class="rounded">
                        </a>
                    <% } else { %>
                        <span class="text-muted">None</span>
                    <% } %>
                </td>
                <td>
                    <span class="badge <%= badgeClass %>">
                        <%= Web.esc(submission.getApprovalStatus()) %>
                    </span>
                </td>
                <td>
                    <div class="d-flex gap-2">
                        <%-- Approving changes stored data, so each button posts
                             a form to the Controller instead of following a
                             plain link. --%>
                        <form action="ApproveResultServlet" method="post">
                            <input type="hidden" name="id" value="<%= submission.getResultId() %>">
                            <input type="hidden" name="status" value="Approved">
                            <button type="submit" class="btn btn-success btn-sm">Approve</button>
                        </form>

                        <form action="ApproveResultServlet" method="post">
                            <input type="hidden" name="id" value="<%= submission.getResultId() %>">
                            <input type="hidden" name="status" value="Rejected">
                            <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                        </form>
                    </div>
                </td>
            </tr>
        <%
                }
            }
        %>
        </tbody>

    </table>

</div>

</body>
</html>
