<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    int eventId = Integer.parseInt(request.getParameter("id"));

    Connection conn = DBConnection.getConnection();

    String sql = "SELECT * FROM events WHERE event_id=?";

    PreparedStatement ps = conn.prepareStatement(sql);

    ps.setInt(1, eventId);

    ResultSet rs = ps.executeQuery();

    rs.next();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Edit Event</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

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

            <div class="card-header bg-warning">
                <h3>Edit Event</h3>
            </div>

            <div class="card-body">

                <form action="EditEventServlet" method="post">

                    <input type="hidden"
                           name="eventId"
                           value="<%=rs.getInt("event_id")%>">

                    <div class="mb-3">
                        <label>Event Name</label>

                        <input type="text"
                               name="eventName"
                               class="form-control"
                               value="<%=rs.getString("event_name")%>"
                               required>
                    </div>

                    <div class="mb-3">
                        <label>Description</label>

                        <textarea
                            name="description"
                            class="form-control"
                            rows="4"
                            required><%=rs.getString("description")%></textarea>

                    </div>

                    <div class="mb-3">
                        <label>Event Date</label>

                        <input type="date"
                               name="eventDate"
                               class="form-control"
                               value="<%=rs.getString("event_date")%>"
                               required>
                    </div>

                    <div class="mb-3">
                        <label>Distance (KM)</label>

                        <input type="number"
                               step="0.1"
                               name="distance"
                               class="form-control"
                               value="<%=rs.getDouble("distance")%>"
                               required>
                    </div>

                    <div class="mb-3">
                        <label>Fee (RM)</label>

                        <input type="number"
                               step="0.01"
                               name="fee"
                               class="form-control"
                               value="<%=rs.getDouble("fee")%>"
                               required>
                    </div>

                    <button type="submit" class="btn btn-warning">
                        Update Event
                    </button>

                    <a href="manageEvents.jsp" class="btn btn-secondary">
                        Cancel
                    </a>

                </form>

            </div>

        </div>

    </div>

</body>
</html>