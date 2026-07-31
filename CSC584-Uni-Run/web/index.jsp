<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    boolean loggedIn = session.getAttribute("userId") != null;
    boolean isAdmin = "admin".equals(session.getAttribute("role"));
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Marathon &amp; Virtual Run Coordinator</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/theme.css">
    <script src="js/app.js"></script>
</head>

<body>

    <!-- Navigation Bar -->
    <nav class="navbar">
        <a href="index.jsp" class="logo">Uni-Run</a>

        <div class="nav-links">
            <a href="index.jsp" class="active">Home</a>
            <a href="events.jsp">Events</a>
            <a href="leaderboard.jsp">Leaderboard</a>
            <% if (loggedIn) { %>
                <a href="<%= isAdmin ? "adminDashboard.jsp" : "dashboard.jsp" %>">Dashboard</a>
                <a href="LogoutServlet" class="logout-btn">Log Out</a>
            <% } else { %>
                <a href="login.jsp">Login</a>
                <a href="register.jsp">Register</a>
            <% } %>
        </div>
    </nav>

    <% if ("loggedout".equals(request.getParameter("status"))) { %>
        <div class="message message-success" style="max-width:1000px;margin:20px auto;">
            You have been logged out successfully.
        </div>
    <% } %>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <p class="hero-label">RUN. TRACK. ACHIEVE.</p>

            <h1>Marathon &amp; Virtual Run Coordinator</h1>

            <p class="hero-description">
                Uni-Run helps students and organizers manage marathon events,
                virtual runs, participant registration, race results and event
                information in one convenient platform.
            </p>

            <div class="hero-buttons">
                <a href="events.jsp" class="btn btn-yellow">View Events</a>
                <% if (loggedIn) { %>
                    <a href="<%= isAdmin ? "adminDashboard.jsp" : "dashboard.jsp" %>"
                       class="btn btn-white">Go to Dashboard</a>
                <% } else { %>
                    <a href="register.jsp" class="btn btn-white">Join Now</a>
                <% } %>
            </div>
        </div>

        <div class="hero-card">
            <div class="hero-card-icon">&#127939;</div>
            <h2>Your Running Journey Starts Here</h2>
            <p>
                Browse events, register online, submit virtual run results,
                and stay updated with your race progress.
            </p>

            <div class="hero-stats">
                <div>
                    <strong>Events</strong>
                    <span>Explore races</span>
                </div>
                <div>
                    <strong>Results</strong>
                    <span>Track progress</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <div class="section-heading">
            <p class="section-label">WHAT UNI-RUN OFFERS</p>
            <h2>System Features</h2>
            <p>
                Everything needed to manage your marathon and virtual run journey.
            </p>
        </div>

        <div class="features-container">

            <a href="events.jsp" class="feature-card">
                <div class="feature-icon">&#128221;</div>
                <h3>Event Registration</h3>
                <p>
                    Browse available marathon and virtual run events, then
                    register online easily.
                </p>
                <span class="feature-link">Browse events &rarr;</span>
            </a>

            <a href="submitResult.jsp" class="feature-card">
                <div class="feature-icon">&#8986;</div>
                <h3>Virtual Run Tracking</h3>
                <p>
                    Submit virtual run details and track your running progress
                    through the system.
                </p>
                <span class="feature-link">Submit result &rarr;</span>
            </a>

            <a href="viewResultStatus.jsp" class="feature-card">
                <div class="feature-icon">&#127942;</div>
                <h3>Result Management</h3>
                <p>
                    Organizers can manage participant records, registrations
                    and race results.
                </p>
                <span class="feature-link">View results &rarr;</span>
            </a>

        </div>
    </section>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 Uni-Run System | Marathon &amp; Virtual Run Coordinator</p>
    </footer>

</body>
</html>
