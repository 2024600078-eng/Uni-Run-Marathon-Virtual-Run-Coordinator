<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.EventDAO"%>
<%@page import="model.Event"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    Lists the events for an administrator, with links to add, edit and delete.
    Data comes from EventDAO; this page contains no SQL.
--%>
<%
    List<Event> events = null;
    boolean loadFailed = false;

    try {
        events = new EventDAO().findAll();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading the event list for an administrator", e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Manage Events</title>
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
            <a class="text-white me-3 text-decoration-none fw-bold" href="manageEvents.jsp">Manage Events</a>
            <a class="text-white me-3 text-decoration-none" href="manageParticipants.jsp">Participants</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-primary mb-0">Event Management</h2>
            <a href="addEvent.jsp" class="btn btn-success">+ Add Event</a>
        </div>

        <%
            String status = request.getParameter("status");
            if (status != null) {
                String message;
                if ("added".equals(status)) {
                    message = "The event has been created.";
                } else if ("updated".equals(status)) {
                    message = "The event has been updated.";
                } else if ("deleted".equals(status)) {
                    message = "The event has been deleted.";
                } else {
                    message = "Done.";
                }
        %>
            <div class="alert alert-success"><%= Web.esc(message) %></div>
        <%
            }

            String error = request.getParameter("error");
            if (error != null) {
                String message;
                if ("notfound".equals(error)) {
                    message = "That event no longer exists.";
                } else if ("invalid".equals(error)) {
                    message = "That request was not valid.";
                } else {
                    message = "Sorry, the action could not be completed. Please try again.";
                }
        %>
            <div class="alert alert-danger"><%= Web.esc(message) %></div>
        <%
            }
        %>

        <div class="filter-bar">
            <input type="text" class="filter-input" data-filter="tbody .event-row"
                   placeholder="Search events...">
            <span class="filter-count"></span>
        </div>

        <div class="table-responsive">

            <table class="table table-bordered table-hover bg-white align-middle">

                <thead class="table-primary">
                    <tr>
                        <th>ID</th>
                        <th>Event Name</th>
                        <th>Description</th>
                        <th>Date</th>
                        <th>Distance</th>
                        <th>Fee (RM)</th>
                        <th width="180">Action</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (loadFailed) {
                %>
                    <tr>
                        <td colspan="7" class="text-danger text-center py-4">
                            Sorry, the events could not be loaded right now.
                        </td>
                    </tr>
                <%
                    } else if (events.isEmpty()) {
                %>
                    <tr>
                        <td colspan="7" class="text-center text-muted py-4">
                            No events have been created yet.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Event event : events) {
                %>
                    <tr class="event-row">
                        <td><%= event.getEventId() %></td>
                        <td><%= Web.esc(event.getEventName()) %></td>
                        <td><%= Web.esc(event.getDescription()) %></td>
                        <td><%= Web.esc(event.getEventDate()) %></td>
                        <td><%= event.getDistance() %> KM</td>
                        <td>RM <%= String.format("%.2f", event.getFee()) %></td>
                        <td>
                            <div class="d-flex gap-2">
                                <a href="editEvent.jsp?id=<%= event.getEventId() %>"
                                   class="btn btn-warning btn-sm">Edit</a>

                                <%-- A delete changes data, so it is sent as a POST
                                     rather than as a link that could be followed
                                     by accident. --%>
                                <form action="DeleteEventServlet" method="post"
                                      onsubmit="return confirm('Delete this event? Its registrations and results will be removed too.');">
                                    <input type="hidden" name="id" value="<%= event.getEventId() %>">
                                    <button type="submit" class="btn btn-danger btn-sm">Delete</button>
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

    </div>

</body>
</html>
