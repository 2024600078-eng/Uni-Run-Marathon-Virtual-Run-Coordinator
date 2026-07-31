<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Add Event</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
            <a class="text-white me-3 text-decoration-none" href="manageEvents.jsp">Manage Events</a>
            <a class="text-white me-3 text-decoration-none" href="manageParticipants.jsp">Participants</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="card shadow">

            <div class="card-header bg-success text-white">
                <h3 class="mb-0">Add New Event</h3>
            </div>

            <div class="card-body">

                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                        String message;
                        if ("empty".equals(error)) {
                            message = "Please fill in the event name and date.";
                        } else if ("number".equals(error)) {
                            message = "Distance and fee must be numbers.";
                        } else if ("range".equals(error)) {
                            message = "Distance must be greater than zero and the fee cannot be negative.";
                        } else {
                            message = "Sorry, the event could not be saved. Please try again.";
                        }
                %>
                    <div class="alert alert-danger"><%= Web.esc(message) %></div>
                <%
                    }
                %>

                <form action="AddEventServlet" method="post">

                    <div class="mb-3">
                        <label class="form-label" for="eventName">Event Name</label>
                        <input type="text" name="eventName" id="eventName"
                               class="form-control" maxlength="255" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="description">Description</label>
                        <textarea name="description" id="description"
                                  class="form-control" rows="4" required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="eventDate">Event Date</label>
                        <input type="date" name="eventDate" id="eventDate"
                               class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="distance">Distance (KM)</label>
                        <input type="number" step="0.1" min="0.1" name="distance" id="distance"
                               class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="fee">Fee (RM)</label>
                        <input type="number" step="0.01" min="0" name="fee" id="fee"
                               class="form-control" required>
                    </div>

                    <button type="submit" class="btn btn-success">Save Event</button>
                    <a href="manageEvents.jsp" class="btn btn-secondary">Cancel</a>

                </form>

            </div>

        </div>

    </div>

</body>
</html>
