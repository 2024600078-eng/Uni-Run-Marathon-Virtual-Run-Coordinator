<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.UserDAO"%>
<%@page import="model.ParticipantSummary"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    Lists every participant with a summary of their activity.

    The counts are worked out by the query inside UserDAO, so this page
    receives finished numbers and contains no SQL.
--%>
<%
    List<ParticipantSummary> participants = null;
    boolean loadFailed = false;

    try {
        participants = new UserDAO().findAllParticipants();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading the participant list", e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Manage Participants</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
            <a class="text-white me-3 text-decoration-none" href="manageEvents.jsp">Manage Events</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="manageParticipants.jsp">Participants</a>
            <a class="text-white me-3 text-decoration-none" href="approveResults.jsp">Approve Results</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-primary mb-0">Participant Management</h2>
            <div class="d-flex gap-2">
                <a href="export?type=participants" class="btn btn-success btn-sm">
                    &#11015; Export CSV
                </a>
                <a href="adminDashboard.jsp" class="btn btn-outline-secondary btn-sm">&larr; Back</a>
            </div>
        </div>

        <%
            String status = request.getParameter("status");
            if ("deleted".equals(status)) {
        %>
            <div class="alert alert-success">The participant account has been removed.</div>
        <%
            }

            String error = request.getParameter("error");
            if (error != null) {
                String message;
                if ("notfound".equals(error)) {
                    message = "That participant no longer exists.";
                } else if ("invalid".equals(error)) {
                    message = "That request was not valid.";
                } else if ("protected".equals(error)) {
                    message = "Administrator accounts cannot be removed from this page.";
                } else {
                    message = "Sorry, the action could not be completed. Please try again.";
                }
        %>
            <div class="alert alert-danger"><%= Web.esc(message) %></div>
        <%
            }
        %>

        <div class="filter-bar">
            <input type="text" class="filter-input" data-filter="tbody .participant-row"
                   placeholder="Search by name or email...">
            <span class="filter-count"></span>
        </div>

        <div class="table-responsive bg-white p-3 shadow-sm rounded">

            <table class="table table-hover align-middle mb-0">

                <thead class="table-primary">
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th class="text-center">Events</th>
                        <th class="text-center">Submitted</th>
                        <th class="text-center">Approved</th>
                        <th>Joined</th>
                        <th width="110">Action</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (loadFailed) {
                %>
                    <tr>
                        <td colspan="8" class="text-danger text-center py-4">
                            Sorry, the participants could not be loaded right now.
                        </td>
                    </tr>
                <%
                    } else if (participants.isEmpty()) {
                %>
                    <tr>
                        <td colspan="8" class="text-center text-muted py-4">
                            No participants have registered yet.
                        </td>
                    </tr>
                <%
                    } else {
                        for (ParticipantSummary participant : participants) {
                %>
                    <tr class="participant-row">
                        <td><%= participant.getUserId() %></td>
                        <td class="fw-bold"><%= Web.esc(participant.getFullName()) %></td>
                        <td><%= Web.esc(participant.getEmail()) %></td>
                        <td class="text-center">
                            <span class="badge bg-secondary"><%= participant.getEventsJoined() %></span>
                        </td>
                        <td class="text-center">
                            <span class="badge bg-secondary"><%= participant.getResultsSubmitted() %></span>
                        </td>
                        <td class="text-center">
                            <span class="badge bg-success"><%= participant.getResultsApproved() %></span>
                        </td>
                        <td class="text-muted"><%= participant.getCreatedAt() %></td>
                        <td>
                            <%-- Removing an account also removes its registrations
                                 and results, because of the ON DELETE CASCADE
                                 foreign keys. --%>
                            <form action="DeleteParticipantServlet" method="post"
                                  onsubmit="return confirm('Remove this participant? Their registrations and submitted results will be deleted too.');">
                                <input type="hidden" name="id" value="<%= participant.getUserId() %>">
                                <button type="submit" class="btn btn-danger btn-sm">Remove</button>
                            </form>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>

            </table>

        </div>

    </div>

</body>
</html>
