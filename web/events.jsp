<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // This page is open to visitors, but the navigation and the join button
    // change depending on whether somebody is signed in.
    boolean loggedIn = session.getAttribute("userId") != null;
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
                String sql = "SELECT event_id, event_name, description, event_date, distance, fee "
                           + "FROM events ORDER BY event_date";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {

                    boolean hasEvents = false;
                    while (rs.next()) {
                        hasEvents = true;
            %>

            <div class="col-md-4 mb-4 event-card">
                <div class="card h-100 shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title fw-bold text-dark">
                            <%= Web.esc(rs.getString("event_name")) %>
                        </h5>

                        <p class="card-text text-muted">
                            <%= Web.esc(rs.getString("description")) %>
                        </p>

                        <ul class="list-unstyled mb-0">
                            <li><strong>&#128197; Date:</strong> <%= Web.esc(rs.getString("event_date")) %></li>
                            <li><strong>&#127939; Distance:</strong> <%= rs.getDouble("distance") %> KM</li>
                            <li><strong>&#128176; Fee:</strong> RM <%= String.format("%.2f", rs.getDouble("fee")) %></li>
                        </ul>
                    </div>

                    <div class="card-footer bg-white border-top-0">
                        <% if (loggedIn) { %>
                            <form action="RegisterEventServlet" method="post">
                                <input type="hidden" name="eventId" value="<%= rs.getInt("event_id") %>">
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

                    if (!hasEvents) {
            %>
            <div class="col-12">
                <p class="text-center text-muted py-4">
                    There are no events available at the moment. Please check back later.
                </p>
            </div>
            <%
                    }
                } catch (Exception e) {
                    application.log("Loading the events list", e);
            %>
            <div class="col-12">
                <p class="text-center text-danger py-4">
                    Sorry, the events could not be loaded right now.
                </p>
            </div>
            <%
                }
            %>
        </div>
    </div>

</body>
</html>
