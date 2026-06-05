<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if (!currentUser.isSuperAdmin()) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    List<User> userList =
        (List<User>) request.getAttribute("userList");
    if (userList == null) userList = new ArrayList<>();

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");

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
<title>User Management | ADAMS</title>
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
.main { flex:1; padding:25px; overflow-x:auto; }

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

/* ── CONTROLS ── */
.controls {
    display:flex; justify-content:space-between;
    align-items:center; margin-bottom:16px;
    flex-wrap:wrap; gap:12px;
}

/* ── BUTTONS ── */
.btn {
    padding:8px 14px; border:none; border-radius:4px;
    cursor:pointer; font-size:13px; text-decoration:none;
    display:inline-block; transition:background 0.2s;
}
.btn-primary   { background:#6d0f0f; color:#fff; }
.btn-primary:hover   { background:#5a0c0c; }
.btn-secondary { background:#6c757d; color:#fff; }
.btn-secondary:hover { background:#5a6268; }
.btn-success   { background:#2e7d32; color:#fff; }
.btn-success:hover   { background:#1b5e20; }
.btn-warning   { background:#f57c00; color:#fff; }
.btn-warning:hover   { background:#e65100; }
.btn-danger    { background:#c62828; color:#fff; }
.btn-danger:hover    { background:#b71c1c; }
.btn-sm { padding:5px 10px; font-size:12px; }

/* ── TABLE ── */
table {
    width:100%; background:#fff; border-collapse:collapse;
    border-radius:8px; overflow:hidden;
    box-shadow:0 2px 4px rgba(0,0,0,0.1); table-layout:fixed;
}
thead { background:#6d0f0f; color:#fff; }
thead th { padding:12px 14px; text-align:left; font-size:13px; }
tbody tr { border-bottom:1px solid #ddd; }
tbody tr:hover { background:#f9f9f9; }
tbody td { padding:11px 14px; font-size:13px; vertical-align:middle; }

/* ── ROLE BADGES ── */
.role-badge {
    padding:3px 10px; border-radius:12px;
    font-size:11px; font-weight:700; white-space:nowrap;
}
.role-superadmin { background:#4a148c; color:#fff; }
.role-admin      { background:#6d0f0f; color:#fff; }
.role-staff      { background:#1565c0; color:#fff; }
.role-student    { background:#2e7d32; color:#fff; }

/* ── ACTIVE BADGE ── */
.badge-active   { background:#e8f5e9; color:#2e7d32;
    padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
.badge-inactive { background:#ffecec; color:#c62828;
    padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }

/* ── ACTION CELL ── */
.action-cell { display:flex; gap:5px; flex-wrap:wrap; }

/* ── MODAL ── */
.modal {
    display:none; position:fixed; inset:0;
    background:rgba(0,0,0,0.55); justify-content:center;
    align-items:center; z-index:9999; padding:14px;
}
.modal.show { display:flex; }
.modal-content {
    background:#fff; width:min(500px,95vw);
    border-radius:8px; overflow:hidden;
    box-shadow:0 12px 40px rgba(0,0,0,0.35); margin:auto;
}
.modal-header {
    background:#6d0f0f; color:#fff; padding:14px 16px;
    display:flex; justify-content:space-between;
    align-items:center; font-weight:600;
}
.modal-body { padding:16px; }
.modal-body label {
    display:block; font-weight:600;
    margin-top:12px; margin-bottom:4px; font-size:13px;
}
.modal-body input,
.modal-body select {
    width:100%; padding:9px; border:1px solid #ccc;
    border-radius:4px; font-size:13px; font-family:inherit;
}
.modal-body input:focus,
.modal-body select:focus {
    outline:none; border-color:#6d0f0f;
    box-shadow:0 0 0 2px rgba(109,15,15,0.1);
}
.modal-actions {
    display:flex; justify-content:flex-end;
    gap:10px; margin-top:16px;
}
.close-x {
    background:transparent; border:none;
    color:#fff; font-size:20px; cursor:pointer;
}
.form-row {
    display:grid; grid-template-columns:1fr 1fr; gap:12px;
}
</style>
</head>
<body class="theme-<%= _theme %>">
<div class="container">

<!-- ── SIDEBAR ── -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ── MAIN ── -->
<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <div class="header">
        <h2>👤 User Management</h2>
        <div class="header-info">
            Logged in as <b><%= currentUser.getUsername() %></b><br>
            Role: <b>Super Admin</b>
        </div>
    </div>

    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="msg-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="msg-error">❌ <%= errorMsg %></div>
    <% } %>

    <div class="controls">
        <button class="btn btn-primary" type="button"
                onclick="openCreateModal()">
            ➕ Add New User
        </button>
    </div>

    <!-- TABLE -->
    <table>
        <colgroup>
            <col style="width:50px;">
            <col style="width:130px;">
            <col style="width:auto;">
            <col style="width:160px;">
            <col style="width:100px;">
            <col style="width:80px;">
            <col style="width:200px;">
        </colgroup>
        <thead>
            <tr>
                <th>#</th>
                <th>Username</th>
                <th>Full Name / Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Last Login</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <% if (userList.isEmpty()) { %>
            <tr>
                <td colspan="7" style="text-align:center;
                    color:#999; padding:30px;">
                    No users found.
                </td>
            </tr>
        <% } else {
               int rowNum = 1;
               for (User u : userList) {
                   String roleCss = "role-staff";
                   switch (u.getRole().toLowerCase()) {
                       case "superadmin" : roleCss = "role-superadmin"; break;
                       case "admin"      : roleCss = "role-admin";      break;
                       case "staff"      : roleCss = "role-staff";      break;
                       case "student"    : roleCss = "role-student";    break;
                   }
                   boolean isSelf =
                       u.getUserId() == currentUser.getUserId();
        %>
            <tr data-id="<%= u.getUserId() %>"
                data-username="<%= u.getUsername() %>"
                data-fullname="<%= u.getFullName() != null
                    ? u.getFullName().replace("\"","&quot;") : "" %>"
                data-email="<%= u.getEmail() != null
                    ? u.getEmail().replace("\"","&quot;") : "" %>"
                data-phone="<%= u.getPhone() != null
                    ? u.getPhone().replace("\"","&quot;") : "" %>"
                data-role="<%= u.getRole() %>"
                data-active="<%= u.isActive() ? "1" : "0" %>">

                <td><%= rowNum++ %></td>
                <td>
                    <b><%= u.getUsername() %></b>
                    <% if (isSelf) { %>
                        <span style="font-size:10px;
                            color:#6d0f0f;">(you)</span>
                    <% } %>
                </td>
                <td>
                    <%= (u.getFullName() != null &&
                        !u.getFullName().isEmpty())
                        ? u.getFullName() : "—" %><br>
                    <span style="font-size:12px; color:#888;">
                        <%= (u.getEmail() != null &&
                            !u.getEmail().isEmpty())
                            ? u.getEmail() : "—" %>
                    </span>
                </td>
                <td>
                    <span class="role-badge <%= roleCss %>">
                        <%= u.getRole() %>
                    </span>
                </td>
                <td>
                    <span class="<%= u.isActive()
                        ? "badge-active" : "badge-inactive" %>">
                        <%= u.isActive() ? "Active" : "Inactive" %>
                    </span>
                </td>
                <td style="font-size:11px; color:#666;">
                    <%= u.getLastLogin() != null
                        ? u.getLastLogin().toString().substring(0,16)
                        : "Never" %>
                </td>
                <td>
                    <div class="action-cell">
                        <!-- EDIT -->
                        <button class="btn btn-warning btn-sm"
                                type="button"
                                onclick="openEditModal(this)">
                            ✏️ Edit
                        </button>

                        <!-- TOGGLE ACTIVE — not self -->
                        <% if (!isSelf) { %>
                        <a class="btn btn-sm
                            <%= u.isActive()
                                ? "btn-secondary"
                                : "btn-success" %>"
                           href="<%= request.getContextPath()
                           %>/user-management?action=toggle&userId=<%= u.getUserId() %>"
                           onclick="return confirmSubmit(this, 
                               '<%= u.isActive()
                                   ? "Deactivate" : "Activate" %> user \'<%= u.getUsername() %>\'?');">
                            <%= u.isActive() ? "🔒 Deactivate" : "🔓 Activate" %>
                        </a>

                        <!-- DELETE -->
                        <a class="btn btn-danger btn-sm"
                           href="<%= request.getContextPath()
                           %>/user-management?action=delete&userId=<%= u.getUserId() %>"
                           onclick="return confirmSubmit(this, 
                               'Permanently delete user \'<%= u.getUsername() %>\'?\nThis cannot be undone.');">
                            🗑️
                        </a>
                        <% } %>
                    </div>
                </td>
            </tr>
        <% }
           } %>
        </tbody>
    </table>
</div>
</div>

<!-- ── CREATE MODAL ── -->

<div id="createModal" class="modal">
    <div class="modal-content">

        <div class="modal-header">
            <span>➕ Add New User</span>
            <button class="close-x"
                    onclick="closeModal('createModal')">×</button>
        </div>
        <div class="modal-body">
            <form method="post"
                  action="<%= request.getContextPath()
                             %>/user-management">
                <input type="hidden" name="action" value="create">

                <div class="form-row">
                    <div>
                        <label>Username *</label>
                        <input type="text" name="username"
                               required placeholder="e.g. jdoe">
                    </div>
                    <div>
                        <label>Password *</label>
                        <input type="password" name="password"
                               required placeholder="Min 6 chars">
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label>Full Name</label>
                        <input type="text" name="fullName"
                               placeholder="Juan Dela Cruz">
                    </div>
                    <div>
                        <label>Email</label>
                        <input type="email" name="email"
                               placeholder="email@example.com">
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label>Phone</label>
                        <input type="tel" name="phone"
                               placeholder="09XX-XXX-XXXX">
                    </div>
                    <div>
                        <label>Role *</label>
                        <select name="role" required>
                            <option value="">-- Select Role --</option>
                            <option value="superadmin">Super Admin</option>
                            <option value="admin">Admin</option>
                            <option value="staff">Staff</option>
                        </select>
                    </div>
                </div>

                <div class="modal-actions">
                    <button class="btn btn-secondary" type="button"
                            onclick="closeModal('createModal')">
                        Cancel
                    </button>
                    <button class="btn btn-primary" type="submit">
                        💾 Create User
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ── EDIT MODAL ── -->
<div id="editModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span>✏️ Edit User</span>
            <button class="close-x"
                    onclick="closeModal('editModal')">×</button>
        </div>
        <div class="modal-body">
            <form method="post"
                  action="<%= request.getContextPath()
                             %>/user-management">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="edit_userId">

                <div class="form-row">
                    <div>
                        <label>Username</label>
                        <input type="text" id="edit_username"
                               disabled style="background:#f5f5f5;">
                    </div>
                    <div>
                        <label>Role *</label>
                        <select name="role" id="edit_role" required>
                            <option value="superadmin">Super Admin</option>
                            <option value="admin">Admin</option>
                            <option value="staff">Staff</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label>Full Name</label>
                        <input type="text" name="fullName"
                               id="edit_fullName">
                    </div>
                    <div>
                        <label>Email</label>
                        <input type="email" name="email"
                               id="edit_email">
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label>Phone</label>
                        <input type="tel" name="phone"
                               id="edit_phone">
                    </div>
                    <div>
                        <label>Active Status</label>
                        <select name="isActive" id="edit_active">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="modal-actions">
                    <button class="btn btn-secondary" type="button"
                            onclick="closeModal('editModal')">
                        Cancel
                    </button>
                    <button class="btn btn-primary" type="submit">
                        ✔️ Update
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openModal(id)  {
    document.getElementById(id).classList.add('show');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('show');
}
function openCreateModal() { openModal('createModal'); }

function openEditModal(btn) {
    const tr = btn.closest('tr');
    document.getElementById('edit_userId').value    = tr.dataset.id;
    document.getElementById('edit_username').value  = tr.dataset.username;
    document.getElementById('edit_fullName').value  = tr.dataset.fullname;
    document.getElementById('edit_email').value     = tr.dataset.email;
    document.getElementById('edit_phone').value     = tr.dataset.phone;
    document.getElementById('edit_role').value      = tr.dataset.role;
    document.getElementById('edit_active').value    = tr.dataset.active;
    openModal('editModal');
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal.show')
                .forEach(m => m.classList.remove('show'));
    }
});
</script>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
