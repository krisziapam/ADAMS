<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.ActivityLog, model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLEncoder" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<ActivityLog> logs =
        (List<ActivityLog>) request.getAttribute("logs");
    if (logs == null) logs = new ArrayList<>();

    int currentPage = (Integer) request.getAttribute("currentPage");
    int totalPages  = (Integer) request.getAttribute("totalPages");
    int pageSize    = (Integer) request.getAttribute("pageSize");
    int startRow    = (Integer) request.getAttribute("startRow");
    int endRow      = (Integer) request.getAttribute("endRow");
    int totalLogs   = (Integer) request.getAttribute("totalLogs");

    String filterModule   = (String) request.getAttribute("filterModule");
    String filterUsername = (String) request.getAttribute("filterUsername");
    if (filterModule   == null) filterModule   = "";
    if (filterUsername == null) filterUsername = "";

    // ✅ CLEAN BASE URL (no spaces, no line breaks)
    String baseUrl = request.getContextPath()
        + "/activity-log?module="
        + URLEncoder.encode(filterModule, "UTF-8")
        + "&username="
        + URLEncoder.encode(filterUsername, "UTF-8")
        + "&pageSize=" + pageSize;

    // ✅ DATE FORMATTER (no timezone shift — DB already UTC+8)
    SimpleDateFormat dtf =
        new SimpleDateFormat("MMM dd, yyyy hh:mm a");
    
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
<title>Activity Log | ADAMS</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family:'Segoe UI', Arial, sans-serif; background:#f4f4f4; }
.container { display:flex; min-height:100vh; }

/* SIDEBAR */
.sidebar {
    width:240px; background:#6d0f0f;
    color:#fff; display:flex; flex-direction:column;
}
.sidebar h2 {
    margin:0; padding:20px;
    background:#5a0c0c; text-align:center; font-size:18px;
}
.sidebar a {
    display:block; padding:14px 20px;
    color:#fff; text-decoration:none; transition:background 0.2s;
}
.sidebar a:hover  { background:#8b1a1a; }
.sidebar a.active { background:#8b1a1a; font-weight:600; }
.sidebar .logout  { margin-top:auto; background:#4a0a0a; }

/* MAIN */
.main { flex:1; padding:25px; overflow-x:auto; }

.header-info {
    text-align:right; font-size:13px;
    margin-bottom:16px;
}

/* FILTER BAR */
.filter-bar {
    display:flex; gap:8px; flex-wrap:wrap;
    align-items:center; margin-bottom:16px;
}
.filter-bar input,
.filter-bar select {
    padding:8px 10px; border:1px solid #ccc;
    border-radius:4px; font-size:13px;
}

/* BUTTONS */
.btn {
    padding:8px 14px; border:none; border-radius:4px;
    cursor:pointer; font-size:13px; text-decoration:none;
    display:inline-block; transition:background 0.2s;
}
.btn-primary  { background:#6d0f0f; color:#fff; }
.btn-primary:hover  { background:#5a0c0c; }
.btn-secondary { background:#6c757d; color:#fff; }
.btn-secondary:hover { background:#5a6268; }

/* TABLE */
table {
    width:100%; background:#fff; border-collapse:collapse;
    border-radius:8px; overflow:hidden;
    box-shadow:0 2px 4px rgba(0,0,0,.1);
}
th, td {
    padding:11px 14px; border-bottom:1px solid #ddd;
    text-align:left; font-size:13px;
}
th { background:#f5f5f5; font-weight:600; }
tr:hover { background:#f9f9f9; }

/* BADGES */
.badge {
    padding:3px 10px; border-radius:12px;
    font-size:11px; font-weight:700;
    white-space:nowrap; display:inline-block;
}
.badge-add     { background:#e8f5e9; color:#2e7d32; }
.badge-update  { background:#e3f2fd; color:#1565c0; }
.badge-delete  { background:#fdecea; color:#b71c1c; }
.badge-upload  { background:#fff8e1; color:#f57f17; }
.badge-replace { background:#f3e5f5; color:#6a1b9a; }

/* PAGINATION */
.pagination-wrap {
    display:flex; justify-content:center;
    align-items:center; gap:6px;
    margin-top:20px; flex-wrap:wrap;
}
.pg-btn {
    padding:6px 12px; border-radius:4px;
    text-decoration:none; font-size:12px;
    display:inline-block;
}
.pg-btn-nav    { background:#6d0f0f; color:#fff; }
.pg-btn-nav:hover { background:#5a0c0c; }
.pg-btn-num    { background:#f5f5f5; color:#333; border:1px solid #ccc; }
.pg-btn-num:hover { background:#e0e0e0; }
.pg-btn-active { background:#333; color:#fff; font-weight:bold; }
.pg-info {
    text-align:center; font-size:11px;
    color:#777; margin-top:8px;
}

/* EMPTY */
.empty-row td {
    text-align:center; color:#999; padding:30px;
}
</style>
</head>
<body class="theme-<%= _theme %>">
<div class="container">

<!-- SIDEBAR -->
<jsp:include page="/includes/sidebar.jsp" />


<!-- MAIN -->
<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <!-- HEADER INFO -->
    <div class="header-info">
        Logged in as <b><%= currentUser.getUsername() %></b><br>
        Role: <b>
            <%= currentUser.getRole() != null
                ? currentUser.getRole().substring(0,1).toUpperCase()
                + currentUser.getRole().substring(1).toLowerCase()
                : "Unknown" %>
        </b>
    </div>

    <!-- FILTER BAR -->
    <form method="get"
          action="<%= request.getContextPath() %>/activity-log"
          class="filter-bar">

        <input type="hidden" name="pageSize" value="<%= pageSize %>">

        <select name="module">
            <option value="">All Modules</option>
            <option value="Students"
                <%= "Students".equals(filterModule) ? "selected" : "" %>>
                Students
            </option>
            <option value="Uploads"
                <%= "Uploads".equals(filterModule) ? "selected" : "" %>>
                Uploads
            </option>
            <option value="Users"
                <%= "Users".equals(filterModule) ? "selected" : "" %>>
                Users
            </option>
            <option value="Categories"
                <%= "Categories".equals(filterModule) ? "selected" : "" %>>
                Categories
            </option>
            <option value="Requirements"
                <%= "Requirements".equals(filterModule) ? "selected" : "" %>>
                Requirements
            </option>
        </select>

        <input type="text" name="username"
               value="<%= filterUsername %>"
               placeholder="Search by username">

        <button class="btn btn-primary" type="submit">
            &#128269; Filter
        </button>

        <% if (!filterModule.isEmpty() || !filterUsername.isEmpty()) { %>
            <a class="btn btn-secondary"
               href="<%= request.getContextPath() %>/activity-log">
                Clear
            </a>
        <% } %>
    </form>

    <!-- TABLE -->
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Date &amp; Time</th>
                <th>User</th>
                <th>Action</th>
                <th>Module</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
        <% if (logs.isEmpty()) { %>
            <tr class="empty-row">
                <td colspan="6">No activity logs found.</td>
            </tr>
        <% } else {
            int rowNum = startRow;
            for (ActivityLog log : logs) {
                String badgeClass;
                switch (log.getAction()) {
                    case "ADD":     badgeClass = "badge-add";     break;
                    case "DELETE":  badgeClass = "badge-delete";  break;
                    case "UPLOAD":  badgeClass = "badge-upload";  break;
                    case "REPLACE": badgeClass = "badge-replace"; break;
                    default:        badgeClass = "badge-update";  break;
                }
        %>
            <tr>
                <td><%= rowNum++ %></td>
                <td style="white-space:nowrap;">
                    <%= log.getLogTime() != null
                        ? dtf.format(log.getLogTime())
                        : "—" %>
                </td>
                <td><%= log.getUsername() %></td>
                <td>
                    <span class="badge <%= badgeClass %>">
                        <%= log.getAction() %>
                    </span>
                </td>
                <td><%= log.getModule() %></td>
                <td><%= log.getDescription() %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>

    <!-- PAGINATION -->
    <div class="pagination-wrap">

        <% if (currentPage > 1) { %>
            <a href="<%= baseUrl %>&page=1"
               class="pg-btn pg-btn-nav">&laquo; First</a>
            <a href="<%= baseUrl %>&page=<%= currentPage - 1 %>"
               class="pg-btn pg-btn-nav">&lsaquo; Prev</a>
        <% } %>

        <%
            int startPage = Math.max(1, currentPage - 2);
            int endPage   = Math.min(totalPages, currentPage + 2);
        %>

        <% for (int pg = startPage; pg <= endPage; pg++) { %>
            <% if (pg == currentPage) { %>
                <span class="pg-btn pg-btn-active"><%= pg %></span>
            <% } else { %>
                <a href="<%= baseUrl %>&page=<%= pg %>"
                   class="pg-btn pg-btn-num"><%= pg %></a>
            <% } %>
        <% } %>

        <% if (currentPage < totalPages) { %>
            <a href="<%= baseUrl %>&page=<%= currentPage + 1 %>"
               class="pg-btn pg-btn-nav">Next &rsaquo;</a>
            <a href="<%= baseUrl %>&page=<%= totalPages %>"
               class="pg-btn pg-btn-nav">Last &raquo;</a>
        <% } %>

    </div>

    <!-- PAGE INFO -->
    <p class="pg-info">
        Showing <%= startRow %> – <%= endRow %> of <%= totalLogs %> logs
        &nbsp;|&nbsp; Page <%= currentPage %> of <%= totalPages %>
    </p>

</div><!-- end .main -->
</div><!-- end .container -->

<jsp:include page="/includes/footer.jsp" />
</body>
</html>
