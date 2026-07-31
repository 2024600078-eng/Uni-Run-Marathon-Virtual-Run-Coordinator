<%@page import="java.util.List"%>
<%@page import="dao.EventDAO"%>
<%@page import="model.Event"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    Displays the list of available events.

    This page contains no SQL. It asks the Model, through EventDAO, for a list
    of Event objects and is responsible only for presenting them.
--%>
<%
    boolean loggedIn = session.getAttribute("userId") != null;

    List<Event> events = null;
    boolean loadFailed = false;

    try {
        events = new EventDAO().findAll();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading the events list", e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Events List</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="events.jsp">Events</a>
            <a class="text-white me-3 text-decoration-none" href="leaderboard.jsp">Leaderboard</a>
            <% if (loggedIn) { %>
                <a class="text-white me-3 text-decoration-none" href="dashboard.jsp">Dashboard</a>
                <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
            <% } else { %>
                <a class="text-white me-3 text-decoration-none" href="login.jsp">Login</a>
                <a class="text-white text-decoration-none" href="register.jsp">Register</a>
            <% } %>
        </div>
    </nav>

    <div class="container my-5">
        <h2 class="text-center fw-bold text-primary mb-4">
            Available Marathon &amp; Virtual Runs
        </h2>

        <%
            String error = request.getParameter("error");
            if (error != null) {
                String message;
                if ("duplicate".equals(error)) {
                    message = "You have already registered for that event.";
                } else if ("notfound".equals(error)) {
                    message = "That event is no longer available.";
                } else if ("invalid".equals(error)) {
                    message = "Please choose a valid event.";
                } else {
                    message = "Sorry, your registration could not be completed. Please try again.";
                }
        %>
            <div class="alert alert-warning text-center"><%= Web.esc(message) %></div>
        <%
            }
        %>

        <div class="filter-bar">
            <input type="text" class="filter-input" data-filter=".event-card"
                   placeholder="Search events by name or description...">
            <span class="filter-count"></span>
        </div>

        <div class="row">
        <%
            if (loadFailed) {
        %>
            <div class="col-12">
                <p class="text-center text-danger py-4">
                    Sorry, the events could not be loaded right now.
                </p>
            </div>
        <%
            } else if (events.isEmpty()) {
        %>
            <div class="col-12">
                <p class="text-center text-muted py-4">
                    There are no events available at the moment. Please check back later.
                </p>
            </div>
        <%
            } else {
                for (Event event : events) {
        %>
            <div class="col-md-4 mb-4 event-card">
                <div class="card h-100 shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title fw-bold text-dark">
                            <%= Web.esc(event.getEventName()) %>
                        </h5>

                        <p class="card-text text-muted">
                            <%= Web.esc(event.getDescription()) %>
                        </p>

                        <ul class="list-unstyled mb-0">
                            <li><strong>&#128197; Date:</strong> <%= Web.esc(event.getEventDate()) %></li>
                            <li><strong>&#127939; Distance:</strong> <%= event.getDistance() %> KM</li>
                            <li>
                                <strong>&#128176; Fee:</strong>
                                <% if (event.isFree()) { %>
                                    <span class="badge bg-success">Free</span>
                                <% } else { %>
                                    RM <%= String.format("%.2f", event.getFee()) %>
                                <% } %>
                            </li>
                        </ul>
                    </div>

                    <div class="card-footer bg-white border-top-0">
                        <% if (loggedIn) { %>
                            <form action="RegisterEventServlet" method="post">
                                <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                                <button type="submit" class="btn btn-primary w-100 fw-bold">
                                    Join Event
                                </button>
                            </form>
                        <% } else { %>
                            <a href="login.jsp" class="btn btn-outline-primary w-100 fw-bold">
                                Log in to join
                            </a>
                        <% } %>
                    </div>
                </div>
            </div>
        <%
                }
            }
        %>
        </div>
    </div>

</body>
</html>
