<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.RequirementType, model.User" %>

<%!
    // ── Safe JS string escaping ──
    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("'",  "\\'")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
    // ── Safe HTML escaping ──
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&",  "&amp;")
                .replace("<",  "&lt;")
                .replace(">",  "&gt;")
                .replace("\"", "&quot;");
    }
%>

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
    List<RequirementType> requirementList =
        (List<RequirementType>) request.getAttribute("requirementList");
    if (requirementList == null) requirementList = new ArrayList<>();

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
<title>Requirements | ADAMS</title>
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
.main { flex:1; padding:25px; overflow-x:auto; }

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

/* ── CONTROLS ── */
.controls {
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:16px;
    flex-wrap:wrap;
    gap:12px;
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
.btn-primary { background:#6d0f0f; color:#fff; }
.btn-primary:hover { background:#5a0c0c; }
.btn-success { background:#2e7d32; color:#fff; }
.btn-success:hover { background:#1b5e20; }
.btn-edit    { background:#f57c00; color:#fff; }
.btn-edit:hover    { background:#e65100; }
.btn-delete  { background:#c62828; color:#fff; }
.btn-delete:hover  { background:#b71c1c; }
.btn-secondary { background:#6c757d; color:#fff; }
.btn-secondary:hover { background:#5a6268; }

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
tbody tr:hover { background:#f9f9f9; }
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
.action-cell .btn {
    padding:5px 10px;
    font-size:12px;
}
.empty-row td {
    text-align:center;
    color:#999;
    padding:30px;
}

/* ── MODAL ── */
.modal {
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.55);
    justify-content:center;
    align-items:center;
    z-index:9999;
    padding:14px;
}
.modal.show { display:flex; }

.modal-content {
    background:#fff;
    width:min(460px, 95vw);
    border-radius:8px;
    overflow:hidden;
    box-shadow:0 12px 40px rgba(0,0,0,0.35);
    margin:auto;
}
.modal-header {
    background:#6d0f0f;
    color:#fff;
    padding:14px 16px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    font-weight:600;
    font-size:14px;
}
.modal-body { padding:16px; }
.modal-body label {
    display:block;
    font-weight:600;
    margin-top:12px;
    margin-bottom:4px;
    font-size:13px;
}
.modal-body input[type="text"],
.modal-body textarea {
    width:100%;
    padding:9px;
    border:1px solid #ccc;
    border-radius:4px;
    font-size:13px;
    font-family:inherit;
}
.modal-body textarea {
    resize:vertical;
    min-height:90px;
}
.modal-body input:focus,
.modal-body textarea:focus {
    outline:none;
    border-color:#6d0f0f;
    box-shadow:0 0 0 2px rgba(109,15,15,0.1);
}
.modal-actions {
    display:flex;
    justify-content:flex-end;
    gap:10px;
    margin-top:16px;
}
.close-x {
    background:transparent;
    border:none;
    color:#fff;
    font-size:20px;
    cursor:pointer;
    line-height:1;
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

    <!-- STAFF NOTICE -->
    <% if (!isAdmin) { %>
        <div class="readonly-notice">
            ℹ️ You are viewing requirements in <b>read-only</b> mode.
            Only admins can add, edit, or delete requirements.
        </div>
    <% } %>

    <!-- CONTROLS — Admin only -->
    <% if (isAdmin) { %>
    <div class="controls">
        <button class="btn btn-primary" type="button"
                onclick="openModal()">
            ➕ Add Requirement
        </button>
    </div>
    <% } %>

    <!-- ══════════════════════════
         TABLE
    ══════════════════════════ -->
    <table>
        <colgroup>
            <col style="width:55px;">
            <col style="width:30%;">
            <col style="width:auto;">
            <% if (isAdmin) { %>
            <col style="width:180px;">
            <% } %>
        </colgroup>
        <thead>
            <tr>
                <th>#</th>
                <th>Requirement Name</th>
                <th>Description</th>
                <% if (isAdmin) { %>
                <th>Actions</th>
                <% } %>
            </tr>
        </thead>
        <tbody>

        <% if (requirementList.isEmpty()) { %>
            <tr class="empty-row">
                <td colspan="<%= isAdmin ? 4 : 3 %>">
                    No requirements found.
                </td>
            </tr>

        <% } else {
               int rowNum = 1;
               for (RequirementType r : requirementList) {
                   String reqDesc = r.getDescription() != null
                                    ? r.getDescription() : "";
        %>
            <tr>
                <!-- ROW NUMBER -->
                <td><%= rowNum++ %></td>

                <!-- REQUIREMENT NAME -->
                <td><%= escapeHtml(r.getRequirementName()) %></td>

                <!-- DESCRIPTION -->
                <td><%= escapeHtml(reqDesc) %></td>

                <!-- ACTIONS — Admin only -->
                <% if (isAdmin) { %>
                <td>
                    <div class="action-cell">

                        <!-- EDIT -->
                        <button class="btn btn-edit" type="button"
                                onclick="openModal(
                                    '<%= r.getRequirementId() %>',
                                    '<%= escapeJs(r.getRequirementName()) %>',
                                    '<%= escapeJs(reqDesc) %>'
                                )">
                            ✏️ Edit
                        </button>

                        <!-- DELETE -->
                        <form action="<%= request.getContextPath() %>/requirements"
                              method="post"
                              style="display:inline;"
                              onsubmit="return confirmSubmit(this, 
                                  'Delete \'<%= escapeJs(r.getRequirementName()) %>\'?\nThis cannot be undone.');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id"
                                   value="<%= r.getRequirementId() %>">
                            <button class="btn btn-delete" type="submit">
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


<!-- ══════════════════════════
     ADD / EDIT MODAL
══════════════════════════ -->
<div id="reqModal" class="modal"
     onclick="if(event.target===this) closeModal()">
    <div class="modal-content" onclick="event.stopPropagation()">

        <div class="modal-header">
            <span id="modalTitle">Add Requirement</span>
            <button class="close-x" type="button"
                    onclick="closeModal()">×</button>
        </div>

        <div class="modal-body">
            <form action="<%= request.getContextPath() %>/requirements"
                  method="post">

                <input type="hidden" name="action" id="formAction">
                <input type="hidden" name="id"     id="formId">

                <label for="formName">Requirement Name *</label>
                <input type="text" id="formName" name="name"
                       required placeholder="e.g. Birth Certificate">

                <label for="formDesc">Description</label>
                <textarea id="formDesc" name="description"
                          placeholder="e.g. Original copy required"></textarea>

                <div class="modal-actions">
                    <button class="btn btn-secondary" type="button"
                            onclick="closeModal()">Cancel</button>
                    <button class="btn btn-success" type="submit"
                            id="submitBtn">💾 Save</button>
                </div>

            </form>
        </div>
    </div>
</div>


<script>
// ── OPEN MODAL ──
function openModal(id, name, desc) {
    const isEdit = (id !== undefined && id !== '');

    document.getElementById('modalTitle').textContent =
        isEdit ? '✏️ Edit Requirement' : '➕ Add Requirement';

    document.getElementById('formAction').value =
        isEdit ? 'update' : 'add';

    document.getElementById('formId').value   = id   || '';
    document.getElementById('formName').value = name || '';
    document.getElementById('formDesc').value = desc || '';

    document.getElementById('submitBtn').textContent =
        isEdit ? '✔️ Update' : '💾 Save';

    document.getElementById('reqModal').classList.add('show');
}

// ── CLOSE MODAL ──
function closeModal() {
    document.getElementById('reqModal').classList.remove('show');

    // Clear fields
    document.getElementById('formId').value   = '';
    document.getElementById('formName').value = '';
    document.getElementById('formDesc').value = '';
}

// ── ESC KEY CLOSES MODAL ──
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal();
});
</script>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
