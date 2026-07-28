<%@include file="/WEB-INF/jspf/participantGuard.jspf" %>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | My Race Results</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>
        <div>
            <a class="text-white me-3 text-decoration-none" href="index.jsp">Home</a>
            <a class="text-white me-3 text-decoration-none" href="events.jsp">Events</a>
            <a class="text-white me-3 text-decoration-none" href="leaderboard.jsp">Leaderboard</a>
            <a class="text-white me-3 text-decoration-none" href="dashboard.jsp">Dashboard</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <a href="dashboard.jsp" class="btn btn-outline-secondary mb-3">&larr; Back</a>

        <div class="p-4 bg-white shadow-sm rounded mb-4">
            <h2 class="fw-bold text-dark">My Race Results</h2>
            <p class="text-muted mb-0">Check the status of the results you have submitted.</p>
        </div>

        <%
            String status = request.getParameter("status");
            if ("submitted".equals(status)) {
        %>
            <div class="alert alert-success">
                <strong>Thank you.</strong> Your result has been submitted and is waiting for approval.
            </div>
        <%
            } else if ("resubmitted".equals(status)) {
        %>
            <div class="alert alert-success">
                <strong>Thank you.</strong> Your corrected result has replaced the rejected one
                and is waiting for approval again.
            </div>
        <%
            }

            String error = request.getParameter("error");
            if (error != null) {
                String message;
                if ("notapproved".equals(error)) {
                    message = "A certificate is only available once your result has been approved.";
                } else if ("notfound".equals(error)) {
                    message = "That result could not be found.";
                } else if ("invalid".equals(error)) {
                    message = "That request was not valid.";
                } else {
                    message = "Sorry, something went wrong. Please try again.";
                }
        %>
            <div class="alert alert-warning"><%= Web.esc(message) %></div>
        <%
            }
        %>

        <div class="table-responsive bg-white p-3 shadow-sm rounded">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-primary">
                    <tr>
                        <th>Event</th>
                        <th>Distance (km)</th>
                        <th>Duration</th>
                        <th>Proof</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String sql = "SELECT e.event_name, r.result_id, r.distance_achieved, r.duration, "
                                   + "r.proof_image, r.approval_status, reg.registration_id "
                                   + "FROM results r "
                                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                                   + "JOIN events e ON reg.event_id = e.event_id "
                                   + "WHERE reg.user_id = ? "
                                   + "ORDER BY r.result_id DESC";

                        try (Connection conn = DBConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement(sql)) {

                            ps.setInt(1, currentUserId);

                            try (ResultSet rs = ps.executeQuery()) {

                                boolean hasResults = false;
                                while (rs.next()) {
                                    hasResults = true;

                                    String approvalStatus = rs.getString("approval_status");
                                    boolean rejected = "Rejected".equalsIgnoreCase(approvalStatus);

                                    String badgeClass = "bg-secondary";
                                    if ("Approved".equalsIgnoreCase(approvalStatus)) {
                                        badgeClass = "bg-success";
                                    } else if ("Pending".equalsIgnoreCase(approvalStatus)) {
                                        badgeClass = "bg-warning text-dark";
                                    } else if (rejected) {
                                        badgeClass = "bg-danger";
                                    }

                                    String proofImage = rs.getString("proof_image");
                    %>
                            <tr>
                                <td class="fw-bold"><%= Web.esc(rs.getString("event_name")) %></td>
                                <td><%= rs.getDouble("distance_achieved") %></td>
                                <td><%= Web.esc(rs.getString("duration")) %></td>
                                <td>
                                    <%
                                        // Images are served by a servlet that checks
                                        // the viewer, because the upload folder sits
                                        // outside the application.
                                        if (proofImage != null) {
                                    %>
                                        <img src="proof?file=<%= Web.esc(proofImage) %>"
                                             alt="Proof of run" width="80" class="rounded">
                                    <% } else { %>
                                        <span class="text-muted">No image</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge <%= badgeClass %>"><%= Web.esc(approvalStatus) %></span>
                                </td>
                                <td>
                                    <% if (rejected) { %>
                                        <a class="btn btn-primary btn-sm"
                                           href="submitResult.jsp?registrationId=<%= rs.getInt("registration_id") %>">
                                            Resubmit
                                        </a>
                                    <% } else if ("Approved".equalsIgnoreCase(approvalStatus)) { %>
                                        <a class="btn btn-success btn-sm"
                                           href="certificate.jsp?resultId=<%= rs.getInt("result_id") %>">
                                            &#127942; Certificate
                                        </a>
                                    <% } else { %>
                                        <span class="text-muted">&ndash;</span>
                                    <% } %>
                                </td>
                            </tr>
                    <%
                                }

                                if (!hasResults) {
                    %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">
                                    You have not submitted any results yet.
                                </td>
                            </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            application.log("Loading results for user " + currentUserId, e);
                    %>
                            <tr>
                                <td colspan="6" class="text-danger text-center py-4">
                                    Sorry, your results could not be loaded right now.
                                </td>
                            </tr>
                    <%
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
