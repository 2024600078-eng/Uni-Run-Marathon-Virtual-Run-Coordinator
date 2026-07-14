<%-- 
    Document   : events
    Created on : Jul 9, 2026, 4:52:05 PM
    Author     : arifs
--%>

<%@page import="java.util.List"%>
<%@page import="util.Event"%>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Events List</title>
    <!-- Guna Bootstrap CDN untuk design cepat & kemas -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Copy Navbar kawan kau kat sini supaya design seragam -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="events.jsp">Events</a>
            <a class="text-white text-decoration-none" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="logout.jsp">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">
        <h2 class="text-center fw-bold text-primary mb-4">Available Marathon & Virtual Runs</h2>
        <div class="row">
            <%
                // Tarik data terus dari database
                try {
                    Connection conn = DBConnection.getConnection();
                    String query = "SELECT * FROM events";
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    
                    while(rs.next()) {
            %>
            <div class="col-md-4 mb-4">
                <div class="card h-100 shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title fw-bold text-dark"><%= rs.getString("event_name") %></h5>
                        <p class="card-text text-muted"><%= rs.getString("description") %></p>
                        <ul class="list-unstyled">
                            <li><strong>📅 Tarikh:</strong> <%= rs.getString("event_date") %></li>
                            <li><strong>🏃 Jarak:</strong> <%= rs.getDouble("distance") %> KM</li>
                            <li><strong>💰 Yuran:</strong> RM <%= String.format("%.2f", rs.getDouble("fee")) %></li>
                        </ul>
                    </div>
                    <div class="card-footer bg-white border-top-0">
                        <!-- Form hantar pendaftaran -->
                        <form action="RegisterEventServlet" method="POST">
                            <input type="hidden" name="eventId" value="<%= rs.getInt("event_id") %>">
                            <button type="submit" class="btn btn-primary w-100 fw-bold">Join Event</button>
                        </form>
                    </div>
                </div>
            </div>
            <%
                    }
                } catch(Exception e) {
                    out.println("<p class='text-danger'>Error loading events: " + e.getMessage() + "</p>");
                }
            %>
        </div>
    </div>
</body>
</html>