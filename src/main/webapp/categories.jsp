<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.StudentCategory, model.User" %>

<%
    // ===== AUTH =====
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isAdmin =
    "admin".equalsIgnoreCase(currentUser.getRole()) ||
    "superadmin".equalsIgnoreCase(currentUser.getRole());

    // ===== DATA =====
    List<StudentCategory> categoryList =
        (List<StudentCategory>) request.getAttribute("categoryList");
    if (categoryList == null) categoryList = new ArrayList<>();

    StudentCategory editCategory =
        (StudentCategory) request.getAttribute("editCategory");

    // ===== MESSAGES =====
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
<title>Categories | ADAMS</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family:'Segoe UI', Arial, sans-serif;
    background:#f4f4f4;
}

.container { display:flex; min-height:100vh; }

/* ── SIDEBAR ── */
.sidebar {
    width:240px;
    background:#6d0f0f;
    color:#fff;
    display:flex;
    flex-direction:column;
}
.sidebar h2 {
    margin:0;
    padding:20px;
    background:#5a0c0c;
    text-align:center;
    font-size:18px;
}
.sidebar a {
    display:block;
    padding:14px 20px;
    color:#fff;
    text-decoration:none;
    transition:background 0.2s;
    font-size:14px;
}
.sidebar a:hover  { background:#8b1a1a; }
.sidebar a.active { background:#8b1a1a; font-weight:600; }
.sidebar .logout  { margin-top:auto; background:#4a0a0a; }

/* ── MAIN ── */
.main { flex:1; padding:25px; }

/* ── HEADER ── */
.header {
    background:#fff;
    padding:16px 20px;
    border-radius:8px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:20px;
    box-shadow:0 2px 4px rgba(0,0,0,0.1);
}
.header h2 { margin:0; font-size:20px; }
.header-info { text-align:right; font-size:13px; }

/* ── MESSAGES ── */
.msg-success {
    background:#eaffea;
    border:1px solid #8bd88b;
    padding:12px 16px;
    border-radius:6px;
    margin-bottom:16px;
    color:#2d5016;
    font-size:13px;
}
.msg-error {
    background:#ffecec;
    border:1px solid #e9a3a3;
    padding:12px 16px;
    border-radius:6px;
    margin-bottom:16px;
    color:#7d2c2c;
    font-size:13px;
}

/* ── FORM BOX ── */
.form-box {
    background:#fff;
    padding:16px 20px;
    border-radius:8px;
    margin-bottom:20px;
    box-shadow:0 2px 4px rgba(0,0,0,0.1);
    display:flex;
    align-items:center;
    gap:10px;
    flex-wrap:wrap;
}
.form-box input[type="text"] {
    padding:9px 12px;
    border:1px solid #ccc;
    border-radius:4px;
    font-size:13px;
    width:260px;
}
.form-box input[type="text"]:focus {
    outline:none;
    border-color:#6d0f0f;
    box-shadow:0 0 0 2px rgba(109,15,15,0.1);
}

/* ── STAFF NOTICE ── */
.readonly-notice {
    background:#fff8e1;
    border:1px solid #ffe082;
    padding:10px 16px;
    border-radius:6px;
    margin-bottom:16px;
    color:#795548;
    font-size:13px;
}

/* ── BUTTONS ── */
.btn {
    padding:8px 14px;
    border:none;
    border-radius:4px;
    cursor:pointer;
    font-size:13px;
    text-decoration:none;
    display:inline-block;
    transition:background 0.2s;
}
.btn-save   { background:#2e7d32; color:#fff; }
.btn-save:hover   { background:#1b5e20; }
.btn-cancel { background:#6c757d; color:#fff; }
.btn-cancel:hover { background:#5a6268; }
.btn-edit   { background:#f57c00; color:#fff; }
.btn-edit:hover   { background:#e65100; }
.btn-delete { background:#c62828; color:#fff; }
.btn-delete:hover { background:#b71c1c; }

/* ── TABLE ── */
table {
    width:100%;
    background:#fff;
    border-collapse:collapse;
    border-radius:8px;
    overflow:hidden;
    box-shadow:0 2px 4px rgba(0,0,0,0.1);
    table-layout:fixed;
}
thead { background:#6d0f0f; color:#fff; }
thead th {
    padding:12px 16px;
    text-align:left;
    font-size:13px;
    font-weight:600;
}
tbody tr { border-bottom:1px solid #ddd; }
tbody tr:hover { background:#fdf5f5; }
tbody td {
    padding:12px 16px;
    font-size:13px;
    vertical-align:middle;
}
.action-cell {
    display:flex;
    gap:6px;
    align-items:center;
}
.empty-row td {
    text-align:center;
    color:#999;
    padding:30px;
}
</style>
</head>

<body class="theme-<%= _theme %>">
<div class="container">

<!-- ══════════════════════════
     SIDEBAR
══════════════════════════ -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ══════════════════════════
     MAIN
══════════════════════════ -->
<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <!-- HEADER -->  
        <div class="header-info">
            Logged in as <b><%= currentUser.getUsername() %></b><br>
            Role:
            <b>
                <%= currentUser.getRole() != null
                    ? currentUser.getRole().substring(0, 1).toUpperCase()
                    + currentUser.getRole().substring(1).toLowerCase()
                    : "Unknown" %>
            </b>
        </div>


    <!-- MESSAGES -->
    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div class="msg-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="msg-error">❌ <%= errorMsg %></div>
    <% } %>

    <!-- ══════════════════════════
         ADD / EDIT FORM — Admin only
    ══════════════════════════ -->
    <% if (isAdmin) { %>
    <div class="form-box">
        <form action="<%= request.getContextPath() %>/categories"
              method="post">

            <input type="hidden" name="action"
                   value="<%= (editCategory != null) ? "update" : "add" %>">

            <% if (editCategory != null) { %>
                <input type="hidden" name="id"
                       value="<%= editCategory.getCategoryId() %>">
            <% } %>

            <input type="text" name="name" required
                   placeholder="Category Name"
                   value="<%= (editCategory != null)
                              ? editCategory.getCategoryName() : "" %>">

            <button class="btn btn-save" type="submit">
                <%= (editCategory != null) ? "✔️ Update" : "➕ Add" %>
            </button>

            <% if (editCategory != null) { %>
                <a href="<%= request.getContextPath() %>/categories"
                   class="btn btn-cancel">Cancel</a>
            <% } %>

        </form>
    </div>

    <% } else { %>
        <!-- Staff read-only notice -->
        <div class="readonly-notice">
            ℹ️ You are viewing categories in <b>read-only</b> mode.
            Only admins can add, edit, or delete categories.
        </div>
    <% } %>

    <!-- ══════════════════════════
         TABLE
    ══════════════════════════ -->
    <table>
        <colgroup>
            <col style="width:60px;">
            <col style="width:auto;">
            <% if (isAdmin) { %>
            <col style="width:180px;">
            <% } %>
        </colgroup>
        <thead>
            <tr>
                <th>#</th>
                <th>Category Name</th>
                <% if (isAdmin) { %>
                <th>Actions</th>
                <% } %>
            </tr>
        </thead>
        <tbody>

        <% if (categoryList.isEmpty()) { %>
            <tr class="empty-row">
                <td colspan="<%= isAdmin ? 3 : 2 %>">
                    No categories found.
                </td>
            </tr>

        <% } else {
               int rowNum = 1;
               for (StudentCategory c : categoryList) { %>
            <tr>
                <!-- ROW NUMBER -->
                <td><%= rowNum++ %></td>

                <!-- CATEGORY NAME -->
                <td><%= c.getCategoryName() %></td>

                <!-- ACTIONS — Admin only -->
                <% if (isAdmin) { %>
                <td>
                    <div class="action-cell">

                        <!-- EDIT BUTTON -->
                        <form action="<%= request.getContextPath() %>/categories"
                              method="get"
                              style="display:inline;">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id"
                                   value="<%= c.getCategoryId() %>">
                            <button class="btn btn-edit" type="submit">
                                ✏️ Edit
                            </button>
                        </form>

                        <!-- DELETE BUTTON -->
                        <form action="<%= request.getContextPath() %>/categories"
                              method="post"
                              style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id"
                                   value="<%= c.getCategoryId() %>">
                            <button class="btn btn-delete"
                                    type="submit"
                                    onclick="return confirmSubmit(this, 
                                        'Delete \'<%= c.getCategoryName() %>\'?\nThis cannot be undone.');">
                                🗑️ Delete
                            </button>
                        </form>

                    </div>
                </td>
                <% } %>
            </tr>
        <% }
           } %>

        </tbody>
    </table>

</div><!-- end .main -->
</div><!-- end .container -->

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
