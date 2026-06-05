<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Student, model.StudentCategory, model.User" %>

<%
    // ===== AUTH =====
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    boolean isAdmin = "admin".equalsIgnoreCase(currentUser.getRole());

    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    if (studentList == null) studentList = new ArrayList<>();

    Map<Integer, Integer> uploadedCountMap =
        (Map<Integer, Integer>) request.getAttribute("uploadedCountMap");
    if (uploadedCountMap == null) uploadedCountMap = new HashMap<>();

    Integer totalRequirements = (Integer) request.getAttribute("totalRequirements");
    if (totalRequirements == null) totalRequirements = 0;

    Integer selectedStudentId = (Integer) session.getAttribute("selectedStudentId");

    // ===== CATEGORY DATA =====
    List<StudentCategory> categoryList = (List<StudentCategory>) request.getAttribute("categoryList");
    Map<Integer, String> categoryMap = new HashMap<>();
    if (categoryList != null) {
        for (StudentCategory c : categoryList) {
            categoryMap.put(c.getCategoryId(), c.getCategoryName());
        }
    }

    // ===== PAGINATION =====
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = 1;

    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (totalPages == null) totalPages = 1;

    Integer pageSize = (Integer) request.getAttribute("pageSize");
    if (pageSize == null) pageSize = 10;

    String sort = (String) request.getAttribute("sort");
    if (sort == null) sort = "student_id";
    String dir = (String) request.getAttribute("dir");
    if (dir == null) dir = "asc";
    String nextDir = "asc".equals(dir) ? "desc" : "asc";
    String sortParam = "&sort=" + sort + "&dir=" + dir;

    Integer startRow = (Integer) request.getAttribute("startRow");
    if (startRow == null) startRow = 0;

    Integer endRow = (Integer) request.getAttribute("endRow");
    if (endRow == null) endRow = 0;

    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    if (totalStudents == null) totalStudents = 0;

    // ===== SEARCH / FILTER PARAMS =====
    String searchParam = request.getParameter("search") != null ? request.getParameter("search") : "";
    String catParam    = request.getParameter("categoryId") != null ? request.getParameter("categoryId") : "";

    // Safe escaped versions for HTML output
    String searchParamEsc = searchParam.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");
    String catParamEsc    = catParam.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");

    // Extra params string to preserve search/filter across pagination
    String extraParams = sortParam;
    if (!searchParam.isEmpty()) extraParams += "&search=" + java.net.URLEncoder.encode(searchParam, "UTF-8");
    if (!catParam.isEmpty())    extraParams += "&categoryId=" + java.net.URLEncoder.encode(catParam, "UTF-8");

    boolean showClear = !searchParam.trim().isEmpty() || !catParam.trim().isEmpty();

    // ===== MESSAGES =====
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

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
<title>Students | ADAMS</title>

<style>
* { margin:0; padding:0; box-sizing:border-box; }

body { font-family:'Segoe UI', Arial, sans-serif; background:#f4f4f4; }
.container { display:flex; min-height:100vh; }

/* ── SIDEBAR ── */
.sidebar { width:240px; background:#6d0f0f; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { margin:0; padding:20px; background:#5a0c0c; text-align:center; font-size:18px; }
.sidebar a {
    display:block;
    padding:14px 20px;
    color:#fff;
    text-decoration:none;
    transition:background 0.2s;
}
.sidebar a:hover  { background:#8b1a1a; }
.sidebar a.active { background:#8b1a1a; font-weight:600; }
.sidebar .logout  { margin-top:auto; background:#4a0a0a; }

/* ── MAIN ── */
.main { flex:1; padding:25px; overflow-x:auto; }

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
.header h2 { margin:0; }
.header-info { text-align:right; font-size:13px; }

/* ── BUTTONS ── */
.btn {
    padding:8px 14px;
    border:none;
    border-radius:4px;
    cursor:pointer;
    font-size:13px;
    text-decoration:none;
    transition:background 0.2s;
    display:inline-block;
}
.btn-primary   { background:#6d0f0f; color:#fff; }
.btn-primary:hover:not(:disabled)   { background:#5a0c0c; }
.btn-secondary { background:#6c757d; color:#fff; }
.btn-secondary:hover:not(:disabled) { background:#5a6268; }
.btn-success   { background:#2e7d32; color:#fff; }
.btn-success:hover:not(:disabled)   { background:#1b5e20; }
.btn-danger    { background:#c62828; color:#fff; }
.btn-danger:hover:not(:disabled)    { background:#b71c1c; }
.btn:disabled  { opacity:0.6; cursor:not-allowed; }

/* ── TABLE ── */
table {
    width:100%;
    background:#fff;
    border-collapse:collapse;
    border-radius:8px;
    overflow:hidden;
    box-shadow:0 2px 4px rgba(0,0,0,0.1);
}
th, td { padding:12px; border-bottom:1px solid #ddd; text-align:left; font-size:13px; }
th.sortable { cursor:pointer; user-select:none; white-space:nowrap; transition:background 0.15s; }
th.sortable:hover { background:#f0e6e6; }
th .sort-arrow { font-size:10px; margin-left:4px; opacity:0.3; }
th .sort-arrow.active { opacity:1; color:#6d0f0f; font-weight:bold; }
th { background:#f5f5f5; font-weight:600; }
tr:hover { background:#f9f9f9; }

/* ── CONTROLS ── */
.controls {
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:12px;
    flex-wrap:wrap;
    gap:12px;
}

.page-size-form {
    display:flex;
    align-items:center;
    gap:8px;
    font-size:13px;
}
.page-size-form select {
    padding:6px 10px;
    border:1px solid #ccc;
    border-radius:4px;
    cursor:pointer;
}

/* ── SEARCH BAR ── */
.search-bar {
    display:flex;
    gap:8px;
    flex-wrap:wrap;
    margin-bottom:16px;
    align-items:center;
}
.search-bar input,
.search-bar select {
    padding:8px 10px;
    border:1px solid #ccc;
    border-radius:4px;
    font-size:13px;
}
.search-bar input { min-width:200px; }

/* ── PAGINATION ── */
.pagination {
    display:flex;
    gap:6px;
    margin-top:16px;
    align-items:center;
    flex-wrap:wrap;
}
.pagination-info {
    font-size:12px;
    color:#666;
    margin-left:auto;
}

/* ── MESSAGES ── */
.msg-success {
    background:#eaffea;
    border:1px solid #8bd88b;
    padding:12px;
    border-radius:6px;
    margin-bottom:16px;
    color:#2d5016;
}
.msg-error {
    background:#ffecec;
    border:1px solid #e9a3a3;
    padding:12px;
    border-radius:6px;
    margin-bottom:16px;
    color:#7d2c2c;
}

/* ── MODAL BASE ── */
.modal {
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.55);
    justify-content:center;
    align-items:center;
    z-index:9999;
    padding:14px;
    overflow-y:auto;
}
.modal.show { display:flex; }
.modal-content {
    background:#fff;
    width:min(520px, 95vw);
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
}
.modal-body { padding:16px; }

/* ── VIEW MODAL ── */
.view-section { margin-bottom:16px; }
.view-section-title {
    font-weight:600;
    color:#6d0f0f;
    border-bottom:2px solid #f0f0f0;
    padding-bottom:8px;
    margin-bottom:12px;
    font-size:13px;
    text-transform:uppercase;
}
.view-field { display:flex; margin-bottom:10px; font-size:13px; }
.view-label { font-weight:600; width:120px; color:#333; flex-shrink:0; }
.view-value { flex:1; color:#555; word-break:break-word; }
.view-value.empty { color:#999; font-style:italic; }

/* ── FORM MODALS ── */
.modal-body label {
    display:block;
    font-weight:600;
    margin-top:12px;
    margin-bottom:4px;
    font-size:13px;
}
.modal-body input,
.modal-body select,
.modal-body textarea {
    width:100%;
    padding:9px;
    border:1px solid #ccc;
    border-radius:4px;
    font-size:13px;
    font-family:inherit;
}
.modal-body textarea { resize:vertical; min-height:80px; }
.modal-body input:focus,
.modal-body select:focus,
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
    flex-wrap:wrap;
}

.view-modal-actions {
    display:flex;
    justify-content:space-between;
    gap:10px;
    margin-top:16px;
    flex-wrap:wrap;
}
.view-modal-actions .left-actions { display:flex; gap:10px; flex-wrap:wrap; }

.close-x {
    background:transparent;
    border:none;
    color:#fff;
    font-size:20px;
    cursor:pointer;
    width:24px;
    height:24px;
    display:flex;
    align-items:center;
    justify-content:center;
}

/* ── ACTION BUTTONS IN TABLE ── */
.action-buttons { display:flex; gap:6px; flex-wrap:wrap; }
.action-buttons .btn { padding:5px 9px; font-size:12px; }

/* ── STATUS / PROGRESS ── */
.selected-row { background-color:#ffe0e0 !important; font-weight:bold; }

.badge { padding:4px 10px; border-radius:12px; font-size:12px; white-space:nowrap; }
.complete { background:#4caf50; color:#fff; }
.missing  { background:#f44336; color:#fff; }

.progress-bar  { width:90px; background:#eee; border-radius:5px; overflow:hidden; }
.progress-fill {
    background:#6d0f0f;
    color:#fff;
    text-align:center;
    border-radius:5px;
    font-size:11px;
    min-width:18px;
    padding:2px 0;
    white-space:nowrap;
}

/* ── BATCH TOOLBAR ── */
.batch-toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px;
    background: #fff8e1;
    border: 1px solid #f9a825;
    border-radius: 6px;
    margin-bottom: 12px;
    font-size: 13px;
    font-weight: bold;
    color: #555;
}

.btn-batch-print {
    padding: 7px 16px;
    background: #6d0f0f;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
}

.btn-batch-print:hover {
    background: #5a0c0c;
}

.btn-clear {
    padding: 7px 12px;
    background: #eee;
    color: #555;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
}

/* ── BATCH ARCHIVE BUTTON ── */
.btn-batch-archive {
    padding: 7px 16px;
    background: #e65100;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    transition: background 0.2s;
}
.btn-batch-archive:hover {
    background: #bf360c;
}

/* ── CHECKBOX COLUMN ── */
input[type="checkbox"] {
    cursor: pointer;
    width: 16px;
    height: 16px;
    accent-color: #6d0f0f;
}
/* ── BATCH CATEGORY BUTTON ── */
.btn-batch-category {
    padding: 7px 16px;
    background: #1565c0;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    transition: background 0.2s;
}

.btn-batch-category:hover {
    background: #0d47a1;
}

/* ── Validation Styles ── */
.field-error {
    color: #c62828;
    font-size: 12px;
    display: none;
    margin-top: 2px;
    font-weight: 500;
}

.field-error.visible {
    display: block;
}

input:invalid:not(:placeholder-shown):not(:focus) {
    border-color: #c62828 !important;
    box-shadow: 0 0 3px rgba(198,40,40,0.2);
}

input:valid:not(:placeholder-shown) {
    border-color: #2e7d32 !important;
}

input.input-error {
    border-color: #c62828 !important;
    background: #fff5f5;
}

input.input-valid {
    border-color: #2e7d32 !important;
}
</style>
</head>

<body class="theme-<%= _theme %>">
<div class="container">

<!-- ═══════════════ SIDEBAR ═══════════════ -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ═══════════════ MAIN ═══════════════ -->
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

    <!-- SUCCESS / ERROR MESSAGES -->
    <% if (success != null && !success.trim().isEmpty()) { %>
        <div class="msg-success">✅ <%= success.replace("<", "&lt;") %></div>
    <% } %>
    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="msg-error">❌ <%= error.replace("<", "&lt;") %></div>
    <% } %>

    <!-- CONTROLS ROW -->
    <div class="controls">
        <button class="btn btn-primary" type="button" onclick="openModal('addModal')">+ Add Student</button>

        <!-- PAGE SIZE -->
        <form method="get" action="<%=request.getContextPath()%>/students" class="page-size-form">
            <input type="hidden" name="search"     value="<%= searchParamEsc %>">
            <input type="hidden" name="categoryId" value="<%= catParamEsc %>">
            <label for="pageSizeSelect">Show</label>
            <select id="pageSizeSelect" name="pageSize" onchange="this.form.submit()">
                <option value="10"  <%=pageSize==10 ?"selected":""%>>10</option>
                <option value="25"  <%=pageSize==25 ?"selected":""%>>25</option>
                <option value="50"  <%=pageSize==50 ?"selected":""%>>50</option>
                <option value="100" <%=pageSize==100?"selected":""%>>100</option>
            </select>
            <span>entries</span>
        </form>
    </div>

    <!-- SEARCH & FILTER -->
    <form method="get" action="<%=request.getContextPath()%>/students" class="search-bar">
        <input type="hidden" name="pageSize" value="<%= pageSize %>">
        <input type="hidden" name="sort" value="<%= sort %>">
        <input type="hidden" name="dir" value="<%= dir %>">

        <input type="text" name="search"
               value="<%= searchParamEsc %>"
               placeholder="Search name or email">

        <select name="categoryId">
            <option value="">All Categories</option>
            <% if (categoryList != null) {
                for (StudentCategory c : categoryList) {
                    boolean selected = catParam.equals(String.valueOf(c.getCategoryId()));
            %>
                <option value="<%= c.getCategoryId() %>" <%= selected ? "selected" : "" %>>
                    <%= c.getCategoryName() %>
                </option>
            <% }} %>
        </select>

        <button class="btn btn-primary" type="submit">🔍 Search</button>

        <% if (showClear) { %>
            <a href="<%=request.getContextPath()%>/students?page=1&pageSize=<%= pageSize %>"
               class="btn btn-secondary">✖ Clear</a>
        <% } %>
    </form>

    <%-- ✅ BATCH PRINT and UPDATE TOOLBAR --%>
<div class="batch-toolbar" id="batchToolbar"
     style="display:none;">
    <span id="selectedCount">0</span>
    students selected

    <%-- ✅ EXISTING --%>
    <button onclick="batchPrint()"
            class="btn-batch-print">
        🖨 Print Selected
    </button>

    <%-- ✅ NEW — Batch Category Update --%>
    <button onclick="openCategoryModal()"
            class="btn-batch-category">
        📁 Update Category
    </button>

    <%-- ✅ NEW — Batch Archive (Super Admin & Admin only) --%>
    <% if ("superadmin".equals(currentUser.getRole().toLowerCase())
        || "admin".equals(currentUser.getRole().toLowerCase())) { %>
    <button onclick="openBatchArchiveModal()"
            class="btn-batch-archive">
        📦 Archive Selected
    </button>
    <% } %>

    <button onclick="clearSelection()"
            class="btn-clear">
        ✕ Clear
    </button>
</div>

    <!-- TABLE -->
<table>
    <thead>
        <tr>
            <%-- ✅ ALREADY EXISTS — keep as is --%>
            <th style="width:40px; text-align:center;">
                <input type="checkbox"
                    id="selectAll"
                    onchange="toggleAll(this)"
                    title="Select All">
            </th>
            <th>#</th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=student_id&dir=<%="student_id".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">ID <span class="sort-arrow <%="student_id".equals(sort)?"active":""%>"><%="student_id".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=last_name&dir=<%="last_name".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Name <span class="sort-arrow <%="last_name".equals(sort)?"active":""%>"><%="last_name".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=email&dir=<%="email".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Email <span class="sort-arrow <%="email".equals(sort)?"active":""%>"><%="email".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=category_name&dir=<%="category_name".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Category <span class="sort-arrow <%="category_name".equals(sort)?"active":""%>"><%="category_name".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=phone&dir=<%="phone".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Phone <span class="sort-arrow <%="phone".equals(sort)?"active":""%>"><%="phone".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=status&dir=<%="status".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Status <span class="sort-arrow <%="status".equals(sort)?"active":""%>"><%="status".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th class="sortable" onclick="window.location.href='<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%>&sort=progress&dir=<%="progress".equals(sort)? nextDir : "asc"%><%= extraParams.replaceAll("&sort=[^&]*", "").replaceAll("&dir=[^&]*", "") %>'">Progress <span class="sort-arrow <%="progress".equals(sort)?"active":""%>"><%="progress".equals(sort)?("asc".equals(dir)?"&#9650;":"&#9660;"):"&#9650;"%></span></th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
    <% if (studentList.isEmpty()) { %>
        <tr>
            <%-- ✅ CHANGE 1 — colspan 9 → 10 --%>
            <td colspan="10"
                style="text-align:center;
                       color:#999; padding:24px;">
                No students found.
            </td>
        </tr>
    <% } else {
        int rowNum = (startRow > 0) ? startRow : 1;
        for (Student s : studentList) {
            int uploaded = uploadedCountMap
                .getOrDefault(s.getStudentId(), 0);
            int safeUploaded = (totalRequirements > 0)
                ? Math.min(uploaded, totalRequirements)
                : 0;
            boolean isComplete = (totalRequirements > 0)
                && (safeUploaded >= totalRequirements);
            int percent = (totalRequirements > 0)
                ? Math.min(100,
                    safeUploaded * 100
                    / totalRequirements)
                : 0;

            String safeId      =
                String.valueOf(s.getStudentId());
            String safeName    =
                s.getFormattedName() != null
                ? s.getFormattedName()
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                : "";
                 String safeLastName = s.getLastName() != null
                    ? s.getLastName().replace("\"", "&quot;").replace("<", "&lt;") : "";
                String safeFirstName = s.getFirstName() != null
                    ? s.getFirstName().replace("\"", "&quot;").replace("<", "&lt;") : "";
                String safeMiddleName = s.getMiddleName() != null
                    ? s.getMiddleName().replace("\"", "&quot;").replace("<", "&lt;") : "";
                String displayName = s.getFormattedName() != null
                    ? s.getFormattedName().replace("\"", "&quot;").replace("<", "&lt;") : safeName;
            String safeEmail   =
                s.getEmail() != null
                ? s.getEmail()
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                : "";
            String safePhone   =
                s.getPhone() != null
                ? s.getPhone()
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                : "";
            String safeBirth   =
                s.getBirthDate() != null
                ? s.getBirthDate().toString()
                    .replace("\"", "&quot;")
                : "";
            String safeRemarks =
                s.getRemarks() != null
                ? s.getRemarks()
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                : "";
            String safeCatId   =
                String.valueOf(s.getCategoryId());
            String safeCatName =
                categoryMap.getOrDefault(
                    s.getCategoryId(), "-")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;");
            boolean isSelected =
                (selectedStudentId != null
                && selectedStudentId.equals(
                    s.getStudentId()));
    %>
        
   

<tr class="<%= isSelected
        ? "selected-row" : "" %>"
    data-id="<%= safeId %>"
    data-name="<%= safeName %>"
    data-lastname="<%= safeLastName %>"
    data-firstname="<%= safeFirstName %>"
    data-middlename="<%= safeMiddleName %>"
    data-displayname="<%= displayName %>"
    data-email="<%= safeEmail %>"
    data-phone="<%= safePhone %>"
    data-category="<%= safeCatId %>"
    data-category-name="<%= safeCatName %>"
    data-birthdate="<%= safeBirth %>"
    data-remarks="<%= safeRemarks %>">

            <%-- ✅ CHANGE 2 — NEW checkbox cell --%>
            <td style="text-align:center;">
                <input type="checkbox"
                       class="student-check"
                       value="<%= s.getStudentId() %>"
                       onchange="updateToolbar()">
            </td>

            <%-- ✅ ALL EXISTING CELLS — UNCHANGED --%>
            <td><%= rowNum++ %></td>
            <td><%= s.getStudentId() %></td>
            <td>
                <b><%= displayName %></b>
                <% if (!safeLastName.isEmpty()) { %>
                    <br><span style="font-size:11px; color:#888;">
                        <%= safeFirstName %>
                        <%= !safeMiddleName.isEmpty() ? safeMiddleName : "" %>
                        <%= safeLastName %>
                    </span>
                <% } %>
            </td>
            <td><%= safeEmail %></td>
            <td><%= safeCatName %></td>
            <td><%= !safePhone.isEmpty()
                ? safePhone : "-" %></td>

            <!-- STATUS — UNCHANGED -->
            <td>
                <% if (isComplete) { %>
                    <span class="badge complete">
                        Complete
                    </span>
                <% } else { %>
                    <span class="badge missing">
                        Missing
                    </span>
                <% } %>
            </td>

            <!-- PROGRESS — UNCHANGED -->
            <td>
                <div class="progress-bar">
                    <div class="progress-fill"
                         style="width:<%= percent %>%;">
                        <%= percent %>%
                    </div>
                </div>
            </td>

            <!-- ACTIONS — UNCHANGED -->
            <td>
                <div class="action-buttons">
                    <button class="btn btn-secondary"
                            type="button"
                            onclick="openView(this)">
                        👁 View
                    </button>

                    <button class="btn btn-primary"
                            type="button"
                            onclick="openEdit(this)">
                        ✏️ Edit
                    </button>

                    <a class="btn btn-success"
                       href="<%= request
                           .getContextPath()
                           %>/uploads?studentId=<%=
                           s.getStudentId() %>">
                        📂 Docs
                    </a>
                    <a href="<%= request
                           .getContextPath()
                           %>/student-print?studentId=<%=
                           s.getStudentId() %>"
                       target="_blank"
                       class="btn btn-secondary">
                        🖨 Print
                    </a>

                    <!-- ARCHIVE — Super Admin & Admin only -->
                    <% if ("superadmin".equals(currentUser.getRole().toLowerCase())
                        || "admin".equals(currentUser.getRole().toLowerCase())) { %>
                    <form method="post"
                        action="<%= request.getContextPath() %>/archives"
                        style="display:inline;">
                        <input type="hidden" name="action" value="archive">
                        <input type="hidden" name="studentId"
                            value="<%= s.getStudentId() %>">
                        <input type="hidden" name="studentName"
                            value="<%= s.getFormattedName() %>">
                        <button class="btn btn-warning btn-sm" type="submit"
                                onclick="return confirmSubmit(this, 
                                    'Archive student \'<%= s.getFormattedName() %>\'?\nThey will be moved to the Archives.');">
                            📦 Archive
                        </button>
                    </form>
                    <% } %>

                </div>
            </td>
        </tr>
    <%  }
       } %>
    </tbody>
</table>

    <!-- PAGINATION -->
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a class="btn btn-secondary"
               href="<%=request.getContextPath()%>/students?page=1&pageSize=<%=pageSize%><%=extraParams%>">First</a>
            <a class="btn btn-secondary"
               href="<%=request.getContextPath()%>/students?page=<%=currentPage-1%>&pageSize=<%=pageSize%><%=extraParams%>">← Prev</a>
        <% } %>

        <% for (int i = 1; i <= totalPages; i++) {
               if (i == currentPage) { %>
                   <button class="btn btn-primary" disabled><%= i %></button>
        <%     } else if (i >= currentPage - 2 && i <= currentPage + 2) { %>
                   <a class="btn btn-secondary"
                      href="<%=request.getContextPath()%>/students?page=<%=i%>&pageSize=<%=pageSize%><%=extraParams%>"><%= i %></a>
        <%     }
           } %>

        <% if (currentPage < totalPages) { %>
            <a class="btn btn-secondary"
               href="<%=request.getContextPath()%>/students?page=<%=currentPage+1%>&pageSize=<%=pageSize%><%=extraParams%>">Next →</a>
            <a class="btn btn-secondary"
               href="<%=request.getContextPath()%>/students?page=<%=totalPages%>&pageSize=<%=pageSize%><%=extraParams%>">Last</a>
        <% } %>

        <div class="pagination-info">
            Page <%= currentPage %> of <%= totalPages %> &nbsp;|&nbsp;
            Showing <%= startRow %>–<%= endRow %> of <%= totalStudents %> students
        </div>
    </div>

</div><!-- end .main -->
</div><!-- end .container -->


<!-- ═══════════════════════════════════════════
     VIEW MODAL
═══════════════════════════════════════════ -->
<div id="viewModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>Student Details</b>
            <button class="close-x" type="button" onclick="closeModal('viewModal')">×</button>
        </div>
        <div class="modal-body">

            <!-- PERSONAL INFO -->
            <div class="view-section">
                <div class="view-section-title">Personal Information</div>
                <div class="view-field">
                    <div class="view-label">ID:</div>
                    <div class="view-value" id="view_id">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Name:</div>
                    <div class="view-value" id="view_name">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Birth Date:</div>
                    <div class="view-value" id="view_birthdate">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Email:</div>
                    <div class="view-value" id="view_email">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Phone:</div>
                    <div class="view-value" id="view_phone">-</div>
                </div>
            </div>

            <!-- ACADEMIC INFO -->
            <div class="view-section">
                <div class="view-section-title">Academic Information</div>
                <div class="view-field">
                    <div class="view-label">Category:</div>
                    <div class="view-value" id="view_category">-</div>
                </div>
            </div>

            <!-- REMARKS -->
            <div class="view-section">
                <div class="view-section-title">Remarks</div>
                <div class="view-value" id="view_remarks"
                     style="padding:10px; background:#f9f9f9; border-radius:4px;
                            border-left:4px solid #6d0f0f; min-height:40px;">
                </div>
            </div>

            <!-- ACTIONS -->
            <div class="view-modal-actions">
                <div class="left-actions">
                    <button class="btn btn-primary"  type="button" onclick="switchToEdit()">✏️ Edit</button>
                    <button class="btn btn-danger"   type="button" onclick="switchToDelete()">🗑️ Delete</button>
                </div>
                <button class="btn btn-secondary" type="button" onclick="closeModal('viewModal')">Close</button>
            </div>
        </div>
    </div>
</div>


<!-- ═══════════════════════════════════════════
     ADD MODAL
═══════════════════════════════════════════ -->
<div id="addModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>Add Student</b>
            <button class="close-x" type="button" onclick="closeModal('addModal')">×</button>
        </div>
        <form method="post" action="<%=request.getContextPath()%>/students">
            <div class="modal-body">
                <input type="hidden" name="action" value="save">

               <label for="add_lastName">Last Name *</label>
                <input id="add_lastName" name="lastName" required
                       pattern="^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{2,50}$"
                       title="Letters, spaces, hyphens, apostrophes only. Min 2 characters."
                       oninput="validateNameField(this)">
                <small class="field-error" id="err_add_lastName"></small>

                <label for="add_firstName">First Name *</label>
                <input id="add_firstName" name="firstName" required
                       pattern="^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{2,50}$"
                       title="Letters, spaces, hyphens, apostrophes only. Min 2 characters."
                       oninput="validateNameField(this)">
                <small class="field-error" id="err_add_firstName"></small>

                <label for="add_middleName">Middle Name <em>(optional)</em></label>
                <input id="add_middleName" name="middleName"
                       pattern="^$|^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{1,50}$"
                       title="Letters only if provided."
                       oninput="validateNameField(this)">

                <label for="add_birthdate">Birth Date *</label>
                <input id="add_birthdate" name="birthDate" type="date" required>
                <small class="field-error" id="err_add_birthdate"></small>

                <label for="add_email">Email *</label>
                <input id="add_email" name="email" type="email" required
                       placeholder="email@example.com"
                       pattern="^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"
                       title="Enter a valid email address."
                       oninput="validateEmailField(this)">
                <small class="field-error" id="err_add_email"></small>

                <label for="add_phone">Phone</label>
                <input id="add_phone" name="phone" type="tel"
                       placeholder="09xxxxxxxxx"
                       pattern="^(09\d{9})?$"
                       title="Philippine mobile: 09 followed by 9 digits (11 total)"
                       oninput="validatePhoneField(this)">
                <small class="field-error" id="err_add_phone"></small>

                <label for="add_category">Category *</label>
                <select id="add_category" name="categoryId" required>
                    <option value="">-- Select Category --</option>
                    <% if (categoryList != null) for (StudentCategory c : categoryList) { %>
                        <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                    <% } %>
                </select>

                <label for="add_remarks">Remarks</label>
                <textarea id="add_remarks" name="remarks" placeholder="Optional notes..."></textarea>

                <div class="modal-actions">
                    <button class="btn btn-secondary" type="button" onclick="closeModal('addModal')">Cancel</button>
                    <button class="btn btn-primary"   type="submit">💾 Save</button>
                </div>
            </div>
        </form>
    </div>
</div>


<!-- ═══════════════════════════════════════════
     EDIT MODAL
═══════════════════════════════════════════ -->
<div id="editModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>Edit Student</b>
            <button class="close-x" type="button" onclick="closeModal('editModal')">×</button>
        </div>
        <form method="post" action="<%=request.getContextPath()%>/students">
            <div class="modal-body">
                <input type="hidden" name="action"    value="update">
                <input type="hidden" name="studentId" id="edit_id">

                <label for="edit_lastName">Last Name *</label>
                <input id="edit_lastName" name="lastName" required
                       pattern="^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{2,50}$"
                       title="Letters, spaces, hyphens, apostrophes only. Min 2 characters."
                       oninput="validateNameField(this)">
                <small class="field-error" id="err_edit_lastName"></small>

                <label for="edit_firstName">First Name *</label>
                <input id="edit_firstName" name="firstName" required
                       pattern="^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{2,50}$"
                       title="Letters, spaces, hyphens, apostrophes only. Min 2 characters."
                       oninput="validateNameField(this)">
                <small class="field-error" id="err_edit_firstName"></small>

                <label for="edit_middleName">Middle Name <em>(optional)</em></label>
                <input id="edit_middleName" name="middleName"
                       pattern="^$|^(?!.*\s{2})[A-Za-zÀ-ÿñÑ\s\-'.]{1,50}$"
                       title="Letters only if provided.">

                <label for="edit_birthdate">Birth Date</label>
                <input id="edit_birthdate" name="birthDate" type="date">
                <small class="field-error" id="err_edit_birthdate"></small>

                <label for="edit_email">Email *</label>
                <input id="edit_email" name="email" type="email" required
                       pattern="^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"
                       title="Enter a valid email address."
                       oninput="validateEmailField(this)">
                <small class="field-error" id="err_edit_email"></small>

                <label for="edit_phone">Phone</label>
                <input id="edit_phone" name="phone" type="tel"
                       placeholder="09xxxxxxxxx"
                       pattern="^(09\d{9})?$"
                       title="Philippine mobile: 09 followed by 9 digits"
                       oninput="validatePhoneField(this)">
                <small class="field-error" id="err_edit_phone"></small>

                <label for="edit_category">Category *</label>
                <select id="edit_category" name="categoryId" required>
                    <option value="">-- Select Category --</option>
                    <% if (categoryList != null) for (StudentCategory c : categoryList) { %>
                        <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                    <% } %>
                </select>

                <label for="edit_remarks">Remarks</label>
                <textarea id="edit_remarks" name="remarks" placeholder="Optional notes..."></textarea>

                <div class="modal-actions">
                    <button class="btn btn-secondary" type="button" onclick="closeModal('editModal')">Cancel</button>
                    <button class="btn btn-primary"   type="submit">✔️ Update</button>
                </div>
            </div>
        </form>
    </div>
</div>


<!-- ═══════════════════════════════════════════
     DELETE MODAL
═══════════════════════════════════════════ -->
<div id="deleteModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>Delete Student</b>
            <button class="close-x" type="button" onclick="closeModal('deleteModal')">×</button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:12px;">
                Are you sure you want to delete <b id="delete_name"></b>?
            </p>
            <p style="font-size:12px; color:#d32f2f; margin-bottom:16px;">
                ⚠️ <strong>WARNING:</strong> This action cannot be undone.
                All related documents will also be removed.
            </p>
            <div class="modal-actions">
                <button class="btn btn-secondary" type="button" onclick="closeModal('deleteModal')">Cancel</button>
                <a class="btn btn-danger" id="deleteLink" href="#">🗑️ Delete Permanently</a>
            </div>
        </div>
    </div>
</div>

<%-- ✅ BATCH ARCHIVE CONFIRMATION MODAL --%>
<div id="batchArchiveModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>📦 Archive Selected Students</b>
            <button class="close-x" type="button"
                    onclick="closeModal('batchArchiveModal')">×</button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:12px; font-size:14px;">
                You are about to archive
                <b id="archiveModalCount">0</b> student(s).
            </p>
            <p style="font-size:12px; color:#e65100; margin-bottom:8px;">
                ⚠️ <strong>What happens:</strong>
            </p>
            <ul style="font-size:12px; color:#555; margin-left:20px; margin-bottom:16px;">
                <li>Students will be <b>moved to the Archives</b></li>
                <li>They will <b>no longer appear</b> in the active student list</li>
                <li>Archived students can be <b>restored</b> later by an Admin</li>
            </ul>

            <p style="font-size:13px; font-weight:600; margin-bottom:8px;">
                Selected students:
            </p>
            <div id="archiveStudentList"
                 style="max-height:150px; overflow-y:auto;
                        background:#f9f9f9; border:1px solid #ddd;
                        border-radius:4px; padding:10px;
                        font-size:12px; margin-bottom:16px;">
            </div>

            <div class="modal-actions">
                <button class="btn btn-secondary" type="button"
                        onclick="closeModal('batchArchiveModal')">
                    Cancel
                </button>
                <button class="btn btn-danger" type="button"
                        onclick="executeBatchArchive()"
                        id="confirmArchiveBtn">
                    📦 Archive All Selected
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════
     JAVASCRIPT
═══════════════════════════════════════════ -->
<script>
// ── Global student snapshot ──
let currentStudent = {};

// ── Modal helpers ──
function openModal(id)  { document.getElementById(id).classList.add('show');    }
function closeModal(id) { document.getElementById(id).classList.remove('show'); }

// Close all modals on Escape
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal.show').forEach(m => m.classList.remove('show'));
    }
});

// ── Read data-* from a table row ──
function readRow(tr) {
    return {
        id           : tr.dataset.id           || '',
        name         : tr.dataset.name         || '',
        lastName     : tr.dataset.lastname     || '',
        firstName    : tr.dataset.firstname    || '',
        middleName   : tr.dataset.middlename   || '',
        displayName  : tr.dataset.displayname  || '',
        email        : tr.dataset.email        || '',
        phone        : tr.dataset.phone        || '',
        category     : tr.dataset.category     || '',
        categoryName : tr.dataset.categoryName || '-',
        birthdate    : tr.dataset.birthdate    || '',
        remarks      : tr.dataset.remarks      || ''
    };
}

// ── OPEN VIEW MODAL ──
function openView(btn) {
    currentStudent = readRow(btn.closest('tr'));

    document.getElementById('view_id').textContent        = currentStudent.id;
    document.getElementById('view_name').textContent      =currentStudent.displayName || currentStudent.name;
    document.getElementById('view_email').textContent     = currentStudent.email;
    document.getElementById('view_phone').textContent     = currentStudent.phone  || '-';
    document.getElementById('view_birthdate').textContent = currentStudent.birthdate || 'Not specified';
    document.getElementById('view_category').textContent  = currentStudent.categoryName;

    const remarksEl = document.getElementById('view_remarks');
    if (currentStudent.remarks && currentStudent.remarks.trim() !== '') {
        remarksEl.textContent = currentStudent.remarks;
        remarksEl.classList.remove('empty');
    } else {
        remarksEl.textContent = 'No remarks added.';
        remarksEl.classList.add('empty');
    }

    openModal('viewModal');
}

// ── OPEN EDIT MODAL DIRECTLY ──
function openEdit(btn) {
    currentStudent = readRow(btn.closest('tr'));
    populateEditModal();
    openModal('editModal');
}

// ── SWITCH: VIEW → EDIT ──
function switchToEdit() {
    closeModal('viewModal');
    populateEditModal();
    openModal('editModal');
}

function populateEditModal() {
    document.getElementById('edit_id').value         = currentStudent.id;
    document.getElementById('edit_lastName').value    = currentStudent.lastName;
    document.getElementById('edit_firstName').value   = currentStudent.firstName;
    document.getElementById('edit_middleName').value  = currentStudent.middleName;
    document.getElementById('edit_email').value       = currentStudent.email;
    document.getElementById('edit_phone').value       = currentStudent.phone;
    document.getElementById('edit_category').value    = currentStudent.category;
    document.getElementById('edit_birthdate').value   = currentStudent.birthdate;
    document.getElementById('edit_remarks').value     = currentStudent.remarks;
}

// ── SWITCH: VIEW → DELETE ──
function switchToDelete() {
    closeModal('viewModal');
    document.getElementById('delete_name').textContent =
    currentStudent.displayName || currentStudent.name;
    document.getElementById('deleteLink').href =
        '<%=request.getContextPath()%>/students?action=delete&studentId=' + currentStudent.id;
    openModal('deleteModal');
}
</script>

<script>
// ✅ Toggle all checkboxes
function toggleAll(master) {
    var boxes = document.querySelectorAll(
        '.student-check');
    boxes.forEach(function(box) {
        box.checked = master.checked;
    });
    updateToolbar();
}

// ✅ Update toolbar count
function updateToolbar() {
    var checked = document.querySelectorAll(
        '.student-check:checked');
    var toolbar =
        document.getElementById('batchToolbar');
    var countEl =
        document.getElementById('selectedCount');

    if (checked.length > 0) {
        toolbar.style.display = 'flex';
        countEl.textContent = checked.length;
    } else {
        toolbar.style.display = 'none';
    }
}
// ✅ Open category modal
function openCategoryModal() {
    var checked = document.querySelectorAll(
        '.student-check:checked');

    if (checked.length === 0) {
        showAlert('Please select at least one student.', 'warning');
        return;
    }

    // Update count in modal
    document.getElementById('modalCount')
        .textContent = checked.length;

    // Show modal
    var modal =
        document.getElementById('categoryModal');
    modal.style.display = 'flex';
}

// ✅ Close modal
function closeCategoryModal() {
    document.getElementById('categoryModal')
        .style.display = 'none';
    document.getElementById('modalCategorySelect')
        .value = '';
}

// ✅ Apply batch category update
function applyBatchCategory() {
    var categoryId = document
        .getElementById('modalCategorySelect')
        .value;

    if (!categoryId) {
        showAlert('Please select a category.', 'warning');
        return;
    }

    // Collect selected IDs
    var checked = document.querySelectorAll(
        '.student-check:checked');
    var ids = [];
    checked.forEach(function(b) {
        ids.push(b.value);
    });

    if (ids.length === 0) {
        showAlert('No students selected.', 'warning');
        return;
    }

    // ✅ POST to BatchCategoryServlet
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '<%= request.getContextPath()
        %>/batch-category';

    // IDs
    var idsInput =
        document.createElement('input');
    idsInput.type  = 'hidden';
    idsInput.name  = 'ids';
    idsInput.value = ids.join(',');
    form.appendChild(idsInput);

    // Category
    var catInput =
        document.createElement('input');
    catInput.type  = 'hidden';
    catInput.name  = 'categoryId';
    catInput.value = categoryId;
    form.appendChild(catInput);

    document.body.appendChild(form);
    form.submit();
}

// ✅ Close modal on background click
document.getElementById('categoryModal')
    .addEventListener('click', function(e) {
        if (e.target === this) {
            closeCategoryModal();
        }
    });

// ✅ Clear all selections
function clearSelection() {
    document.querySelectorAll(
        '.student-check')
        .forEach(function(b) {
            b.checked = false;
        });
    document.getElementById('selectAll')
        .checked = false;
    updateToolbar();
}
// ✅ Open batch print
function batchPrint() {
    var checked = document.querySelectorAll(
        '.student-check:checked');
    var ids = [];
    checked.forEach(function(b) {
        ids.push(b.value);
    });
    if (ids.length === 0) {
        showAlert('Please select at least one student.', 'warning');
        return;
    }
    // ✅ ctx now resolves correctly
    var url = '<%= request.getContextPath() %>/batch-print?ids=' + ids.join(',');
    window.open(url, '_blank');
}

// ✅ Open batch archive modal
function openBatchArchiveModal() {
    var checked = document.querySelectorAll('.student-check:checked');

    if (checked.length === 0) {
        showAlert('Please select at least one student.', 'warning');
        return;
    }

    // Update count
    document.getElementById('archiveModalCount').textContent = checked.length;

    // Build student name list
    var listDiv = document.getElementById('archiveStudentList');
    listDiv.innerHTML = '';

    checked.forEach(function(box) {
        var tr = box.closest('tr');
        var name = tr.dataset.name || 'Unknown';
        var id = tr.dataset.id || '?';
        var p = document.createElement('div');
        p.style.padding = '3px 0';
        p.style.borderBottom = '1px solid #eee';
        p.innerHTML = '• <b>' + name + '</b> <span style="color:#999;">(ID: ' + id + ')</span>';
        listDiv.appendChild(p);
    });

    openModal('batchArchiveModal');
}

// ✅ Execute batch archive
function executeBatchArchive() {
    var checked = document.querySelectorAll('.student-check:checked');
    var ids = [];

    checked.forEach(function(box) {
        ids.push(box.value);
    });

    if (ids.length === 0) {
        showAlert('No students selected.', 'warning');
        return;
    }

    // Disable button to prevent double-click
    var btn = document.getElementById('confirmArchiveBtn');
    btn.disabled = true;
    btn.textContent = '⏳ Archiving...';

    // POST to ArchiveServlet
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '<%= request.getContextPath() %>/archives';

    var actionInput = document.createElement('input');
    actionInput.type  = 'hidden';
    actionInput.name  = 'action';
    actionInput.value = 'batch-archive';
    form.appendChild(actionInput);

    var idsInput = document.createElement('input');
    idsInput.type  = 'hidden';
    idsInput.name  = 'ids';
    idsInput.value = ids.join(',');
    form.appendChild(idsInput);

    document.body.appendChild(form);
    form.submit();
}
</script>

<%-- ✅ BATCH CATEGORY MODAL --%>
<div id="categoryModal" style="
    display:none;
    position:fixed;
    top:0; left:0; right:0; bottom:0;
    background:rgba(0,0,0,0.5);
    z-index:9999;
    justify-content:center;
    align-items:center;">

    <div style="
        background:#fff;
        border-radius:8px;
        padding:30px;
        width:400px;
        box-shadow:0 8px 32px rgba(0,0,0,0.3);">

        <%-- HEADER --%>
        <h3 style="
            color:#6d0f0f;
            margin-bottom:6px;
            font-size:18px;">
            📁 Update Category
        </h3>
        <p style="
            color:#777;
            font-size:13px;
            margin-bottom:20px;">
            Selected students:
            <b id="modalCount">0</b>
        </p>

        <%-- CATEGORY SELECT --%>
        <label style="
            font-size:13px;
            font-weight:bold;
            color:#333;
            display:block;
            margin-bottom:8px;">
            New Category:
        </label>

        <select id="modalCategorySelect" style="
            width:100%;
            padding:10px;
            border:1px solid #ccc;
            border-radius:4px;
            font-size:13px;
            margin-bottom:20px;">
            <option value="">
                -- Select Category --
            </option>
            <%-- ✅ Loop your categories --%>
            <% for (StudentCategory cat :
                    categoryList) { %>
            <option value="<%= cat.getCategoryId() %>">
                <%= cat.getCategoryName() %>
            </option>
            <% } %>
        </select>

        <%-- BUTTONS --%>
        <div style="
            display:flex;
            justify-content:flex-end;
            gap:10px;">
            <button onclick="closeCategoryModal()"
                    style="
                padding:10px 20px;
                background:#eee;
                color:#555;
                border:none;
                border-radius:4px;
                cursor:pointer;
                font-size:13px;">
                Cancel
            </button>
            <button onclick="applyBatchCategory()"
                    style="
                padding:10px 20px;
                background:#6d0f0f;
                color:#fff;
                border:none;
                border-radius:4px;
                cursor:pointer;
                font-size:13px;
                font-weight:bold;">
                ✅ Apply to Selected
            </button>
        </div>
    </div>
</div>
<script>
// ══════════════════════════════════════
//  VALIDATION ENGINE
// ══════════════════════════════════════

// ── Set birthdate max = today (no future dates) ──
(function() {
    var today = new Date().toISOString().split('T')[0];
    var minDate = '1900-01-01';

    // Add form
    var addBirth = document.getElementById('add_birthdate');
    if (addBirth) {
        addBirth.setAttribute('max', today);
        addBirth.setAttribute('min', minDate);
        addBirth.addEventListener('change', function() {
            validateDateField(this, 'err_add_birthdate');
        });
    }

    // Edit form
    var editBirth = document.getElementById('edit_birthdate');
    if (editBirth) {
        editBirth.setAttribute('max', today);
        editBirth.setAttribute('min', minDate);
        editBirth.addEventListener('change', function() {
            validateDateField(this, 'err_edit_birthdate');
        });
    }
})();

// ── Name Field Validation ──
function validateNameField(input) {
    var value = input.value;
    var errId = 'err_' + input.id;
    var errEl = document.getElementById(errId);

    // Remove leading/trailing spaces visually
    if (value !== value.trimStart()) {
        input.value = value.trimStart();
        value = input.value;
    }

    // Check if only whitespace
    if (value.length > 0 && value.trim().length === 0) {
        showError(input, errId, 'Name cannot be blank spaces only.');
        return false;
    }

    // Check for numbers
    if (/\d/.test(value)) {
        showError(input, errId, 'Name cannot contain numbers.');
        return false;
    }

    // Check for special characters (allow letters, spaces, hyphens, apostrophes, periods, ñ/Ñ)
    if (value.length > 0 && !/^[A-Za-zÀ-ÿñÑ\s\-'.]+$/.test(value)) {
        showError(input, errId, 'Only letters, spaces, hyphens, apostrophes, and periods allowed.');
        return false;
    }

    // Check minimum length for required fields
    if (input.required && value.trim().length > 0 && value.trim().length < 2) {
        showError(input, errId, 'Minimum 2 characters required.');
        return false;
    }

    // Check consecutive spaces
    if (/\s{2,}/.test(value)) {
        showError(input, errId, 'No consecutive spaces allowed.');
        return false;
    }

    clearError(input, errId);
    return true;
}

// ── Date Field Validation ──
function validateDateField(input, errId) {
    var value = input.value;
    if (!value) {
        clearError(input, errId);
        return true;
    }

    var selected = new Date(value);
    var today = new Date();
    today.setHours(23, 59, 59, 999);

    var minDate = new Date('1900-01-01');

    if (selected > today) {
        showError(input, errId, 'Birth date cannot be in the future.');
        input.value = '';
        return false;
    }

    if (selected < minDate) {
        showError(input, errId, 'Birth date must be after January 1, 1900.');
        input.value = '';
        return false;
    }

    // Check if too young (e.g., born today = 0 years old, maybe unrealistic for students)
    // Optional: uncomment to enforce minimum age
    // var age = today.getFullYear() - selected.getFullYear();
    // if (age < 15) {
    //     showError(input, errId, 'Student must be at least 15 years old.');
    //     return false;
    // }

    clearError(input, errId);
    return true;
}

// ── Email Validation ──
function validateEmailField(input) {
    var value = input.value.trim();
    var errId = 'err_' + input.id;
    var pattern = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;

    if (value.length > 0 && !pattern.test(value)) {
        showError(input, errId, 'Enter a valid email address (e.g., name@example.com).');
        return false;
    }

    clearError(input, errId);
    return true;
}

// ── Phone Validation ──
function validatePhoneField(input) {
    var value = input.value.trim();
    var errId = 'err_' + input.id;

    // Allow empty (optional field)
    if (value.length === 0) {
        clearError(input, errId);
        return true;
    }

    // Only digits allowed
    if (/[^\d]/.test(value)) {
        input.value = value.replace(/[^\d]/g, '');
        value = input.value;
    }

    // Must start with 09
    if (value.length >= 2 && !value.startsWith('09')) {
        showError(input, errId, 'Philippine mobile must start with 09.');
        return false;
    }

    // Must be exactly 11 digits
    if (value.length > 0 && value.length !== 11) {
        showError(input, errId, 'Phone must be exactly 11 digits (09xxxxxxxxx).');
        return false;
    }

    clearError(input, errId);
    return true;
}

// ── Helper: Show Error ──
function showError(input, errId, message) {
    input.classList.add('input-error');
    input.classList.remove('input-valid');
    var errEl = document.getElementById(errId);
    if (errEl) {
        errEl.textContent = message;
        errEl.classList.add('visible');
    }
}

// ── Helper: Clear Error ──
function clearError(input, errId) {
    input.classList.remove('input-error');
    if (input.value.trim().length > 0) {
        input.classList.add('input-valid');
    } else {
        input.classList.remove('input-valid');
    }
    var errEl = document.getElementById(errId);
    if (errEl) {
        errEl.textContent = '';
        errEl.classList.remove('visible');
    }
}

// ══ Form Submit Validation ══
function validateStudentForm(formId) {
    var form = document.getElementById(formId);
    if (!form) return true;

    var prefix = formId === 'addForm' ? 'add_' : 'edit_';
    var valid = true;

    // Validate name fields
    ['lastName', 'firstName'].forEach(function(field) {
        var input = document.getElementById(prefix + field);
        if (input) {
            // Trim the value before submit
            input.value = input.value.trim();
            if (input.value.length === 0) {
                showError(input, 'err_' + prefix + field,
                    field === 'lastName' ? 'Last name is required.' : 'First name is required.');
                valid = false;
            } else if (!validateNameField(input)) {
                valid = false;
            }
        }
    });

    // Validate birthdate
    var birthInput = document.getElementById(prefix + 'birthdate');
    if (birthInput && birthInput.value) {
        if (!validateDateField(birthInput, 'err_' + prefix + 'birthdate')) {
            valid = false;
        }
    }

    // Validate email
    var emailInput = document.getElementById(prefix + 'email');
    if (emailInput) {
        emailInput.value = emailInput.value.trim();
        if (!validateEmailField(emailInput)) {
            valid = false;
        }
    }

    // Validate phone
    var phoneInput = document.getElementById(prefix + 'phone');
    if (phoneInput && !validatePhoneField(phoneInput)) {
        valid = false;
    }

    if (!valid) {
        // Scroll to first error
        var firstErr = form.querySelector('.input-error');
        if (firstErr) firstErr.focus();
    }

    return valid;
}

// ── Attach to forms ──
document.addEventListener('DOMContentLoaded', function() {
    // Add form
    var addForm = document.querySelector('form[action*="students"] input[value="add"]');
    if (addForm) {
        var form = addForm.closest('form');
        if (form) {
            form.setAttribute('id', 'addForm');
            form.addEventListener('submit', function(e) {
                if (!validateStudentForm('addForm')) {
                    e.preventDefault();
                }
            });
        }
    }

    // Edit form
    var editForm = document.querySelector('form[action*="students"] input[value="update"]');
    if (editForm) {
        var form = editForm.closest('form');
        if (form) {
            form.setAttribute('id', 'editForm');
            form.addEventListener('submit', function(e) {
                if (!validateStudentForm('editForm')) {
                    e.preventDefault();
                }
            });
        }
    }
});
</script>
<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
