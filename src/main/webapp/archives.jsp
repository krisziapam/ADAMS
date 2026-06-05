<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.User, model.ArchivedStudent" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String role = currentUser.getRole().toLowerCase();
    if (!"superadmin".equals(role) && !"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    List<ArchivedStudent> archivedList =
        (List<ArchivedStudent>) request.getAttribute("archivedList");
    if (archivedList == null) archivedList = new ArrayList<>();

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");

    String _theme = (String) session.getAttribute("theme");
    if (_theme == null) _theme = "normal";

    // ── Extract unique categories for filter dropdown ──
    Set<String> categorySet = new LinkedHashSet<>();
    for (ArchivedStudent a : archivedList) {
        if (a.getCategoryName() != null && !a.getCategoryName().isEmpty()) {
            categorySet.add(a.getCategoryName());
        }
    }
    List<String> categories = new ArrayList<>(categorySet);
    Collections.sort(categories);
%>

<!DOCTYPE html>
<html>
<head>
    <link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/themes.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Archives | ADAMS</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',Arial,sans-serif; background:#f4f4f4; }
        .container { display:flex; min-height:100vh; }
        .main { flex:1; padding:25px; overflow-x:auto; }

        .header {
            background:#fff; padding:16px 20px; border-radius:8px;
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:20px; box-shadow:0 2px 4px rgba(0,0,0,0.1);
        }
        .header h2 { margin:0; }
        .header-info { text-align:right; font-size:13px; }

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

        /* ── STATS ── */
        .stats-bar {
            display:flex; gap:16px; margin-bottom:20px; flex-wrap:wrap;
        }
        .stat-card {
            background:#fff; padding:16px 24px; border-radius:8px;
            box-shadow:0 2px 4px rgba(0,0,0,0.1); text-align:center;
        }
        .stat-card .number { font-size:28px; font-weight:700; color:#6d0f0f; }
        .stat-card .label  { font-size:12px; color:#888; margin-top:4px; }

        /* ── SEARCH BAR ── */
        .search-bar {
            display:flex; gap:8px; flex-wrap:wrap;
            margin-bottom:16px; align-items:center;
        }
        .search-bar input,
        .search-bar select {
            padding:8px 10px; border:1px solid #ccc;
            border-radius:4px; font-size:13px;
        }
        .search-bar input { min-width:200px; }

        /* ── BATCH TOOLBAR ── */
        .batch-toolbar {
            display:flex; align-items:center; gap:12px;
            padding:10px 16px; background:#fff8e1;
            border:1px solid #f9a825; border-radius:6px;
            margin-bottom:12px; font-size:13px;
            font-weight:bold; color:#555;
        }

        /* ── TABLE ── */
        table {
            width:100%; background:#fff; border-collapse:collapse;
            border-radius:8px; overflow:hidden;
            box-shadow:0 2px 4px rgba(0,0,0,0.1);
        }
        thead { background:#6d0f0f; color:#fff; }
        thead th {
            padding:12px 14px; text-align:left; font-size:13px;
        }
        tbody tr { border-bottom:1px solid #ddd; }
        tbody tr:hover { background:#f9f9f9; }
        tbody td { padding:11px 14px; font-size:13px; vertical-align:middle; }

        /* ── SORTABLE HEADERS ── */
        .sortable {
            cursor:pointer; user-select:none;
            white-space:nowrap;
        }
        .sortable:hover { text-decoration:underline; }
        .sort-icon { font-size:11px; margin-left:4px; opacity:0.7; }

        /* ── BUTTONS ── */
        .btn {
            padding:8px 14px; border:none; border-radius:4px;
            cursor:pointer; font-size:13px; text-decoration:none;
            display:inline-block; transition:background 0.2s;
        }
        .btn-sm { padding:5px 10px; font-size:12px; }
        .btn-primary   { background:#6d0f0f; color:#fff; }
        .btn-primary:hover   { background:#5a0c0c; }
        .btn-secondary { background:#6c757d; color:#fff; }
        .btn-secondary:hover { background:#5a6268; }
        .btn-success   { background:#2e7d32; color:#fff; }
        .btn-success:hover { background:#1b5e20; }
        .btn-danger    { background:#c62828; color:#fff; }
        .btn-danger:hover  { background:#b71c1c; }
        .btn-warning   { background:#f57c00; color:#fff; }
        .btn-warning:hover { background:#e65100; }

        .btn-batch-print {
            padding:7px 16px; background:#6d0f0f; color:#fff;
            border:none; border-radius:4px; cursor:pointer;
            font-size:13px; font-weight:bold;
        }
        .btn-batch-print:hover { background:#5a0c0c; }
        .btn-clear {
            padding:7px 12px; background:#eee; color:#555;
            border:none; border-radius:4px; cursor:pointer;
            font-size:13px;
        }
        .btn-clear:hover { background:#ddd; }

        .action-cell { display:flex; gap:5px; flex-wrap:wrap; }

        /* ── BADGES ── */
        .badge-archived {
            background:#fff3e0; color:#e65100;
            padding:3px 10px; border-radius:12px;
            font-size:11px; font-weight:700;
        }

        /* ── CHECKBOX ── */
        input[type="checkbox"] {
            cursor:pointer; width:16px; height:16px;
            accent-color:#6d0f0f;
        }

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
            box-shadow:0 12px 40px rgba(0,0,0,0.35);
        }
        .modal-header {
            background:#6d0f0f; color:#fff; padding:14px 16px;
            display:flex; justify-content:space-between;
            align-items:center; font-weight:600;
        }
        .modal-body { padding:16px; }
        .modal-actions {
            display:flex; justify-content:flex-end;
            gap:10px; margin-top:16px;
        }
        .close-x {
            background:transparent; border:none;
            color:#fff; font-size:20px; cursor:pointer;
        }
        .view-section { margin-bottom:16px; }
        .view-section-title {
            font-weight:700; font-size:14px; color:#6d0f0f;
            border-bottom:2px solid #6d0f0f; padding-bottom:4px;
            margin-bottom:8px;
        }
        .view-field { display:flex; padding:4px 0; }
        .view-label { width:130px; font-weight:600; color:#555; font-size:13px; }
        .view-value { flex:1; font-size:13px; }

        /* ── NO RESULTS ── */
        .no-results {
            text-align:center; color:#999; padding:30px; font-size:13px;
        }
    </style>
</head>
<body class="theme-<%= _theme %>">
<div class="container">

    <!-- SIDEBAR -->
    <jsp:include page="/includes/sidebar.jsp" />

    <div class="main">
        <jsp:include page="/includes/pup-banner.jsp" />

        <div class="header">
            <h2>📦 Student Archives</h2>
            <div class="header-info">
                Logged in as <b><%= currentUser.getUsername() %></b><br>
                Role: <b><%= currentUser.getRole() %></b>
            </div>
        </div>

        <!-- MESSAGES -->
        <% if (successMsg != null && !successMsg.isEmpty()) { %>
            <div class="msg-success">✅ <%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="msg-error">❌ <%= errorMsg %></div>
        <% } %>

        <!-- STATS -->
        <div class="stats-bar">
            <div class="stat-card">
                <div class="number" id="totalCount"><%= archivedList.size() %></div>
                <div class="label">Total Archived</div>
            </div>
            <div class="stat-card">
                <div class="number" id="filteredCount"><%= archivedList.size() %></div>
                <div class="label">Showing</div>
            </div>
        </div>

        <!-- ═══ SEARCH & FILTER BAR ═══ -->
        <div class="search-bar">
            <input type="text" id="searchInput"
                   placeholder="Search name or email"
                   oninput="applyFilters()">

            <select id="categoryFilter" onchange="applyFilters()">
                <option value="">All Categories</option>
                <% for (String cat : categories) { %>
                    <option value="<%= cat %>"><%= cat %></option>
                <% } %>
            </select>

            <button class="btn btn-primary" type="button"
                    onclick="applyFilters()">
                🔍 Search
            </button>

            <button class="btn btn-secondary" type="button"
                    id="clearBtn" style="display:none;"
                    onclick="clearFilters()">
                ✖ Clear
            </button>
        </div>

        <!-- ═══ BATCH TOOLBAR ═══ -->
        <div class="batch-toolbar" id="batchToolbar" style="display:none;">
            <span id="selectedCount">0</span> archived students selected

            <button onclick="batchPrintArchive()" class="btn-batch-print">
                🖨 Print Selected
            </button>

            <% if ("superadmin".equals(role)) { %>
            <button onclick="batchRestoreArchive()" class="btn-batch-print"
                    style="background:#2e7d32;">
                ♻️ Restore Selected
            </button>
            <% } %>

            <button onclick="clearArchiveSelection()" class="btn-clear">
                ✕ Clear
            </button>
        </div>

        <!-- ═══ TABLE ═══ -->
        <table id="archiveTable">
            <thead>
                <tr>
                    <th style="width:40px; text-align:center;">
                        <input type="checkbox" id="selectAll"
                               onchange="toggleAllArchive(this)"
                               title="Select All">
                    </th>
                    <th>#</th>
                    <th>Student ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th class="sortable" onclick="sortTable('category')">
                        Category <span class="sort-icon" id="sort_category">⇅</span>
                    </th>
                    <th class="sortable" onclick="sortTable('date')">
                        Archived Date <span class="sort-icon" id="sort_date">⇅</span>
                    </th>
                    <th>Archived By</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="archiveBody">
            <% if (archivedList.isEmpty()) { %>
                <tr class="no-data-row">
                    <td colspan="9" class="no-results">
                        📭 No archived records found.
                    </td>
                </tr>
            <% } else {
                   int rowNum = 1;
                   for (ArchivedStudent s : archivedList) {
                       String safeName = s.getFormattedName() != null
                           ? s.getFormattedName().replace("\"","&quot;")
                               .replace("<","&lt;") : "";
                       String safeEmail = s.getEmail() != null
                           ? s.getEmail().replace("\"","&quot;")
                               .replace("<","&lt;") : "";
                       String safePhone = s.getPhone() != null
                           ? s.getPhone().replace("\"","&quot;") : "";
                       String safeBirth = s.getBirthDate() != null
                           ? s.getBirthDate().toString() : "";
                       String safeCat = s.getCategoryName() != null
                           ? s.getCategoryName() : "";
                       String safeRemarks = s.getRemarks() != null
                           ? s.getRemarks().replace("\"","&quot;")
                               .replace("<","&lt;") : "";
                       String safeDate = s.getArchivedAt() != null
                           ? s.getArchivedAt().toString().substring(0,16) : "";
                       String safeBy = s.getArchivedByName() != null
                           ? s.getArchivedByName() : "";
            %>
                <tr class="archive-row"
                    data-name="<%= safeName.toLowerCase() %>"
                    data-email="<%= safeEmail.toLowerCase() %>"
                    data-category="<%= safeCat %>"
                    data-date="<%= safeDate %>"
                    data-archive-id="<%= s.getArchiveId() %>"
                    data-student-id="<%= s.getStudentId() %>"
                    data-student-name="<%= safeName %>"
                    data-phone="<%= safePhone %>"
                    data-birthdate="<%= safeBirth %>"
                    data-remarks="<%= safeRemarks %>"
                    data-category-name="<%= safeCat %>"
                    data-archived-at="<%= safeDate %>"
                    data-archived-by="<%= safeBy %>">

                    <td style="text-align:center;">
                        <input type="checkbox" class="archive-check"
                               value="<%= s.getArchiveId() %>"
                               onchange="updateArchiveToolbar()">
                    </td>
                    <td class="row-num"><%= rowNum++ %></td>
                    <td><%= s.getStudentId() %></td>
                    <td>
                        <b><%= safeName.isEmpty() ? "—" : safeName %></b><br>
                        <span style="font-size:11px; color:#888;">
                            <%= safePhone.isEmpty() ? "" : safePhone %>
                        </span>
                    </td>
                    <td style="font-size:12px;">
                        <%= safeEmail.isEmpty() ? "—" : safeEmail %>
                    </td>
                    <td>
                        <span class="badge-archived"><%= safeCat.isEmpty() ? "—" : safeCat %></span>
                    </td>
                    <td style="font-size:12px; color:#666;">
                        <%= safeDate.isEmpty() ? "—" : safeDate %>
                    </td>
                    <td style="font-size:12px;">
                        <%= safeBy.isEmpty() ? "—" : safeBy %>
                    </td>
                    <td>
                        <div class="action-cell">
                            <!-- VIEW -->
                            <button class="btn btn-secondary btn-sm"
                                    type="button"
                                    onclick="openArchiveView(this)">
                                👁️ View
                            </button>

                            <!-- PRINT -->
                            <a class="btn btn-warning btn-sm"
                               href="<%= request.getContextPath()
                               %>/archive-print?archiveId=<%= s.getArchiveId() %>"
                               target="_blank">
                                🖨 Print
                            </a>

                            <!-- RESTORE -->
                            <a class="btn btn-success btn-sm"
                               href="<%= request.getContextPath()
                               %>/archives?action=restore&archiveId=<%= s.getArchiveId() %>"
                               onclick="return confirmSubmit(this, 
                                   'Restore student \'<%= safeName %>\' back to active list?');">
                                ♻️ Restore
                            </a>

                            <!-- PERMANENT DELETE — Super Admin only -->
                            <% if ("superadmin".equals(
                                   currentUser.getRole().toLowerCase())) { %>
                            <a class="btn btn-danger btn-sm"
                               href="<%= request.getContextPath()
                               %>/archives?action=delete&archiveId=<%= s.getArchiveId() %>"
                               onclick="return confirmSubmit(this, 
                                   'PERMANENTLY delete \'<%= safeName %>\'?\nThis cannot be undone!');">
                                🗑️
                            </a>
                            <% } %>
                        </div>
                    </td>
                </tr>
            <%   }
               } %>
            </tbody>
        </table>

        <!-- FILTERED COUNT INFO -->
        <div style="margin-top:12px; font-size:12px; color:#666;" id="filterInfo"></div>

    </div>
</div>

<!-- ═══ VIEW MODAL ═══ -->
<div id="viewArchiveModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <b>📦 Archived Student Details</b>
            <button class="close-x" type="button"
                    onclick="closeModal('viewArchiveModal')">×</button>
        </div>
        <div class="modal-body">
            <div class="view-section">
                <div class="view-section-title">Personal Information</div>
                <div class="view-field">
                    <div class="view-label">Student ID:</div>
                    <div class="view-value" id="av_studentId">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Name:</div>
                    <div class="view-value" id="av_name">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Birth Date:</div>
                    <div class="view-value" id="av_birthdate">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Email:</div>
                    <div class="view-value" id="av_email">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Phone:</div>
                    <div class="view-value" id="av_phone">-</div>
                </div>
            </div>
            <div class="view-section">
                <div class="view-section-title">Academic Information</div>
                <div class="view-field">
                    <div class="view-label">Category:</div>
                    <div class="view-value" id="av_category">-</div>
                </div>
            </div>
            <div class="view-section">
                <div class="view-section-title">Archive Information</div>
                <div class="view-field">
                    <div class="view-label">Archived Date:</div>
                    <div class="view-value" id="av_archivedAt">-</div>
                </div>
                <div class="view-field">
                    <div class="view-label">Archived By:</div>
                    <div class="view-value" id="av_archivedBy">-</div>
                </div>
            </div>
            <div class="view-section">
                <div class="view-section-title">Remarks</div>
                <div class="view-value" id="av_remarks"
                     style="padding:10px; background:#f9f9f9;
                            border-radius:4px;
                            border-left:4px solid #6d0f0f;
                            min-height:40px;">
                </div>
            </div>
            <div class="modal-actions">
                <button class="btn btn-secondary" type="button"
                        onclick="closeModal('viewArchiveModal')">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- ═══ JAVASCRIPT ═══ -->
<script>
// ── Modal helpers ──
function openModal(id)  { document.getElementById(id).classList.add('show'); }
function closeModal(id) { document.getElementById(id).classList.remove('show'); }

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal.show')
                .forEach(m => m.classList.remove('show'));
    }
});

// ══════════════════════════════════
//  VIEW MODAL
// ══════════════════════════════════
function openArchiveView(btn) {
    var tr = btn.closest('tr');
    document.getElementById('av_studentId').textContent  = tr.dataset.studentId || '—';
    document.getElementById('av_name').textContent       = tr.dataset.studentName || '—';
    document.getElementById('av_birthdate').textContent   = tr.dataset.birthdate || '—';
    document.getElementById('av_email').textContent       = tr.dataset.email || '—';
    document.getElementById('av_phone').textContent       = tr.dataset.phone || '—';
    document.getElementById('av_category').textContent    = tr.dataset.categoryName || '—';
    document.getElementById('av_archivedAt').textContent  = tr.dataset.archivedAt || '—';
    document.getElementById('av_archivedBy').textContent  = tr.dataset.archivedBy || '—';
    document.getElementById('av_remarks').textContent     = tr.dataset.remarks || 'No remarks.';
    openModal('viewArchiveModal');
}

// ══════════════════════════════════
//  SEARCH & FILTER (Client-Side)
// ══════════════════════════════════
function applyFilters() {
    var search   = document.getElementById('searchInput').value.toLowerCase().trim();
    var category = document.getElementById('categoryFilter').value;
    var rows     = document.querySelectorAll('.archive-row');
    var visible  = 0;
    var rowNum   = 1;

    rows.forEach(function(row) {
        var name  = row.dataset.name  || '';
        var email = row.dataset.email || '';
        var cat   = row.dataset.category || '';

        var matchSearch = !search
            || name.indexOf(search) !== -1
            || email.indexOf(search) !== -1;

        var matchCategory = !category || cat === category;

        if (matchSearch && matchCategory) {
            row.style.display = '';
            row.querySelector('.row-num').textContent = rowNum++;
            visible++;
        } else {
            row.style.display = 'none';
            // Uncheck hidden rows
            var cb = row.querySelector('.archive-check');
            if (cb) cb.checked = false;
        }
    });

    // Update counts
    document.getElementById('filteredCount').textContent = visible;

    // Show/hide clear button
    var clearBtn = document.getElementById('clearBtn');
    clearBtn.style.display = (search || category) ? 'inline-block' : 'none';

    // Filter info
    var info = document.getElementById('filterInfo');
    if (search || category) {
        info.textContent = 'Showing ' + visible + ' of '
            + rows.length + ' archived records';
    } else {
        info.textContent = '';
    }

    // Update batch toolbar
    updateArchiveToolbar();
}

function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('categoryFilter').value = '';
    resetSort();
    applyFilters();
}

// ══════════════════════════════════
//  SORTING (Client-Side)
// ══════════════════════════════════
var currentSort  = '';
var sortAsc      = true;

function sortTable(column) {
    var tbody = document.getElementById('archiveBody');
    var rows  = Array.from(tbody.querySelectorAll('.archive-row'));

    // Toggle direction
    if (currentSort === column) {
        sortAsc = !sortAsc;
    } else {
        currentSort = column;
        sortAsc = true;
    }

    rows.sort(function(a, b) {
        var valA, valB;

        if (column === 'category') {
            valA = (a.dataset.category || '').toLowerCase();
            valB = (b.dataset.category || '').toLowerCase();
        } else if (column === 'date') {
            valA = a.dataset.date || '';
            valB = b.dataset.date || '';
        }

        if (valA < valB) return sortAsc ? -1 : 1;
        if (valA > valB) return sortAsc ? 1 : -1;
        return 0;
    });

    // Re-append sorted rows
    rows.forEach(function(row) { tbody.appendChild(row); });

    // Update sort icons
    document.getElementById('sort_category').textContent = '⇅';
    document.getElementById('sort_date').textContent     = '⇅';

    var icon = document.getElementById('sort_' + column);
    icon.textContent = sortAsc ? '▲' : '▼';

    // Re-number visible rows
    renumberRows();
}

function resetSort() {
    currentSort = '';
    sortAsc = true;
    document.getElementById('sort_category').textContent = '⇅';
    document.getElementById('sort_date').textContent     = '⇅';
}

function renumberRows() {
    var rows = document.querySelectorAll('.archive-row');
    var num = 1;
    rows.forEach(function(row) {
        if (row.style.display !== 'none') {
            row.querySelector('.row-num').textContent = num++;
        }
    });
}

// ══════════════════════════════════
//  BATCH SELECT / PRINT / RESTORE
// ══════════════════════════════════
function toggleAllArchive(master) {
    var boxes = document.querySelectorAll('.archive-check');
    boxes.forEach(function(box) {
        // Only check visible rows
        if (box.closest('tr').style.display !== 'none') {
            box.checked = master.checked;
        }
    });
    updateArchiveToolbar();
}

function updateArchiveToolbar() {
    var checked = document.querySelectorAll('.archive-check:checked');
    var toolbar = document.getElementById('batchToolbar');
    var countEl = document.getElementById('selectedCount');

    if (checked.length > 0) {
        toolbar.style.display = 'flex';
        countEl.textContent = checked.length;
    } else {
        toolbar.style.display = 'none';
    }
}

function clearArchiveSelection() {
    document.querySelectorAll('.archive-check')
        .forEach(function(b) { b.checked = false; });
    document.getElementById('selectAll').checked = false;
    updateArchiveToolbar();
}

function batchPrintArchive() {
    var checked = document.querySelectorAll('.archive-check:checked');
    var ids = [];
    checked.forEach(function(b) { ids.push(b.value); });

    if (ids.length === 0) {
        showAlert('Please select at least one archived student.', 'warning');
        return;
    }

    var url = '<%= request.getContextPath() %>/archive-print?ids=' + ids.join(',');
    window.open(url, '_blank');
}

function batchRestoreArchive() {
    var checked = document.querySelectorAll('.archive-check:checked');
    var ids = [];
    checked.forEach(function(b) { ids.push(b.value); });

    if (ids.length === 0) {
        showAlert('Please select at least one archived student.', 'warning');
        return;
    }

    if (!confirm('Restore ' + ids.length + ' student(s) back to the active list?')) {
        return;
    }

    // POST to servlet
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '<%= request.getContextPath() %>/archives';

    var actionInput = document.createElement('input');
    actionInput.type  = 'hidden';
    actionInput.name  = 'action';
    actionInput.value = 'batch-restore';
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

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
