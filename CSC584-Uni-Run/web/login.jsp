<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Login</title>
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
            <a href="login.jsp" class="active">Login</a>
            <a href="register.jsp">Register</a>
        </div>
    </nav>

    <!-- Login Section -->
    <main class="login-container">
        <section class="auth-card">

            <div class="auth-icon">&#128272;</div>
            <p class="auth-label">WELCOME BACK</p>
            <h1>User Login</h1>
            <p class="auth-description">
                Log in to manage your event registrations and virtual run results.
            </p>

            <%
                if ("registered".equals(request.getParameter("status"))) {
            %>
                <div class="message message-success">
                    Your account has been created. Please log in.
                </div>
            <%
                }

                String error = request.getParameter("error");
                if (error != null) {
                    String message;
                    if ("empty".equals(error)) {
                        message = "Please enter both your email address and password.";
                    } else if ("server".equals(error)) {
                        message = "Sorry, we could not sign you in right now. Please try again.";
                    } else {
                        // The same wording is used for an unknown email and a
                        // wrong password so that the form cannot be used to
                        // find out which addresses are registered.
                        message = "Incorrect email address or password.";
                    }
            %>
                <div class="message message-error"><%= Web.esc(message) %></div>
            <%
                }
            %>

            <form action="LoginServlet" method="post">

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        placeholder="Enter your email address"
                        required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        required>
                </div>

                <button type="submit" class="btn-login">Login</button>

            </form>

            <p class="auth-footer">
                Don't have an account?
                <a href="register.jsp">Register here</a>
            </p>

            <a href="index.jsp" class="back-home">&larr; Back to Home</a>

        </section>
    </main>

    <footer>
        <p>&copy; 2026 Uni-Run System | Marathon &amp; Virtual Run Coordinator</p>
    </footer>

</body>
</html>
