<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Uni-Run | Marathon & Virtual Run Coordinator</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

    <!-- Navigation Bar -->
    <div class="navbar">
        <div class="logo">Uni-Run</div>

        <div class="nav-links">
            <a href="index.jsp">Home</a>
            <a href="events.jsp">Events</a>
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
            
        </div>
    </div>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1>Marathon & Virtual Run Coordinator</h1>
            <p>
                Uni-Run is a web-based system that helps students and organizers
                manage marathon events, virtual runs, participant registration,
                race results and event information in one platform.
            </p>

            <div class="hero-buttons">
                <a href="events.jsp" class="btn btn-yellow">View Events</a>
                <a href="register.jsp" class="btn btn-white">Join Now</a>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <h2>System Features</h2>
        <div class="features-container">
            <div class="feature-card" onclick="window.location='register.jsp'">
                <a href="register.jsp" class="feature-title-btn">
                Event Registration
                </a>
                <p>
                Participants can browse available marathon and virtual run 
                events and register online.
                </p>
            </div>
            <div class="feature-card" onclick="window.location='submitResult.jsp'">
                <a href="submitResult.jsp" class="feature-title-btn">
                Virtual Run Tracking
                </a>
                <p>
                    Participants can submit virtual run details and track their
                    run progress through the system.
                </p>
            </div>
            <div class="feature-card" onclick="window.location='viewResultStatus.jsp'">
                <a href="viewResultStatus.jsp" class="feature-title-btn">
                Result Management
                </a>
                <p>
                    Organizers can manage participant records, registrations
                    and race results.
                </p>
            </div>
        </div>
    </section>
    
    <!-- Footer -->
    <footer>
        <p>© 2026 Uni-Run System | Marathon & Virtual Run Coordinator</p>
    </footer>

</body>
</html>
