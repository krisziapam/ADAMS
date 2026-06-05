<%@ page contentType="text/html;
    charset=UTF-8" pageEncoding="UTF-8" %>

<%-- ✅ FIX #1: Declare the token variable! --%>
<%
    String token = (String) request.getAttribute("token");
    if (token == null) {
        token = request.getParameter("token");
    }
%>

<!DOCTYPE html>
<html>
<head>
<link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
    <meta charset="UTF-8">
    <title>Reset Password — ADAMS</title>
    <meta name="viewport"
          content="width=device-width,
          initial-scale=1.0">
    <style>
        * { box-sizing:border-box;
            margin:0; padding:0; }
        body {
            font-family:'Segoe UI',
                Tahoma, sans-serif;
            background:#f4f4f4;
            display:flex;
            justify-content:center;
            align-items:center;
            min-height:100vh;
        }
        .card {
            background:#fff;
            border-radius:8px;
            padding:40px;
            width:420px;
            box-shadow:0 4px 16px
                rgba(0,0,0,0.1);
        }
        .header {
            text-align:center;
            margin-bottom:28px;
        }
        .header h2 {
            color:#6d0f0f;
            font-size:22px;
        }
        .header p {
            color:#777;
            font-size:13px;
            margin-top:8px;
        }
        .form-group {
            margin-bottom:18px;
        }
        label {
            display:block;
            font-size:13px;
            font-weight:bold;
            color:#333;
            margin-bottom:6px;
        }
        input[type=password] {
            width:100%;
            padding:10px 12px;
            border:1px solid #ccc;
            border-radius:4px;
            font-size:13px;
        }
        .btn-submit {
            width:100%;
            padding:12px;
            background:#6d0f0f;
            color:#fff;
            border:none;
            border-radius:4px;
            font-size:14px;
            font-weight:bold;
            cursor:pointer;
        }
        .btn-submit:hover {
            background:#5a0c0c;
        }
        .alert-error {
            background:#ffebee;
            border:1px solid #c62828;
            color:#c62828;
            padding:10px 14px;
            border-radius:4px;
            font-size:13px;
            margin-bottom:16px;
        }
        .strength-bar {
            height:6px;
            border-radius:3px;
            background:#eee;
            margin-top:6px;
        }
        .strength-fill {
            height:100%;
            border-radius:3px;
            transition:width 0.3s,
                background 0.3s;
        }
    </style>
</head>
<body>
<div class="card">

    <div class="header">
        <h2>🔑 Reset Password</h2>
        <p>Enter your new password below.</p>
    </div>

    <%-- ERROR --%>
    <% String error = (String)
        request.getAttribute("error");
       if (error != null) { %>
    <div class="alert-error">
        ❌ <%= error %>
    </div>
    <% } %>

    <%-- ✅ FIX #2: Proper form tag --%>
    <form action="<%= request.getContextPath() %>/reset-password"
          method="POST">

        <%-- ✅ FIX #3: Token is now a declared variable --%>
        <input type="hidden" name="token"
               value="<%= token %>" />

        <%-- New Password --%>
        <div class="form-group">
            <label>New Password</label>
            <input type="password"
                   name="newPassword"
                   id="newPassword"
                   oninput="checkStrength(this.value)"
                   required />
            <%-- ✅ FIX #4: Strength bar was missing from HTML --%>
            <div class="strength-bar">
                <div class="strength-fill"
                     id="strengthFill"></div>
            </div>
        </div>

        <%-- Confirm Password --%>
        <div class="form-group">
            <label>Confirm Password</label>
            <input type="password"
                   name="confirmPassword"
                   required />
        </div>

        <%-- ✅ FIX #5: Use YOUR existing CSS class --%>
        <button type="submit" class="btn-submit">
            ✅ Reset Password
        </button>

    </form>

</div>

<script>
function checkStrength(val) {
    var fill =
        document.getElementById('strengthFill');
    var len = val.length;
    if (len < 6) {
        fill.style.width = '25%';
        fill.style.background = '#c62828';
    } else if (len < 10) {
        fill.style.width = '60%';
        fill.style.background = '#f57c00';
    } else {
        fill.style.width = '100%';
        fill.style.background = '#2e7d32';
    }
}
</script>
<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
