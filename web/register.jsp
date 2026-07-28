<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // RegisterServlet forwards back here with these attributes when the details
    // it received were not acceptable, so the visitor does not lose their work.
    String errorMessage = (String) request.getAttribute("error");
    String previousName = (String) request.getAttribute("fullName");
    String previousEmail = (String) request.getAttribute("email");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Register</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/theme.css">
    <script src="js/app.js"></script>
</head>

<body class="auth-page">

    <!-- Navigation Bar -->
    <nav class="navbar">
        <a href="index.jsp" class="logo">Uni-Run</a>

        <div class="nav-links">
            <a href="index.jsp">Home</a>
            <a href="events.jsp">Events</a>
            <a href="leaderboard.jsp">Leaderboard</a>
            <a href="login.jsp">Login</a>
            <a href="register.jsp" class="active">Register</a>
        </div>
    </nav>

    <!-- Registration Section -->
    <main class="login-container">
        <section class="auth-card">

            <div class="auth-icon">&#128221;</div>
            <p class="auth-label">GET STARTED</p>
            <h1>Create Your Account</h1>
            <p class="auth-description">
                Join Uni-Run and start your marathon journey today.
            </p>

            <% if (errorMessage != null) { %>
                <div class="message message-error"><%= Web.esc(errorMessage) %></div>
            <% } %>

            <form action="RegisterServlet" method="post">

                <div class="form-group">
                    <label for="full_name">Full Name</label>
                    <input
                        type="text"
                        id="full_name"
                        name="full_name"
                        placeholder="Enter your full name"
                        maxlength="100"
                        value="<%= Web.esc(previousName) %>"
                        required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        placeholder="Enter your email address"
                        maxlength="100"
                        value="<%= Web.esc(previousEmail) %>"
                        required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="At least 6 characters"
                        minlength="6"
                        required>
                </div>

                <button type="submit" class="btn-login">Create Account</button>

            </form>

            <p class="auth-footer">
                Already have an account?
                <a href="login.jsp">Login here</a>
            </p>

            <a href="index.jsp" class="back-home">&larr; Back to Home</a>

        </section>
    </main>

    <footer>
        <p>&copy; 2026 Uni-Run System | Marathon &amp; Virtual Run Coordinator</p>
    </footer>

</body>
</html>
