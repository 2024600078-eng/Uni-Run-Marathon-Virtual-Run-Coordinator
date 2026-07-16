<%@page import="java.sql.*"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Uni-Run | Approve Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-primary px-4">
    <a class="navbar-brand fw-bold" href="index.jsp">Uni-Run</a>

    <div>
        <a class="text-white me-3 text-decoration-none" href="adminDashboard.jsp">Dashboard</a>
        <a class="text-white me-3 text-decoration-none fw-bold" href="approveResults.jsp">Approve Results</a>
        <a class="text-white text-decoration-none" href="LogoutServlet">Log Out</a>
    </div>
</nav>

<div class="container mt-5">

    <h2 class="text-primary fw-bold mb-4">
        Result Approval
    </h2>

    <table class="table table-bordered table-hover bg-white">

        <thead class="table-primary">

            <tr>

                <th>ID</th>
                <th>Participant</th>
                <th>Event</th>
                <th>Distance</th>
                <th>Duration</th>
                <th>Status</th>
                <th width="180">Action</th>

            </tr>

        </thead>

        <tbody>

<%

try{

Connection conn = DBConnection.getConnection();

String sql =
"SELECT r.result_id,u.full_name,e.event_name,"
+"r.distance_achieved,r.duration,r.approval_status "
+"FROM results r "
+"JOIN registrations reg ON r.registration_id=reg.registration_id "
+"JOIN users u ON reg.user_id=u.user_id "
+"JOIN events e ON reg.event_id=e.event_id "
+"ORDER BY r.result_id";

PreparedStatement ps = conn.prepareStatement(sql);

ResultSet rs = ps.executeQuery();

boolean found=false;

while(rs.next()){

found=true;

%>

<tr>

<td><%=rs.getInt("result_id")%></td>

<td><%=rs.getString("full_name")%></td>

<td><%=rs.getString("event_name")%></td>

<td><%=rs.getDouble("distance_achieved")%> KM</td>

<td><%=rs.getString("duration")%></td>

<td>

<span class="badge bg-secondary">

<%=rs.getString("approval_status")%>

</span>

</td>

<td>

<a href="ApproveResultServlet?id=<%=rs.getInt("result_id")%>&status=Approved"
class="btn btn-success btn-sm">

Approve

</a>

<a href="ApproveResultServlet?id=<%=rs.getInt("result_id")%>&status=Rejected"
class="btn btn-danger btn-sm">

Reject

</a>

</td>

</tr>

<%

}

if(!found){

%>

<tr>

<td colspan="7" class="text-center text-muted">

No participant submissions found.

</td>

</tr>

<%

}

rs.close();
ps.close();
conn.close();

}catch(Exception e){

%>

<tr>

<td colspan="7" class="text-danger">

<%=e.getMessage()%>

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