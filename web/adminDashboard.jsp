<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.EventDAO"%>
<%@page import="dao.StatisticsDAO"%>
<%@page import="model.EventRegistrationCount"%>
<%@page import="model.SystemStatistics"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    The administrator dashboard.

    Both the summary figures and the chart data come from the Model. The bar
    widths are worked out by EventRegistrationCount.percentageOf, so this page
    does no arithmetic and contains no SQL.
--%>
<%
    SystemStatistics stats = null;
    List<EventRegistrationCount> chart = null;
    boolean loadFailed = false;

    try {
        stats = new StatisticsDAO().findSystemStatistics();
        chart = new EventDAO().findRegistrationCounts();
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading admin dashboard statistics", e);
    }

    // The widest bar represents the busiest event and the rest are drawn in
    // proportion to it.
    int highest = 0;
    if (chart != null) {
        for (EventRegistrationCount row : chart) {
            if (row.getTotal() > highest) {
                highest = row.getTotal();
            }
        }
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

        <% if (loadFailed) { %>
            <div class="alert alert-danger">
                The summary figures could not be loaded right now.
            </div>
        <% } else { %>

        <!-- Summary figures -->
        <h5 class="fw-bold text-primary mb-3">System Overview</h5>

        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-icon">&#127942;</div>
                <div class="stat-value" data-count="<%= stats.getTotalEvents() %>"><%= stats.getTotalEvents() %></div>
                <div class="stat-label">Total Events</div>
            </div>

            <div class="stat-card is-info">
                <div class="stat-icon">&#128101;</div>
                <div class="stat-value" data-count="<%= stats.getTotalParticipants() %>"><%= stats.getTotalParticipants() %></div>
                <div class="stat-label">Participants</div>
            </div>

            <div class="stat-card is-info">
                <div class="stat-icon">&#128221;</div>
                <div class="stat-value" data-count="<%= stats.getTotalRegistrations() %>"><%= stats.getTotalRegistrations() %></div>
                <div class="stat-label">Registrations</div>
            </div>

            <div class="stat-card is-alert">
                <div class="stat-icon">&#9203;</div>
                <div class="stat-value" data-count="<%= stats.getPendingResults() %>"><%= stats.getPendingResults() %></div>
                <div class="stat-label">Awaiting Approval</div>
            </div>

            <div class="stat-card is-good">
                <div class="stat-icon">&#9989;</div>
                <div class="stat-value" data-count="<%= stats.getApprovedResults() %>"><%= stats.getApprovedResults() %></div>
                <div class="stat-label">Approved Results</div>
            </div>
        </div>

        <% if (stats.hasPendingWork()) { %>
            <div class="alert alert-warning">
                <strong><%= stats.getPendingResults() %></strong>
                result<%= stats.getPendingResults() == 1 ? " is" : "s are" %> waiting for your review.
                <a href="approveResults.jsp" class="fw-bold">Review now</a>
            </div>
        <% } %>

        <!-- Registrations per event -->
        <div class="bg-white p-4 shadow-sm rounded mb-4">
            <h5 class="fw-bold text-primary mb-4">Registrations per Event</h5>
            <%
                if (chart.isEmpty()) {
            %>
                <p class="text-muted mb-0">No events have been created yet.</p>
            <%
                } else {
                    int index = 0;
                    for (EventRegistrationCount row : chart) {
            %>
                <div class="chart-row">
                    <div class="chart-label" title="<%= Web.esc(row.getEventName()) %>">
                        <%= Web.esc(row.getEventName()) %>
                    </div>
                    <div class="chart-track">
                        <div class="chart-fill"
                             style="width: <%= row.percentageOf(highest) %>%; animation-delay: <%= index * 12 %>0ms;"></div>
                    </div>
                    <div class="chart-value"><%= row.getTotal() %></div>
                </div>
            <%
                        index++;
                    }
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
        /* Counts each summary figure up from zero when the page opens. The
           final number is already in the HTML, so if scripting is unavailable
           the correct value is still shown. */
        (function () {
            var reduceMotion = window.matchMedia
                && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            if (reduceMotion || !window.requestAnimationFrame) {
                return;
            }

            Array.prototype.forEach.call(
                document.querySelectorAll('.stat-value[data-count]'),
                function (el) {
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
                        var eased = 1 - Math.pow(1 - progress, 3);
                        el.textContent = Math.round(eased * target);
                        if (progress < 1) {
                            window.requestAnimationFrame(step);
                        }
                    }

                    el.textContent = '0';
                    window.requestAnimationFrame(step);
                }
            );
        })();
    </script>

</body>
</html>
