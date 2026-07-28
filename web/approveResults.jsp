<%@include file="/WEB-INF/jspf/adminGuard.jspf" %>
<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page import="util.Web"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uni-Run | Approve Results</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
    <script src="js/app.js"></script>
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-primary px-4">
    <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

    <div>
        <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
        <a class="text-white me-3 text-decoration-none fw-bold" href="approveResults.jsp">Approve Results</a>
        <a class="text-white me-3 text-decoration-none" href="manageParticipants.jsp">Participants</a>
        <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
    </div>
</nav>

<div class="container my-5">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="text-primary fw-bold mb-0">Result Approval</h2>
        <a href="export?type=results" class="btn btn-success btn-sm">&#11015; Export CSV</a>
    </div>

    <%
        String status = request.getParameter("status");
        if ("approved".equals(status) || "rejected".equals(status)) {
    %>
        <div class="alert alert-success">
            The submission has been marked as <%= Web.esc(status) %>.
        </div>
    <%
        }

        String error = request.getParameter("error");
        if (error != null) {
            String message;
            if ("notfound".equals(error)) {
                message = "That submission no longer exists.";
            } else if ("invalid".equals(error)) {
                message = "That request was not valid.";
            } else {
                message = "Sorry, the submission could not be updated. Please try again.";
            }
    %>
        <div class="alert alert-danger"><%= Web.esc(message) %></div>
    <%
        }
    %>

    <div class="filter-bar">
        <input type="text" class="filter-input" data-filter="tbody .result-row"
               placeholder="Search by participant, event or status...">
        <span class="filter-count"></span>
    </div>

    <table class="table table-bordered table-hover bg-white align-middle">

        <thead class="table-primary">
            <tr>
                <th>ID</th>
                <th>Participant</th>
                <th>Event</th>
                <th>Distance</th>
                <th>Duration</th>
                <th>Proof</th>
                <th>Status</th>
                <th width="190">Action</th>
            </tr>
        </thead>

        <tbody>
        <%
            String sql = "SELECT r.result_id, u.full_name, e.event_name, r.distance_achieved, "
                       + "r.duration, r.proof_image, r.approval_status "
                       + "FROM results r "
                       + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                       + "JOIN users u ON reg.user_id = u.user_id "
                       + "JOIN events e ON reg.event_id = e.event_id "
                       + "ORDER BY FIELD(r.approval_status, 'Pending', 'Approved', 'Rejected'), r.result_id";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                boolean found = false;
                while (rs.next()) {
                    found = true;

                    int resultId = rs.getInt("result_id");
                    String approvalStatus = rs.getString("approval_status");
                    String proofImage = rs.getString("proof_image");

                    String badgeClass = "bg-secondary";
                    if ("Approved".equalsIgnoreCase(approvalStatus)) {
                        badgeClass = "bg-success";
                    } else if ("Pending".equalsIgnoreCase(approvalStatus)) {
                        badgeClass = "bg-warning text-dark";
                    } else if ("Rejected".equalsIgnoreCase(approvalStatus)) {
                        badgeClass = "bg-danger";
                    }
        %>
            <tr class="result-row">
                <td><%= resultId %></td>
                <td><%= Web.esc(rs.getString("full_name")) %></td>
                <td><%= Web.esc(rs.getString("event_name")) %></td>
                <td><%= rs.getDouble("distance_achieved") %> KM</td>
                <td><%= Web.esc(rs.getString("duration")) %></td>
                <td>
                    <% if (proofImage != null) { %>
                        <a href="proof?file=<%= Web.esc(proofImage) %>" target="_blank">
                            <img src="proof?file=<%= Web.esc(proofImage) %>"
                                 alt="Proof of run" width="70" class="rounded">
                        </a>
                    <% } else { %>
                        <span class="text-muted">None</span>
                    <% } %>
                </td>
                <td>
                    <span class="badge <%= badgeClass %>"><%= Web.esc(approvalStatus) %></span>
                </td>
                <td>
                    <div class="d-flex gap-2">
                        <%-- Approving changes stored data, so each button posts
                             a form instead of following a plain link. --%>
                        <form action="ApproveResultServlet" method="post">
                            <input type="hidden" name="id" value="<%= resultId %>">
                            <input type="hidden" name="status" value="Approved">
                            <button type="submit" class="btn btn-success btn-sm">Approve</button>
                        </form>

                        <form action="ApproveResultServlet" method="post">
                            <input type="hidden" name="id" value="<%= resultId %>">
                            <input type="hidden" name="status" value="Rejected">
                            <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                        </form>
                    </div>
                </td>
            </tr>
        <%
                }

                if (!found) {
        %>
            <tr>
                <td colspan="8" class="text-center text-muted py-4">
                    No participant submissions found.
                </td>
            </tr>
        <%
                }
            } catch (Exception e) {
                application.log("Loading result submissions for an administrator", e);
        %>
            <tr>
                <td colspan="8" class="text-danger text-center py-4">
                    Sorry, the submissions could not be loaded right now.
                </td>
            </tr>
        <%
            }
        %>
        </tbody>

    </table>

</div>

</body>
</html>
