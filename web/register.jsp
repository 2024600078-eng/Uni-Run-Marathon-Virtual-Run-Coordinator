<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Uni-Run | Register</title>

    <link rel="stylesheet" href="css/style.css">

    <style>

        body{
            margin:0;
            font-family:Arial, Helvetica, sans-serif;
            background:#f4f8fc;
        }

        header{
            background:#0b3d91;
            color:white;
            display:flex;
            justify-content:space-between;
            align-items:center;
            padding:15px 60px;
        }

        .logo{
            font-size:28px;
            font-weight:bold;
        }

        nav a{
            color:white;
            text-decoration:none;
            margin-left:25px;
            font-weight:bold;
        }

        nav a:hover{
            color:#ffd54f;
        }

        .register-container{

            display:flex;
            justify-content:center;
            align-items:center;
            padding:70px 20px;

        }

        .register-card{

            width:450px;
            background:white;
            padding:40px;
            border-radius:15px;
            box-shadow:0 8px 25px rgba(0,0,0,.15);

        }

        .register-card h2{

            color:#0b3d91;
            text-align:center;
            margin-bottom:10px;

        }

        .register-card p{

            text-align:center;
            color:#666;
            margin-bottom:30px;

        }

        label{

            font-weight:bold;
            color:#333;

        }

        input[type=text],
        input[type=email],
        input[type=password]{

            width:100%;
            padding:12px;
            margin-top:8px;
            margin-bottom:20px;
            border:1px solid #ccc;
            border-radius:8px;
            box-sizing:border-box;
            font-size:15px;

        }

        input[type=submit]{

            width:100%;
            background:#0b3d91;
            color:white;
            border:none;
            padding:14px;
            border-radius:8px;
            font-size:17px;
            cursor:pointer;
            transition:.3s;

        }

        input[type=submit]:hover{

            background:#1565c0;

        }

        .login-link{

            text-align:center;
            margin-top:20px;

        }

        .login-link a{

            color:#0b3d91;
            text-decoration:none;
            font-weight:bold;

        }

        footer{

            background:#0b3d91;
            color:white;
            text-align:center;
            padding:15px;
            margin-top:50px;

        }

    </style>

</head>

<body>

<header>

    <a href="index.jsp" class="logo">
    Uni-Run
    </a>

    <nav>

        <a href="index.jsp">Home</a>
        <a href="events.jsp">Events</a>
        <a href="login.jsp">Login</a>
        <a href="register.jsp">Register</a>

    </nav>

</header>

<div class="register-container">

    <div class="register-card">

        <h2>Create Your Account</h2>

        <p>Join Uni-Run and start your marathon journey today.</p>

        <form action="RegisterServlet" method="post">

            <label>Full Name</label>

            <input type="text"
                   name="full_name"
                   placeholder="Enter your full name"
                   required>

            <label>Email Address</label>

            <input type="email"
                   name="email"
                   placeholder="Enter your email"
                   required>

            <label>Password</label>

            <input type="password"
                   name="password"
                   placeholder="Enter your password"
                   required>

            <input type="submit" value="Create Account">

        </form>

        <div class="login-link">

            Already have an account?

            <a href="login.jsp">Login Here</a>

        </div>

    </div>

</div>

<footer>

    © 2026 Uni-Run Marathon & Virtual Run Coordinator

</footer>

</body>
</html>