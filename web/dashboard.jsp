<%-- 
    Document   : dashboard
    Created on : Jul 9, 2026, 4:54:26 PM
    Author     : arifs
--%>

<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Participant Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="events.jsp">Events</a>
            <a class="text-white text-decoration-none fw-bold" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
            
        </div>
    </nav>

    <div class="container my-5">
        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">Welcome Back, Participant! 👋</h2>
            <p class="text-muted">Register for the marathon and submit your proof of run here.</p>
        </div>

        <% if("success".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <strong>Tahniah!</strong> Anda berjaya mendaftar untuk acara baharu.
            </div>
        <% } %>

        <h4 class="fw-bold text-primary mb-3">Your Registered Events</h4>
        <div class="table-responsive bg-white p-3 shadow-sm rounded">
            <table class="table table-hover align-middle">
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
                        try {
                            Connection conn = DBConnection.getConnection();
                            // Guna JOIN untuk dapatkan nama event dari table events
                            String query = "SELECT e.event_name, e.event_date, e.distance, r.registration_date, r.status " +
                                           "FROM registrations r JOIN events e ON r.event_id = e.event_id " +
                                           "WHERE r.user_id = 1"; // Hardcode ID user 1 dulu untuk testing
                            PreparedStatement ps = conn.prepareStatement(query);
                            ResultSet rs = ps.executeQuery();
                            
                            boolean hasData = false;
                            while(rs.next()) {
                                hasData = true;
                    %>
                    <tr>
                        <td class="fw-bold"><%= rs.getString("event_name") %></td>
                        <td><%= rs.getString("event_date") %></td>
                        <td><span class="badge bg-secondary"><%= rs.getDouble("distance") %> KM</span></td>
                        <td><%= rs.getTimestamp("registration_date") %></td>
                        <td><span class="badge bg-success"><%= rs.getString("status") %></span></td>
                    </tr>
                    <%
                            }
                            if(!hasData) {
                                out.println("<tr><td colspan='5' class='text-center text-muted py-4'>Anda belum mendaftar mana-mana event lagi.</td></tr>");
                            }
                        } catch(Exception e) {
                            out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
