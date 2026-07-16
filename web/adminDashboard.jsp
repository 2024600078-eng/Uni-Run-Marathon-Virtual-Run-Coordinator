<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Admin Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="adminDashboard.jsp">Admin Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold">Welcome Back, Admin 👋</h2>
            <p class="text-muted">
                Manage marathon events and approve participant submissions.
            </p>
        </div>

        <div class="row">

            <!-- Manage Events -->
            <div class="col-md-6 mb-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">

                        <h4 class="card-title text-primary">
                            Event Management
                        </h4>

                        <p>
                            Create, update and delete marathon events.
                        </p>

                        <a href="manageEvents.jsp"
                           class="btn btn-primary">
                            Manage Events
                        </a>

                    </div>
                </div>
            </div>

            <!-- Approve Results -->
            <div class="col-md-6 mb-4">
                <div class="card shadow-sm h-100">
                    <div class="card-body">

                        <h4 class="card-title text-success">
                            Result Approval
                        </h4>

                        <p>
                            Review and approve participant submissions.
                        </p>

                        <a href="approveResults.jsp"
                           class="btn btn-success">
                            Approve Results
                        </a>

                    </div>
                </div>
            </div>

        </div>

    </div>

</body>
</html>