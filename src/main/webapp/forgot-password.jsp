<%@ page contentType="text/html;
    charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
<link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
    <meta charset="UTF-8">
    <title>Forgot Password — ADAMS</title>
    <meta name="viewport"
          content="width=device-width,
          initial-scale=1.0">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI',
                Tahoma, sans-serif;
            /* ✅ Maroon background
               matches your login page */
            background: #6d0f0f;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .card {
            background: #fff;
            border-radius: 8px;
            padding: 40px;
            width: 420px;
            box-shadow: 0 8px 32px
                rgba(0, 0, 0, 0.3);
        }

        .header {
            text-align: center;
            margin-bottom: 28px;
        }

        .header .icon {
            font-size: 40px;
            margin-bottom: 10px;
        }

        .header h2 {
            color: #6d0f0f;
            font-size: 22px;
            margin-bottom: 8px;
        }

        .header p {
            color: #777;
            font-size: 13px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: bold;
            color: #333;
            margin-bottom: 6px;
        }

        input[type=email] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 13px;
            transition: border 0.2s;
        }

        input[type=email]:focus {
            outline: none;
            border-color: #6d0f0f;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background: #6d0f0f;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-submit:hover {
            background: #5a0c0c;
        }

        .back-link {
            text-align: center;
            margin-top: 16px;
            font-size: 13px;
        }

        .back-link a {
            color: #6d0f0f;
            text-decoration: none;
            font-weight: bold;
        }

        .back-link a:hover {
            text-decoration: underline;
        }

        .alert-success {
            background: #e8f5e9;
            border: 1px solid #2e7d32;
            color: #2e7d32;
            padding: 10px 14px;
            border-radius: 4px;
            font-size: 13px;
            margin-bottom: 16px;
            text-align: center;
        }

        .alert-error {
            background: #ffebee;
            border: 1px solid #c62828;
            color: #c62828;
            padding: 10px 14px;
            border-radius: 4px;
            font-size: 13px;
            margin-bottom: 16px;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="card">

    <%-- HEADER --%>
    <div class="header">
        <div class="icon">🔑</div>
        <h2>Forgot Password</h2>
        <p>Enter your email and we'll
        send you a reset link.</p>
    </div>

    <%-- SUCCESS MESSAGE --%>
    <%
        String success = (String)
            request.getAttribute("success");
        String error = (String)
            request.getAttribute("error");
    %>

    <% if (success != null) { %>
    <div class="alert-success">
        ✅ <%= success %>
    </div>
    <% } %>

    <%-- ERROR MESSAGE --%>
    <% if (error != null) { %>
    <div class="alert-error">
        ❌ <%= error %>
    </div>
    <% } %>

    <%-- FORM — only show if no success --%>
    <% if (success == null) { %>
    <form method="POST"
          action="<%= request.getContextPath()
              %>/forgot-password">

        <div class="form-group">
            <label for="email">
                Email Address
            </label>
            <input type="email"
                   id="email"
                   name="email"
                   placeholder="your@email.com"
                   required
                   autofocus>
        </div>

        <button type="submit"
                class="btn-submit">
            📧 Send Reset Link
        </button>

    </form>
    <% } %>

    <%-- BACK TO LOGIN --%>
    <div class="back-link">
        <a href="<%= request.getContextPath()
            %>/login.jsp">
            ← Back to Login
        </a>
    </div>

</div>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
