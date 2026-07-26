<%-- 
    Document   : submitResult
    Created on : Jul 26, 2026, 7:12:52 AM
    Author     : mnaimzahidi
--%>

<%@ page import="java.sql.*, util.DBConnection" %>
<%
    // Kalau belum login, halau balik ke login page
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Submit Race Result</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="events.jsp">Events</a>
            <a class="text-white me-3 text-decoration-none" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <a href="dashboard.jsp" class="btn btn-outline-secondary mb-3">&larr; Back</a>

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">Submit Your Race Result</h2>
            <p class="text-muted">Pilih event yang anda telah daftar, dan hantar bukti keputusan larian anda.</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <div class="bg-white p-4 shadow-sm rounded">
            <form action="ResultSubmissionServlet" method="post" enctype="multipart/form-data">

                <div class="mb-3">
                    <label class="form-label fw-bold">Select Event</label>
                    <select name="registrationId" class="form-select" required>
                        <%
                            try {
                                Connection conn = DBConnection.getConnection();
                                String sql = "SELECT reg.registration_id, e.event_name "
                                           + "FROM registrations reg "
                                           + "JOIN events e ON reg.event_id = e.event_id "
                                           + "WHERE reg.user_id = ?";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, userId);
                                ResultSet rs = ps.executeQuery();

                                boolean hasEvents = false;
                                while (rs.next()) {
                                    hasEvents = true;
                        %>
                                    <option value="<%= rs.getInt("registration_id") %>">
                                        <%= rs.getString("event_name") %>
                                    </option>
                        <%
                                }
                                if (!hasEvents) {
                        %>
                                    <option value="">-- Anda belum mendaftar event apa-apa --</option>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<option>Error loading events</option>");
                            }
                        %>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Distance Achieved (km)</label>
                    <input type="number" step="0.01" name="distanceAchieved" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Duration</label>
                    <input type="text" name="duration" class="form-control" placeholder="hh:mm:ss" required>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Proof Image</label>
                    <input type="file" name="proofImage" class="form-control" accept="image/*" required>
                </div>

                <button type="submit" class="btn btn-primary w-100 fw-bold">Submit Result</button>
            </form>
        </div>

        <div class="text-center mt-3">
            <a href="viewResultStatus.jsp">View My Results Status</a>
        </div>

    </div>
</body>
</html>