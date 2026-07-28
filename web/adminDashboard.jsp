<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.sql.*"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Summary figures for the overview panel. All five counts are fetched in a
    // single round trip rather than with one query each.
    int totalEvents = 0;
    int totalParticipants = 0;
    int totalRegistrations = 0;
    int pendingResults = 0;
    int approvedResults = 0;
    boolean statsFailed = false;

    String summarySql =
          "SELECT (SELECT COUNT(*) FROM events) AS total_events, "
        + "(SELECT COUNT(*) FROM users WHERE role = 'participant') AS total_participants, "
        + "(SELECT COUNT(*) FROM registrations) AS total_registrations, "
        + "(SELECT COUNT(*) FROM results WHERE approval_status = 'Pending') AS pending_results, "
        + "(SELECT COUNT(*) FROM results WHERE approval_status = 'Approved') AS approved_results";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(summarySql);
         ResultSet rs = ps.executeQuery()) {

        if (rs.next()) {
            totalEvents = rs.getInt("total_events");
            totalParticipants = rs.getInt("total_participants");
            totalRegistrations = rs.getInt("total_registrations");
            pendingResults = rs.getInt("pending_results");
            approvedResults = rs.getInt("approved_results");
        }
    } catch (Exception e) {
        statsFailed = true;
        application.log("Loading admin dashboard statistics", e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Admin Dashboard</title>
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
            <a class="text-white me-3 text-decoration-none fw-bold" href="adminDashboard.jsp">Admin Dashboard</a>
            <a class="text-white me-3 text-decoration-none" href="manageParticipants.jsp">Participants</a>
            <a class="text-white me-3 text-decoration-none" href="leaderboard.jsp">Leaderboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold">
                Welcome back, <%= Web.esc((String) session.getAttribute("fullName")) %>
            </h2>
            <p class="text-muted mb-0">
                Manage marathon events and approve participant submissions.
            </p>
        </div>

        <% if (statsFailed) { %>
            <div class="alert alert-danger">
                The summary figures could not be loaded right now.
            </div>
        <% } else { %>

        <!-- Summary figures -->
        <h5 class="fw-bold text-primary mb-3">System Overview</h5>

        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-icon">&#127942;</div>
                <div class="stat-value" data-count="<%= totalEvents %>"><%= totalEvents %></div>
                <div class="stat-label">Total Events</div>
            </div>

            <div class="stat-card is-info">
                <div class="stat-icon">&#128101;</div>
                <div class="stat-value" data-count="<%= totalParticipants %>"><%= totalParticipants %></div>
                <div class="stat-label">Participants</div>
            </div>

            <div class="stat-card is-info">
                <div class="stat-icon">&#128221;</div>
                <div class="stat-value" data-count="<%= totalRegistrations %>"><%= totalRegistrations %></div>
                <div class="stat-label">Registrations</div>
            </div>

            <div class="stat-card is-alert">
                <div class="stat-icon">&#9203;</div>
                <div class="stat-value" data-count="<%= pendingResults %>"><%= pendingResults %></div>
                <div class="stat-label">Awaiting Approval</div>
            </div>

            <div class="stat-card is-good">
                <div class="stat-icon">&#9989;</div>
                <div class="stat-value" data-count="<%= approvedResults %>"><%= approvedResults %></div>
                <div class="stat-label">Approved Results</div>
            </div>
        </div>

        <% if (pendingResults > 0) { %>
            <div class="alert alert-warning">
                <strong><%= pendingResults %></strong>
                result<%= pendingResults == 1 ? " is" : "s are" %> waiting for your review.
                <a href="approveResults.jsp" class="fw-bold">Review now</a>
            </div>
        <% } %>

        <!-- Registrations per event -->
        <div class="bg-white p-4 shadow-sm rounded mb-4">
            <h5 class="fw-bold text-primary mb-4">Registrations per Event</h5>
            <%
                String chartSql = "SELECT e.event_name, COUNT(r.registration_id) AS total "
                                + "FROM events e "
                                + "LEFT JOIN registrations r ON e.event_id = r.event_id "
                                + "GROUP BY e.event_id, e.event_name "
                                + "ORDER BY total DESC, e.event_name";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(chartSql);
                     ResultSet rs = ps.executeQuery()) {

                    // The widest bar represents the busiest event and the rest
                    // are drawn in proportion to it.
                    List<String> names = new ArrayList<String>();
                    List<Integer> totals = new ArrayList<Integer>();
                    int highest = 0;

                    while (rs.next()) {
                        names.add(rs.getString("event_name"));
                        int total = rs.getInt("total");
                        totals.add(Integer.valueOf(total));
                        if (total > highest) {
                            highest = total;
                        }
                    }

                    if (names.isEmpty()) {
            %>
                        <p class="text-muted mb-0">No events have been created yet.</p>
            <%
                    } else {
                        for (int i = 0; i < names.size(); i++) {
                            int total = totals.get(i).intValue();
                            int percent = (highest == 0) ? 0 : (int) Math.round(total * 100.0 / highest);
            %>
                        <div class="chart-row">
                            <div class="chart-label" title="<%= Web.esc(names.get(i)) %>">
                                <%= Web.esc(names.get(i)) %>
                            </div>
                            <div class="chart-track">
                                <div class="chart-fill"
                                     style="width: <%= percent %>%; animation-delay: <%= i * 12 %>0ms;"></div>
                            </div>
                            <div class="chart-value"><%= total %></div>
                        </div>
            <%
                        }
                    }
                } catch (Exception e) {
                    application.log("Loading registrations per event", e);
            %>
                    <p class="text-danger mb-0">The chart could not be loaded right now.</p>
            <%
                }
            %>
        </div>

        <% } %>

        <!-- Management shortcuts -->
        <h5 class="fw-bold text-primary mb-3">Management</h5>

        <div class="row">

            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">
                        <h4 class="card-title text-primary">Event Management</h4>
                        <p>Create, update and delete marathon events.</p>
                        <a href="manageEvents.jsp" class="btn btn-primary">Manage Events</a>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">
                        <h4 class="card-title text-success">Result Approval</h4>
                        <p>Review and approve participant submissions.</p>
                        <a href="approveResults.jsp" class="btn btn-success">Approve Results</a>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">
                        <h4 class="card-title text-primary">Participant Management</h4>
                        <p>View every participant and their activity.</p>
                        <a href="manageParticipants.jsp" class="btn btn-primary">Manage Participants</a>
                    </div>
                </div>
            </div>

        </div>

    </div>

    <script>
        /*
         * Counts each summary figure up from zero when the page opens.
         * The final number is already written in the HTML, so if scripting is
         * unavailable the correct value is still displayed.
         */
        (function () {
            var reduceMotion = window.matchMedia
                && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            if (reduceMotion || !window.requestAnimationFrame) {
                return;
            }

            var figures = document.querySelectorAll('.stat-value[data-count]');

            Array.prototype.forEach.call(figures, function (el) {
                var target = parseInt(el.getAttribute('data-count'), 10);

                if (isNaN(target) || target === 0) {
                    return;
                }

                var duration = 900;
                var started = null;

                function step(timestamp) {
                    if (started === null) {
                        started = timestamp;
                    }

                    var progress = Math.min((timestamp - started) / duration, 1);
                    // Ease out, so the number slows as it nears the total.
                    var eased = 1 - Math.pow(1 - progress, 3);
                    el.textContent = Math.round(eased * target);

                    if (progress < 1) {
                        window.requestAnimationFrame(step);
                    }
                }

                el.textContent = '0';
                window.requestAnimationFrame(step);
            });
        })();
    </script>

</body>
</html>
