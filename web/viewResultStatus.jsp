<%-- 
    Document   : viewResultStatus
    Created on : Jul 26, 2026, 7:25:41 AM
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
    <title>Uni-Run | My Race Results</title>
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

        <a href="submitResult.jsp" class="btn btn-outline-secondary mb-3">&larr; Back</a>

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">My Race Results</h2>
            <p class="text-muted">Semak status keputusan larian yang anda telah hantar.</p>
        </div>

        <div class="table-responsive bg-white p-3 shadow-sm rounded">
            <table class="table table-hover align-middle">
                <thead class="table-primary">
                    <tr>
                        <th>Event</th>
                        <th>Distance (km)</th>
                        <th>Duration</th>
                        <th>Proof</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DBConnection.getConnection();
                            String sql = "SELECT e.event_name, r.distance_achieved, r.duration, "
                                       + "r.proof_image, r.approval_status "
                                       + "FROM results r "
                                       + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                                       + "JOIN events e ON reg.event_id = e.event_id "
                                       + "WHERE reg.user_id = ? "
                                       + "ORDER BY r.result_id DESC";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setInt(1, userId);
                            ResultSet rs = ps.executeQuery();

                            boolean hasResults = false;
                            while (rs.next()) {
                                hasResults = true;

                                String status = rs.getString("approval_status");
                                String badgeClass = "bg-secondary";
                                if ("Approved".equalsIgnoreCase(status)) badgeClass = "bg-success";
                                else if ("Pending".equalsIgnoreCase(status)) badgeClass = "bg-warning text-dark";
                                else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "bg-danger";
                    %>
                            <tr>
                                <td class="fw-bold"><%= rs.getString("event_name") %></td>
                                <td><%= rs.getDouble("distance_achieved") %></td>
                                <td><%= rs.getString("duration") %></td>
                                <td>
                                    <%
                                        String proofImage = rs.getString("proof_image");
                                        if (proofImage != null) {
                                    %>
                                        <img src="uploads/<%= proofImage %>" width="80" class="rounded">
                                    <%
                                        } else {
                                    %>
                                        <span class="text-muted">No image</span>
                                    <%
                                        }
                                    %>
                                </td>
                                <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                            </tr>
                    <%
                            }
                            if (!hasResults) {
                                out.println("<tr><td colspan='5' class='text-center text-muted py-4'>Belum ada keputusan disubmit lagi.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div class="text-center mt-3">
            <a href="submitResult.jsp" class="btn btn-primary">Submit New Result</a>
        </div>

    </div>
</body>
</html>