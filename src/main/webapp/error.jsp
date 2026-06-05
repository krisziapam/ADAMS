<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error - ADAMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .error-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            text-align: center;
        }
        .error-icon {
            font-size: 64px;
            color: #f44336;
            margin-bottom: 20px;
        }
        h1 { color: #333; margin-bottom: 10px; }
        p { color: #666; margin-bottom: 20px; }
        a { color: #667eea; text-decoration: none; font-weight: 600; }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h1>Oops! Page Not Found</h1>
        <p>The page you're looking for doesn't exist.</p>
        <a href="<%= request.getContextPath() %>/login.jsp">← Back to Login</a>
    </div>
</body>
</html>
