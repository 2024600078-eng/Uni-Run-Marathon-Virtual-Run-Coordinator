<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Add Event</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
            <a class="text-white me-3 text-decoration-none" href="manageEvents.jsp">Manage Events</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container mt-5">

        <div class="card shadow">

            <div class="card-header bg-success text-white">
                <h3>Add New Event</h3>
            </div>

            <div class="card-body">

                <form action="AddEventServlet" method="post">

                    <div class="mb-3">
                        <label class="form-label">Event Name</label>
                        <input type="text"
                               name="eventName"
                               class="form-control"
                               required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>

                        <textarea
                            name="description"
                            class="form-control"
                            rows="4"
                            required></textarea>

                    </div>

                    <div class="mb-3">
                        <label class="form-label">Event Date</label>

                        <input type="date"
                               name="eventDate"
                               class="form-control"
                               required>

                    </div>

                    <div class="mb-3">
                        <label class="form-label">Distance (KM)</label>

                        <input type="number"
                               step="0.1"
                               name="distance"
                               class="form-control"
                               required>

                    </div>

                    <div class="mb-3">
                        <label class="form-label">Fee (RM)</label>

                        <input type="number"
                               step="0.01"
                               name="fee"
                               class="form-control"
                               required>

                    </div>

                    <button type="submit"
                            class="btn btn-success">

                        Save Event

                    </button>

                    <a href="manageEvents.jsp"
                       class="btn btn-secondary">

                        Cancel

                    </a>

                </form>

            </div>

        </div>

    </div>

</body>
</html>