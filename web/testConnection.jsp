<%@ page import="java.sql.Connection" %>
<%@ page import="util.DBConnection" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Database Connection Test</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            padding: 50px;
            text-align: center;
        }

        .box {
            background: white;
            padding: 30px;
            max-width: 500px;
            margin: auto;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .success {
            color: green;
            font-size: 22px;
            font-weight: bold;
        }

        .error {
            color: red;
            font-size: 22px;
            font-weight: bold;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            background: #0b3d91;
            color: white;
            padding: 12px 22px;
            text-decoration: none;
            border-radius: 6px;
        }
    </style>
</head>

<body>

    <div class="box">
        <h2>Uni-Run Database Connection Test</h2>

        <%
            Connection conn = DBConnection.getConnection();

            if (conn != null) {
        %>
                <p class="success">Database connected successfully ✅</p>
        <%
                conn.close();
            } else {
        %>
                <p class="error">Database connection failed ❌</p>
        <%
            }
        %>

        <a href="index.jsp">Back to Homepage</a>
    </div>

</body>
</html>
