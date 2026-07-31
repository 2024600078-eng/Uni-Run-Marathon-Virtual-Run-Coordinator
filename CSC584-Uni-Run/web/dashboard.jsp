<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.util.List"%>
<%@page import="dao.RegistrationDAO"%>
<%@page import="dao.StatisticsDAO"%>
<%@page import="model.ParticipantStatistics"%>
<%@page import="model.Registration"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    VIEW COMPONENT

    The participant's own dashboard. Both the summary figures and the list of
    registered events come from the Model, so this page contains no SQL.
--%>
<%
    ParticipantStatistics stats = null;
    List<Registration> registrations = null;
    boolean loadFailed = false;

    try {
        stats = new StatisticsDAO().findParticipantStatistics(currentUserId);
        registrations = new RegistrationDAO().findByUser(currentUserId);
    } catch (Exception e) {
        loadFailed = true;
        application.log("Loading dashboard for user " + currentUserId, e);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Participant Dashboard</title>
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
            <a class="text-white me-3 text-decoration-none fw-bold" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">
        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">
                Welcome back, <%= Web.esc((String) session.getAttribute("fullName")) %>
            </h2>
            <p class="text-muted mb-0">
                Register for an event and submit your proof of run here.
            </p>
        </div>

        <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success">
                <strong>Success.</strong> You have been registered for the event.
            </div>
        <% } %>

        <% if (!loadFailed) { %>
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-icon">&#127939;</div>
                <div class="stat-value" data-count="<%= stats.getEventsJoined() %>"><%= stats.getEventsJoined() %></div>
                <div class="stat-label">Events Joined</div>
            </div>

            <div class="stat-card is-info">
                <div class="stat-icon">&#128228;</div>
                <div class="stat-value" data-count="<%= stats.getResultsSubmitted() %>"><%= stats.getResultsSubmitted() %></div>
                <div class="stat-label">Results Sent</div>
            </div>

            <div class="stat-card is-good">
                <div class="stat-icon">&#9989;</div>
                <div class="stat-value" data-count="<%= stats.getResultsApproved() %>"><%= stats.getResultsApproved() %></div>
                <div class="stat-label">Approved</div>
            </div>

            <div class="stat-card is-alert">
                <div class="stat-icon">&#9203;</div>
                <div class="stat-value" data-count="<%= stats.getResultsPending() %>"><%= stats.getResultsPending() %></div>
                <div class="stat-label">Pending Review</div>
            </div>
        </div>
        <% } %>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="fw-bold text-primary mb-0">Your Registered Events</h4>
            <div>
                <a href="events.jsp" class="btn btn-outline-primary btn-sm">Browse Events</a>
                <a href="submitResult.jsp" class="btn btn-primary btn-sm">Submit Result</a>
            </div>
        </div>

        <div class="table-responsive bg-white p-3 shadow-sm rounded">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-primary">
                    <tr>
                        <th>Event Name</th>
                        <th>Date</th>
                        <th>Distance</th>
                        <th>Registration Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (loadFailed) {
                %>
                    <tr>
                        <td colspan="5" class="text-danger text-center py-4">
                            Sorry, your registrations could not be loaded right now.
                        </td>
                    </tr>
                <%
                    } else if (registrations.isEmpty()) {
                %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">
                            You have not registered for any events yet.
                            <a href="events.jsp">Browse the available events</a>.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Registration registration : registrations) {
                %>
                    <tr>
                        <td class="fw-bold"><%= Web.esc(registration.getEventName()) %></td>
                        <td><%= Web.esc(registration.getEventDate()) %></td>
                        <td><span class="badge bg-secondary"><%= registration.getEventDistance() %> KM</span></td>
                        <td><%= registration.getRegistrationDate() %></td>
                        <td><span class="badge bg-success"><%= Web.esc(registration.getStatus()) %></span></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        /* Counts the personal totals up from zero. The real numbers are
           already in the HTML, so the page is still correct without script. */
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
