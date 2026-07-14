<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>

    <style>

        body{
            font-family: Arial;
            background:#eef3f9;
        }

        .container{

            width:400px;
            margin:80px auto;
            background:white;
            padding:30px;
            border-radius:10px;
            box-shadow:0 0 10px #ccc;

        }

        h2{

            text-align:center;
            color:#0b3d91;

        }

        input{

            width:100%;
            padding:12px;
            margin:10px 0;

        }

        button{

            width:100%;
            padding:12px;
            background:#0b3d91;
            color:white;
            border:none;
            cursor:pointer;

        }

        a{

            text-decoration:none;

        }

    </style>

</head>

<body>

<div class="container">

<h2>User Login</h2>

<form action="LoginServlet" method="post">

    <input type="email"
           name="email"
           placeholder="Email"
           required>

    <input type="password"
           name="password"
           placeholder="Password"
           required>

    <button type="submit">Login</button>

</form>

<br>

<center>

<a href="register.jsp">Don't have an account? Register</a>

</center>

</div>

</body>
</html>