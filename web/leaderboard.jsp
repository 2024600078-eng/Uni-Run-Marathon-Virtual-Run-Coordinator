<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Open to visitors, in the same way a real race publishes its results.
    // Only approved submissions are listed.
    boolean loggedIn = session.getAttribute("userId") != null;
    boolean isAdmin = "admin".equals(session.getAttribute("role"));
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Leaderboard</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="events.jsp">Events</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="leaderboard.jsp">Leaderboard</a>
            <% if (loggedIn) { %>
                <a class="text-white me-3 text-decoration-none"
                   href="<%= isAdmin ? "adminDashboard.jsp" : "dashboard.jsp" %>">Dashboard</a>
                <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
            <% } else { %>
                <a class="text-white me-3 text-decoration-none" href="login.jsp">Login</a>
                <a class="text-white text-decoration-none" href="register.jsp">Register</a>
            <% } %>
        </div>
    </nav>

    <div class="container my-5">

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">&#127942; Race Leaderboard</h2>
            <p class="text-muted mb-0">
                Approved finishers for each event, fastest time first.
            </p>
        </div>

        <div class="filter-bar">
            <input type="text" class="filter-input" data-filter=".event-block"
                   placeholder="Filter by event or runner name...">
            <span class="filter-count"></span>
        </div>

        <%
            // TIME_TO_SEC turns the stored hh:mm:ss text into a number, so that
            // 9:30:00 sorts before 10:00:00 instead of after it as plain text
            // comparison would give.
            String sql = "SELECT e.event_name, e.distance AS event_distance, u.full_name, "
                       + "r.distance_achieved, r.duration, TIME_TO_SEC(r.duration) AS seconds "
                       + "FROM results r "
                       + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                       + "JOIN users u ON reg.user_id = u.user_id "
                       + "JOIN events e ON reg.event_id = e.event_id "
                       + "WHERE r.approval_status = 'Approved' "
                       + "ORDER BY e.event_date, e.event_name, seconds";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                String currentEvent = null;
                int rank = 0;
                boolean any = false;

                while (rs.next()) {
                    any = true;
                    String eventName = rs.getString("event_name");

                    // Start a new table each time the event changes, and
                    // restart the ranking from one.
                    if (!eventName.equals(currentEvent)) {
                        if (currentEvent != null) {
        %>
                    </tbody></table></div></div>
        <%
                        }
                        currentEvent = eventName;
                        rank = 0;
        %>
            <div class="event-block card shadow-sm mb-4">
                <div class="card-body">
                    <h5 class="fw-bold text-primary mb-3"><%= Web.esc(eventName) %></h5>
                    <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-primary">
                            <tr>
                                <th width="70">Rank</th>
                                <th>Runner</th>
                                <th>Distance</th>
                                <th>Time</th>
                                <th>Pace</th>
                            </tr>
                        </thead>
                        <tbody>
        <%
                    }

                    rank++;

                    double distance = rs.getDouble("distance_achieved");
                    long seconds = rs.getLong("seconds");

                    // Average time per kilometre, shown as m:ss.
                    String pace = "&ndash;";
                    if (distance > 0 && seconds > 0) {
                        long perKm = Math.round(seconds / distance);
                        pace = (perKm / 60) + ":" + String.format("%02d", perKm % 60) + " /km";
                    }

                    String rankClass = (rank <= 3) ? ("rank-badge rank-" + rank) : "rank-badge";
        %>
                            <tr>
                                <td><span class="<%= rankClass %>"><%= rank %></span></td>
                                <td class="fw-bold"><%= Web.esc(rs.getString("full_name")) %></td>
                                <td><%= distance %> KM</td>
                                <td class="fw-bold"><%= Web.esc(rs.getString("duration")) %></td>
                                <td class="text-muted"><%= pace %></td>
                            </tr>
        <%
                }

                if (any) {
        %>
                        </tbody></table></div></div>
        <%
                } else {
        %>
            <div class="card shadow-sm">
                <div class="card-body text-center text-muted py-5">
                    No approved results yet. Once an administrator approves a
                    submission it will appear here.
                </div>
            </div>
        <%
                }
            } catch (Exception e) {
                application.log("Loading the leaderboard", e);
        %>
            <div class="alert alert-danger">
                Sorry, the leaderboard could not be loaded right now.
            </div>
        <%
            }
        %>

    </div>

</body>
</html>
