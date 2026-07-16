<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Manage Events</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-dark bg-primary px-4">
        <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

        <div>
            <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
            <a class="text-white me-3 text-decoration-none fw-bold" href="manageEvents.jsp">Manage Events</a>
            <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
        </div>
    </nav>

    <div class="container my-5">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-primary">Event Management</h2>

            <a href="addEvent.jsp" class="btn btn-success">
    + Add Event
</a>
        </div>

        <div class="table-responsive">

            <table class="table table-bordered table-hover bg-white">

                <thead class="table-primary">
                    <tr>
                        <th>ID</th>
                        <th>Event Name</th>
                        <th>Description</th>
                        <th>Date</th>
                        <th>Distance</th>
                        <th>Fee (RM)</th>
                        <th width="180">Action</th>
                    </tr>
                </thead>

                <tbody>

                <%
                    try{

                        Connection conn = DBConnection.getConnection();

                        String sql = "SELECT * FROM events ORDER BY event_id";

                        PreparedStatement ps = conn.prepareStatement(sql);

                        ResultSet rs = ps.executeQuery();

                        while(rs.next()){
                %>

                    <tr>

                        <td><%=rs.getInt("event_id")%></td>

                        <td><%=rs.getString("event_name")%></td>

                        <td><%=rs.getString("description")%></td>

                        <td><%=rs.getString("event_date")%></td>

                        <td><%=rs.getDouble("distance")%> KM</td>

                        <td>RM <%=String.format("%.2f", rs.getDouble("fee"))%></td>

                        <td>

                            <a href="editEvent.jsp?id=<%=rs.getInt("event_id")%>"
   class="btn btn-warning btn-sm">
   Edit
</a>

                            <a href="DeleteEventServlet?id=<%=rs.getInt("event_id")%>"
   class="btn btn-danger btn-sm"
   onclick="return confirm('Are you sure you want to delete this event?');">
   Delete
</a>

                        </td>

                    </tr>

                <%
                        }

                        rs.close();
                        ps.close();
                        conn.close();

                    }catch(Exception e){

                        out.println("<tr>");
                        out.println("<td colspan='7' class='text-danger'>");
                        out.println(e.getMessage());
                        out.println("</td>");
                        out.println("</tr>");

                    }
                %>

                </tbody>

            </table>

        </div>

    </div>

</body>
</html>