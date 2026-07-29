<%@page import="java.util.List"%>
<%@page import="dao.ResultDAO"%>
<%@page import="model.Result"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    Public race results, grouped by event and ranked fastest first.

    The ordering and the pace calculation are done by the Model: ResultDAO
    returns the rows already sorted, and Result.getPace() works out the pace.
    This page only groups them and draws the table.
--%>
<%
    boolean loggedIn = session.getAttribute("userId") != null;
    boolean isAdmin = "admin".equals(session.getAttribute("role"));

    List<Result> results = null;
    boolean loadFailed = false;

    try {
        results = new ResultDAO().findApprovedForLeaderboard();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading the leaderboard", e);
    }
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
            if (loadFailed) {
        %>
            <div class="alert alert-danger">
                Sorry, the leaderboard could not be loaded right now.
            </div>
        <%
            } else if (results.isEmpty()) {
        %>
            <div class="card shadow-sm">
                <div class="card-body text-center text-muted py-5">
                    No approved results yet. Once an administrator approves a
                    submission it will appear here.
                </div>
            </div>
        <%
            } else {
                String currentEvent = null;
                int rank = 0;

                for (Result result : results) {

                    // The list arrives grouped by event, so a new table starts
                    // whenever the event name changes.
                    if (!result.getEventName().equals(currentEvent)) {
                        if (currentEvent != null) {
        %>
                        </tbody></table></div></div>
        <%
                        }
                        currentEvent = result.getEventName();
                        rank = 0;
        %>
            <div class="event-block card shadow-sm mb-4">
                <div class="card-body">
                    <h5 class="fw-bold text-primary mb-3"><%= Web.esc(currentEvent) %></h5>
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
                    String rankClass = (rank <= 3) ? ("rank-badge rank-" + rank) : "rank-badge";
                    String pace = result.getPace();
        %>
                            <tr>
                                <td><span class="<%= rankClass %>"><%= rank %></span></td>
                                <td class="fw-bold"><%= Web.esc(result.getParticipantName()) %></td>
                                <td><%= result.getDistanceAchieved() %> KM</td>
                                <td class="fw-bold"><%= Web.esc(result.getDuration()) %></td>
                                <td class="text-muted">
                                    <%= pace.isEmpty() ? "&ndash;" : Web.esc(pace) %>
                                </td>
                            </tr>
        <%
                }
        %>
                        </tbody></table></div></div>
        <%
            }
        %>

    </div>

</body>
</html>
