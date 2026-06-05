<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
     // If user is already logged in, redirect to dashboard
     if (session.getAttribute("user") != null) {
         response.sendRedirect(request.getContextPath() + "/dashboard");
         return;
     }

%>
<!DOCTYPE html>
<html>
<head>
   
    <link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />

    <meta charset="UTF-8">
    <title>Login - ADAMS - Automated Document Admission Management System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        font-family: 'Segoe UI', Tahoma, sans-serif;
        background: linear-gradient(135deg, #6d0f0f, #3d0707);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    /* ✅ NEW: Wrapper that holds both sections */
    .login-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 16px;
    }

    /* ✅ NEW: PUP Header (separate from login card) */
    .pup-header-box {
        background: white;
        width: 580px;
        padding: 20px 30px;
        border-radius: 10px 10px 0 0;
        box-shadow: 0 10px 25px rgba(0,0,0,0.25);
        text-align: center;
        border-bottom: 3px solid #6d0f0f;
    }

    .pup-logo-row {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 16px;
    }

    .pup-logo-row img {
        width: 75px;
        height: 75px;
        object-fit: contain;
    }

    .pup-text .republic {
        font-size: 10px;
        color: #888;
        letter-spacing: 1px;
        margin: 0;
    }

    .pup-text .university {
        font-size: 15px;
        color: #6d0f0f;
        font-weight: bold;
        letter-spacing: 0.5px;
        margin: 3px 0;
    }

    .pup-text .ous {
        font-size: 11px;
        color: #444;
        font-weight: bold;
        margin: 0;
    }

    .pup-text .iode {
        font-size: 10px;
        color: #555;
        margin: 2px 0 0 0;
    }

    /* ✅ UPDATED: Login card (same width, no top radius) */
    .login-container {
        background: white;
        width: 580px;
        padding: 35px 50px;
        border-radius: 0 0 10px 10px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.25);
    }

    .login-header {
        text-align: center;
        margin-bottom: 25px;
    }

    .login-header h1 {
        color: #6d0f0f;
        font-size: 28px;
        margin-bottom: 5px;
    }

    .login-header p {
        font-size: 13px;
        color: #777;
    }

    .form-group {
        margin-bottom: 18px;
    }

    .form-group label {
        display: block;
        margin-bottom: 6px;
        font-size: 14px;
        font-weight: 600;
        color: #333;
    }

    .form-group input {
        width: 100%;
        padding: 12px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
    }

    .form-group input:focus {
        outline: none;
        border-color: #6d0f0f;
        box-shadow: 0 0 0 2px rgba(109, 15, 15, 0.15);
    }

    .btn-login {
        width: 100%;
        padding: 12px;
        background: #6d0f0f;
        border: none;
        border-radius: 6px;
        color: white;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.3s;
    }

    .btn-login:hover {
        background: #8b1a1a;
    }

    .error-msg {
        background: #fdecea;
        border-left: 5px solid #c62828;
        color: #c62828;
        padding: 10px;
        margin-bottom: 15px;
        font-size: 13px;
    }

    .footer {
        margin-top: 20px;
        text-align: center;
        font-size: 12px;
        color: #777;
    }
</style>
</head>

<body>

<div class="login-wrapper">

    <%-- ══ SECTION 1: PUP HEADER (separate box) ══ --%>
    <div class="pup-header-box">
        <div class="pup-logo-row">

            <%-- LEFT: PUP Main Seal --%>
            
    <img src="<%= request.getContextPath() %>/assets/pup-logo.png"
                 alt="PUP Seal"
                 style="width: 75px; height: 75px; object-fit: contain;" />


            <%-- CENTER: Official Text --%>
            <div class="pup-text">
                <p class="republic">REPUBLIC OF THE PHILIPPINES</p>
                <p class="university">
                    POLYTECHNIC UNIVERSITY OF THE PHILIPPINES
                </p>
                <p class="ous">OPEN UNIVERSITY SYSTEM</p>
                <p class="iode">
                    INSTITUTE OF OPEN AND DISTANCE EDUCATION
                </p>
            </div>

            <%-- RIGHT: PUP Open University Seal --%>
            
    <img src="<%= request.getContextPath() %>/assets/pup-ou-logo.png"
                 alt="PUP OU Seal"
                 style="width: 75px; height: 75px; object-fit: contain;" />


        </div>
    </div>

    <%-- ══ SECTION 2: LOGIN FORM (separate box) ══ --%>
    <div class="login-container">

        <div class="login-header">
            <h1>ADAMS</h1>
            <p>Automated Document Admission Management System (ADAMS)</p>
        </div>

        <%-- Error message --%>
        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
        <div class="error-msg">
            ❌ <%= error %>
        </div>
        <% } %>

        <%-- Login Form --%>
        <form action="<%= request.getContextPath() %>/login" method="POST">

            <div class="form-group">
                <label>👤 Username</label>
                <input type="text" name="username" required />
            </div>

            <div class="form-group">
                <label>🔒 Password</label>
                <input type="password" name="password" required />
            </div>

            <button type="submit" class="btn-login">
                ➡️ Login
            </button>
        </form>

        <%-- Forgot Password --%>
        <div style="text-align:center; margin-top:14px;">
            <form action="<%= request.getContextPath() %>/forgot-password" method="GET">
                <button type="submit" style="background:none; border:none; color:#6d0f0f; font-size:13px; text-decoration:underline; cursor:pointer;">
                    🔑 Forgot Password?
                </button>
            </form>
        </div>

        <%-- Footer --%>
        <div class="footer">
            © 2026 VANDAM | PUPOUS-BSITOUMN 2-3
        </div>

    </div>

</div>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
