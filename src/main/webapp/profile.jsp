<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    User profileUser = (User) request.getAttribute("profileUser");
    if (profileUser == null) profileUser = currentUser;

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");

    boolean isAdmin = currentUser.isAdminOrAbove();

    String _theme =
        (String) session.getAttribute("theme");
    if (_theme == null) _theme = "normal";
%>

<!DOCTYPE html>
<html>
<head>
<link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
<link rel="stylesheet"
      href="<%= request.getContextPath()
      %>/css/themes.css">
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | ADAMS</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family:'Segoe UI',Arial,sans-serif; background:#f4f4f4; }
.container { display:flex; min-height:100vh; }

/* ── SIDEBAR ── */
.sidebar {
    width:240px; background:#6d0f0f;
    color:#fff; display:flex; flex-direction:column;
}
.sidebar h2 {
    margin:0; padding:20px; background:#5a0c0c;
    text-align:center; font-size:18px;
}
.sidebar a {
    display:block; padding:14px 20px; color:#fff;
    text-decoration:none; transition:background 0.2s; font-size:14px;
}
.sidebar a:hover  { background:#8b1a1a; }
.sidebar a.active { background:#8b1a1a; font-weight:600; }
.sidebar .logout  { margin-top:auto; background:#4a0a0a; }

/* ── MAIN ── */
.main { flex:1; padding:25px; max-width:800px; }

.header {
    background:#fff; padding:16px 20px; border-radius:8px;
    display:flex; justify-content:space-between; align-items:center;
    margin-bottom:20px; box-shadow:0 2px 4px rgba(0,0,0,0.1);
}
.header h2 { margin:0; }
.header-info { text-align:right; font-size:13px; }

/* ── MESSAGES ── */
.msg-success {
    background:#eaffea; border:1px solid #8bd88b;
    padding:12px 16px; border-radius:6px;
    margin-bottom:16px; color:#2d5016; font-size:13px;
}
.msg-error {
    background:#ffecec; border:1px solid #e9a3a3;
    padding:12px 16px; border-radius:6px;
    margin-bottom:16px; color:#7d2c2c; font-size:13px;
}

/* ── PROFILE CARD ── */
.profile-card {
    background:#fff; border-radius:8px;
    box-shadow:0 2px 6px rgba(0,0,0,0.1);
    overflow:hidden; margin-bottom:20px;
}
.profile-card-header {
    background:#6d0f0f; color:#fff;
    padding:14px 18px; font-weight:600; font-size:14px;
    display:flex; align-items:center; gap:10px;
}
.profile-card-body { padding:20px; }

/* ── AVATAR ── */
.avatar-circle {
    width:72px; height:72px; border-radius:50%;
    background:#5a0c0c; color:#fff;
    display:flex; align-items:center; justify-content:center;
    font-size:28px; font-weight:700;
    margin:0 auto 16px auto;
    border:3px solid #6d0f0f;
}

.profile-username {
    text-align:center; font-size:18px;
    font-weight:700; color:#333; margin-bottom:4px;
}
.profile-role {
    text-align:center; margin-bottom:16px;
}

/* ── ROLE BADGE ── */
.role-badge {
    padding:4px 14px; border-radius:12px;
    font-size:12px; font-weight:700;
}
.role-superadmin { background:#4a148c; color:#fff; }
.role-admin      { background:#6d0f0f; color:#fff; }
.role-staff      { background:#1565c0; color:#fff; }
.role-student    { background:#2e7d32; color:#fff; }

/* ── FORM ── */
.form-group { margin-bottom:14px; }
.form-group label {
    display:block; font-weight:600;
    margin-bottom:4px; font-size:13px; color:#333;
}
.form-group input {
    width:100%; padding:9px 12px;
    border:1px solid #ccc; border-radius:4px;
    font-size:13px; font-family:inherit;
}
.form-group input:focus {
    outline:none; border-color:#6d0f0f;
    box-shadow:0 0 0 2px rgba(109,15,15,0.1);
}
.form-group input[disabled] {
    background:#f5f5f5; color:#888; cursor:not-allowed;
}
.form-row {
    display:grid; grid-template-columns:1fr 1fr; gap:16px;
}
.form-actions {
    display:flex; justify-content:flex-end;
    gap:10px; margin-top:18px;
}

/* ── META INFO ── */
.meta-info {
    display:flex; gap:20px; flex-wrap:wrap;
    padding:12px 0; border-top:1px solid #f0f0f0;
    margin-top:16px;
}
.meta-item {
    display:flex; flex-direction:column; font-size:12px;
}
.meta-item .meta-label {
    color:#999; font-size:11px;
    text-transform:uppercase; margin-bottom:2px;
}
.meta-item .meta-value { color:#444; font-weight:600; }

/* ── BUTTONS ── */
.btn {
    padding:9px 18px; border:none; border-radius:4px;
    cursor:pointer; font-size:13px; text-decoration:none;
    display:inline-block; transition:background 0.2s;
}
.btn-primary   { background:#6d0f0f; color:#fff; }
.btn-primary:hover   { background:#5a0c0c; }
.btn-secondary { background:#6c757d; color:#fff; }
.btn-secondary:hover { background:#5a6268; }
</style>
</head>
<body class="theme-<%= _theme %>">
<div class="container">

<!-- ── SIDEBAR ── -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ── MAIN ── */-->
<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <div class="header">
        <h2>⚙️ My Profile</h2>
        <div class="header-info">
            Logged in as <b><%= currentUser.getUsername() %></b><br>
            Role: <%= currentUser.getRole() %>
        </div>
    </div>

    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="msg-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="msg-error">❌ <%= errorMsg %></div>
    <% } %>

    <!-- ── PROFILE OVERVIEW CARD ── -->
    <div class="profile-card">
        <div class="profile-card-header">👤 Profile Overview</div>
        <div class="profile-card-body">

            <!-- AVATAR -->
            <div class="avatar-circle">
                <%= profileUser.getUsername()
                               .substring(0,1)
                               .toUpperCase() %>
            </div>

            <div class="profile-username">
                <%= profileUser.getUsername() %>
            </div>
            <div class="profile-role">
                <%
                    String roleCss = "role-staff";
                    switch (profileUser.getRole().toLowerCase()) {
                        case "superadmin": roleCss = "role-superadmin"; break;
                        case "admin":      roleCss = "role-admin";      break;
                        case "staff":      roleCss = "role-staff";      break;
                        case "student":    roleCss = "role-student";    break;
                    }
                %>
                <span class="role-badge <%= roleCss %>">
                    <%= profileUser.getRole() %>
                </span>
            </div>

            <!-- META INFO -->
            <div class="meta-info">
                <div class="meta-item">
                    <span class="meta-label">Member Since</span>
                    <span class="meta-value">
                        <%= profileUser.getCreatedAt() != null
                            ? profileUser.getCreatedAt()
                                         .toString().substring(0,10)
                            : "—" %>
                    </span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Last Login</span>
                    <span class="meta-value">
                        <%= profileUser.getLastLogin() != null
                            ? profileUser.getLastLogin()
                                         .toString().substring(0,16)
                            : "Never" %>
                    </span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Status</span>
                    <span class="meta-value"
                          style="color:<%= profileUser.isActive()
                              ? "#2e7d32" : "#c62828" %>;">
                        <%= profileUser.isActive()
                            ? "Active" : "Inactive" %>
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- ── EDIT PROFILE CARD ── -->
    <div class="profile-card">
        <div class="profile-card-header">✏️ Edit Profile Info</div>
        <div class="profile-card-body">
            <form method="post"
                  action="<%= request.getContextPath() %>/profile">
                <input type="hidden" name="action"
                       value="updateProfile">

                <div class="form-group">
                    <label>Username (cannot be changed)</label>
                    <input type="text"
                           value="<%= profileUser.getUsername() %>"
                           disabled>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="fullName"
                               value="<%= profileUser.getFullName() != null
                                   ? profileUser.getFullName() : "" %>"
                               placeholder="Juan Dela Cruz">
                    </div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email"
                               value="<%= profileUser.getEmail() != null
                                   ? profileUser.getEmail() : "" %>"
                               placeholder="email@example.com">
                    </div>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input type="tel" name="phone"
                           value="<%= profileUser.getPhone() != null
                               ? profileUser.getPhone() : "" %>"
                           placeholder="09XX-XXX-XXXX">
                </div>

                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">
                        💾 Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ── CHANGE PASSWORD CARD ── -->
    <div class="profile-card">
        <div class="profile-card-header">🔒 Change Password</div>
        <div class="profile-card-body">
            <form method="post"
                  action="<%= request.getContextPath() %>/profile">
                <input type="hidden" name="action"
                       value="changePassword">

                <div class="form-group">
                    <label>Current Password *</label>
                    <input type="password" name="oldPassword"
                           required placeholder="Enter current password">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>New Password *</label>
                        <input type="password" name="newPassword"
                               required placeholder="Min 6 characters"
                               id="newPass">
                    </div>
                    <div class="form-group">
                        <label>Confirm New Password *</label>
                        <input type="password"
                               name="confirmPassword"
                               required
                               placeholder="Repeat new password"
                               id="confirmPass">
                    </div>
                </div>

                <div class="form-actions">
                    <button class="btn btn-primary" type="submit"
                            onclick="return validatePasswords()">
                        🔒 Change Password
                    </button>
                </div>
            </form>
        </div>
    </div>

</div><!-- end .main -->
</div><!-- end .container -->

<script>
function validatePasswords() {
    const np = document.getElementById('newPass').value;
    const cp = document.getElementById('confirmPass').value;

    if (np.length < 6) {
        alert('❌ Password must be at least 6 characters.');
        return false;
    }
    if (np !== cp) {
        alert('❌ New passwords do not match.');
        return false;
    }
    return true;
}
</script>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
