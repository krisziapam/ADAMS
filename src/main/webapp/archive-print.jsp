<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.ArchivedStudent, model.StudentRequirement, model.User" %>

<%
    List<ArchivedStudent> printList =
        (List<ArchivedStudent>) request.getAttribute("printList");
    if (printList == null || printList.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/archives");
        return;
    }

    Map<Integer, List<StudentRequirement>> documentsMap =
        (Map<Integer, List<StudentRequirement>>) request.getAttribute("documentsMap");
    if (documentsMap == null) documentsMap = new HashMap<>();

    String printedBy = (String) request.getAttribute("printedBy");
    if (printedBy == null) printedBy = "Unknown";

    boolean isBatch = printList.size() > 1;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= isBatch
        ? "Batch Archive Print (" + printList.size() + " records)"
        : "Archive Print — " + printList.get(0).getFormattedName() %></title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:'Segoe UI', Arial, sans-serif;
            background:#f4f4f4; padding:20px;
        }

        /* ── PRINT CONTROLS ── */
        .print-controls {
            display:flex; gap:10px; margin-bottom:20px;
            align-items:center; flex-wrap:wrap;
        }
        .print-controls button {
            padding:10px 20px; border:none; border-radius:4px;
            cursor:pointer; font-size:14px; font-weight:600;
        }
        .btn-print { background:#6d0f0f; color:#fff; }
        .btn-print:hover { background:#5a0c0c; }
        .btn-back { background:#6c757d; color:#fff; }
        .btn-back:hover { background:#5a6268; }
        .print-info { font-size:12px; color:#888; margin-left:auto; }

        /* ── CARD ── */
        .archive-card {
            background:#fff; border-radius:8px;
            box-shadow:0 2px 8px rgba(0,0,0,0.1);
            margin-bottom:24px; overflow:hidden;
            page-break-inside:avoid;
        }
        .card-header {
            background:#6d0f0f; color:#fff; padding:14px 20px;
            display:flex; justify-content:space-between; align-items:center;
        }
        .card-header h3 { margin:0; font-size:16px; }
        .card-header .archive-badge {
            background:rgba(255,255,255,0.2);
            padding:4px 12px; border-radius:12px;
            font-size:11px; font-weight:700;
        }
        .card-body { padding:20px; }

        /* ── INFO GRID ── */
        .info-grid {
            display:grid; grid-template-columns:1fr 1fr; gap:16px;
        }
        .info-section { margin-bottom:16px; }
        .info-section-title {
            font-weight:700; font-size:13px; color:#6d0f0f;
            border-bottom:2px solid #f0f0f0;
            padding-bottom:6px; margin-bottom:10px;
            text-transform:uppercase;
        }
        .info-row { display:flex; padding:4px 0; font-size:13px; }
        .info-label { width:130px; font-weight:600; color:#555; flex-shrink:0; }
        .info-value { flex:1; color:#333; word-break:break-word; }
        .info-value.empty { color:#999; font-style:italic; }

        .remarks-box {
            padding:12px; background:#f9f9f9; border-radius:4px;
            border-left:4px solid #6d0f0f; min-height:40px;
            font-size:13px; color:#555; white-space:pre-wrap;
        }

        /* ── DOCUMENTS TABLE ── */
        .docs-section { margin-top:8px; }
        .docs-section-title {
            font-weight:700; font-size:13px; color:#6d0f0f;
            border-bottom:2px solid #f0f0f0;
            padding-bottom:6px; margin-bottom:10px;
            text-transform:uppercase;
        }
        .docs-table { width:100%; border-collapse:collapse; font-size:12px; }
        .docs-table th {
            background:#f5f5f5; padding:8px 12px;
            text-align:left; font-weight:700; color:#333;
            border-bottom:2px solid #ddd;
            font-size:11px; text-transform:uppercase;
        }
        .docs-table td { padding:8px 12px; border-bottom:1px solid #eee; }
        .docs-table tr:last-child td { border-bottom:none; }
        .docs-table tr:hover { background:#fafafa; }

        .doc-status {
            padding:2px 8px; border-radius:10px;
            font-size:10px; font-weight:700; display:inline-block;
        }
        .doc-submitted { background:#e8f5e9; color:#2e7d32; }
        .doc-approved  { background:#e8f5e9; color:#1b5e20; }
        .doc-pending   { background:#fff3e0; color:#e65100; }
        .doc-rejected  { background:#ffebee; color:#c62828; }

        .doc-filename { color:#1565c0; font-weight:600; }

        .no-docs {
            text-align:center; color:#999; padding:16px;
            font-style:italic; font-size:12px;
        }

        .doc-summary {
            display:flex; gap:16px; margin-top:8px; margin-bottom:10px;
            padding:8px 12px; background:#f9f9f9;
            border-radius:4px; font-size:12px; flex-wrap:wrap;
        }
        .doc-summary-item { display:flex; gap:4px; align-items:center; }
        .doc-summary-count { font-weight:700; font-size:14px; }
        .doc-summary-label { color:#666; }

        .file-size { color:#999; font-size:10px; }

        /* ── SUMMARY TABLE (batch) ── */
        .summary-card {
            background:#fff; border-radius:8px;
            box-shadow:0 2px 8px rgba(0,0,0,0.1);
            margin-bottom:24px; overflow:hidden;
            page-break-after:always;
        }
        .summary-card .card-header { background:#333; }
        .summary-table { width:100%; border-collapse:collapse; }
        .summary-table th {
            background:#f5f5f5; padding:10px 14px;
            text-align:left; font-size:12px;
            font-weight:700; color:#333; border-bottom:2px solid #ddd;
        }
        .summary-table td {
            padding:10px 14px; font-size:12px; border-bottom:1px solid #eee;
        }
        .summary-table tr:hover { background:#fafafa; }

        .footer-info {
            text-align:center; font-size:11px;
            color:#999; padding:10px; margin-top:8px;
        }

        /* ── PRINT STYLES ── */
        @media print {
            body { background:#fff; padding:0; margin:0; }
            .print-controls { display:none !important; }
            .archive-card, .summary-card {
                box-shadow:none; border:1px solid #ddd;
            }
            .card-header, .doc-status, .doc-submitted,
            .doc-approved, .doc-pending, .doc-rejected,
            .docs-table th, .doc-summary {
                -webkit-print-color-adjust:exact;
                print-color-adjust:exact;
            }
        }
    </style>
</head>
<body>

<!-- ═══ PRINT CONTROLS ═══ -->
<div class="print-controls">
    <button class="btn-print" onclick="window.print()">🖨 Print</button>
    <button class="btn-back" onclick="window.close()">← Close</button>
    <div class="print-info">
        📦 <%= printList.size() %> archived record(s)
        &nbsp;|&nbsp; Printed by: <b><%= printedBy %></b>
        &nbsp;|&nbsp; <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm")
                .format(new java.util.Date()) %>
    </div>
</div>

<% if (isBatch) { %>
<!-- ═══ SUMMARY TABLE (batch only) ═══ -->
<div class="summary-card">
    <div class="card-header">
        <h3>📋 Archived Students Summary — <%= printList.size() %> Records</h3>
        <span class="archive-badge">BATCH PRINT</span>
    </div>
    <table class="summary-table">
        <thead>
            <tr>
                <th>#</th>
                <th>Student ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Category</th>
                <th>Docs</th>
                <th>Archived Date</th>
                <th>Archived By</th>
            </tr>
        </thead>
        <tbody>
        <% int summaryNum = 1;
           for (ArchivedStudent s : printList) {
               List<StudentRequirement> sDocs =
                   documentsMap.getOrDefault(s.getStudentId(), new ArrayList<>());
        %>
            <tr>
                <td><%= summaryNum++ %></td>
                <td><%= s.getStudentId() %></td>
                <td><b><%= s.getFormattedName() != null ? s.getFormattedName() : "—" %></b></td>
                <td><%= s.getEmail() != null ? s.getEmail() : "—" %></td>
                <td><%= s.getCategoryName() != null ? s.getCategoryName() : "—" %></td>
                <td><b><%= sDocs.size() %></b></td>
                <td><%= s.getArchivedAt() != null
                    ? s.getArchivedAt().toString().substring(0,16) : "—" %></td>
                <td><%= s.getArchivedByName() != null ? s.getArchivedByName() : "—" %></td>
            </tr>
        <% } %>
        </tbody>
    </table>
    <div class="footer-info">
        ADAMS — Student Archive Report
        | Generated: <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
                .format(new java.util.Date()) %>
        | Printed by: <%= printedBy %>
    </div>
</div>
<% } %>

<!-- ═══ INDIVIDUAL CARDS ═══ -->
<% int cardNum = 1;
   for (ArchivedStudent s : printList) {
       List<StudentRequirement> docs =
           documentsMap.getOrDefault(s.getStudentId(), new ArrayList<>());
       int docCount = docs.size();
%>
<div class="archive-card">
    <div class="card-header">
        <h3><%= isBatch ? (cardNum++ + ". ") : "" %>📦
            <%= s.getFormattedName() != null ? s.getFormattedName() : "Unknown Student" %></h3>
        <span class="archive-badge">ARCHIVED</span>
    </div>
    <div class="card-body">

        <!-- ═══ INFO GRID ═══ -->
        <div class="info-grid">
            <!-- LEFT: Personal Info -->
            <div>
                <div class="info-section">
                    <div class="info-section-title">Personal Information</div>
                    <div class="info-row">
                        <div class="info-label">Student ID:</div>
                        <div class="info-value"><%= s.getStudentId() %></div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Full Name:</div>
                        <div class="info-value">
                            <%= s.getFormattedName() != null ? s.getFormattedName() : "—" %>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Birth Date:</div>
                        <div class="info-value">
                            <%= s.getBirthDate() != null ? s.getBirthDate() : "—" %>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Email:</div>
                        <div class="info-value">
                            <%= s.getEmail() != null ? s.getEmail() : "—" %>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Phone:</div>
                        <div class="info-value<%= (s.getPhone() == null
                            || s.getPhone().isEmpty()) ? " empty" : "" %>">
                            <%= (s.getPhone() != null && !s.getPhone().isEmpty())
                                ? s.getPhone() : "Not provided" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- RIGHT: Academic + Archive Info -->
            <div>
                <div class="info-section">
                    <div class="info-section-title">Academic Information</div>
                    <div class="info-row">
                        <div class="info-label">Category:</div>
                        <div class="info-value">
                            <%= s.getCategoryName() != null ? s.getCategoryName() : "—" %>
                        </div>
                    </div>
                </div>
                <div class="info-section">
                    <div class="info-section-title">Archive Information</div>
                    <div class="info-row">
                        <div class="info-label">Archived Date:</div>
                        <div class="info-value">
                            <%= s.getArchivedAt() != null
                                ? s.getArchivedAt().toString().substring(0,16) : "—" %>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Archived By:</div>
                        <div class="info-value">
                            <%= s.getArchivedByName() != null ? s.getArchivedByName() : "—" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ═══ REMARKS ═══ -->
        <div class="info-section">
            <div class="info-section-title">Remarks</div>
            <div class="remarks-box"><%=
                (s.getRemarks() != null && !s.getRemarks().trim().isEmpty())
                ? s.getRemarks().replace("<", "&lt;").replace(">", "&gt;")
                : "No remarks."
            %></div>
        </div>

        <!-- ═══════════════════════════════════════
             📄 SUBMITTED REQUIREMENTS / DOCUMENTS
        ═══════════════════════════════════════ -->
        <div class="docs-section">
            <div class="docs-section-title">
                📄 Submitted Requirements
                (<%= docCount %> document<%= docCount != 1 ? "s" : "" %>)
            </div>

            <% if (docs.isEmpty()) { %>
                <div class="no-docs">
                    No documents were submitted by this student.
                </div>
            <% } else { %>

                <!-- DOCUMENT SUMMARY -->
                <div class="doc-summary">
                    <div class="doc-summary-item">
                        <span class="doc-summary-count" style="color:#2e7d32;">
                            <%= docCount %>
                        </span>
                        <span class="doc-summary-label">Total Submitted</span>
                    </div>
                </div>

                <!-- DOCUMENTS TABLE -->
                <table class="docs-table">
                    <thead>
                        <tr>
                            <th style="width:35px;">#</th>
                            <th>Requirement</th>
                            <th>File Name</th>
                            <th style="width:80px;">Size</th>
                            <th style="width:130px;">Upload Date</th>
                            <th style="width:90px;">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        int docNum = 1;
                        for (StudentRequirement doc : docs) {

                            // ── Determine status badge ──
                            String statusCss  = "doc-submitted";
                            String statusText = "Submitted";

                            if (doc.getStatus() != null) {
                                String st = doc.getStatus().toLowerCase();
                                if (st.contains("approv")) {
                                    statusCss  = "doc-approved";
                                    statusText = "Approved";
                                } else if (st.contains("pend")) {
                                    statusCss  = "doc-pending";
                                    statusText = "Pending";
                                } else if (st.contains("reject")
                                        || st.contains("miss")) {
                                    statusCss  = "doc-rejected";
                                    statusText = "Rejected";
                                } else {
                                    statusText = doc.getStatus();
                                }
                            }

                            // ── Format file size ──
                            String sizeStr = "—";
                            if (doc.getFileSize() > 0) {
                                long bytes = doc.getFileSize();
                                if (bytes < 1024) {
                                    sizeStr = bytes + " B";
                                } else if (bytes < 1024 * 1024) {
                                    sizeStr = String.format("%.1f KB",
                                        bytes / 1024.0);
                                } else {
                                    sizeStr = String.format("%.2f MB",
                                        bytes / (1024.0 * 1024.0));
                                }
                            }

                            // ── Format upload date ──
                            String uploadDateStr = "—";
                            if (doc.getUploadedAt() != null) {
                                uploadDateStr = doc.getUploadedAt()
                                    .toString().substring(0, 16);
                            } else if (doc.getUploadDate() != null) {
                                uploadDateStr = doc.getUploadDate().toString();
                            }
                    %>
                        <tr>
                            <td><%= docNum++ %></td>
                            <td>
                                <b><%= doc.getRequirementName() != null
                                    ? doc.getRequirementName() : "—" %></b>
                            </td>
                            <td>
                                <span class="doc-filename">
                                    <%= doc.getFileName() != null
                                        ? doc.getFileName() : "—" %>
                                </span>
                            </td>
                            <td>
                                <span class="file-size"><%= sizeStr %></span>
                            </td>
                            <td style="font-size:11px; color:#666;">
                                <%= uploadDateStr %>
                            </td>
                            <td>
                                <span class="doc-status <%= statusCss %>">
                                    <%= statusText %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

    </div>
</div>
<% } %>

<div class="footer-info">
    ADAMS — Automated Document Admission Management System (ADAMS)
    | Archive Print
    | <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
            .format(new java.util.Date()) %>
    | Printed by: <%= printedBy %>
</div>

</body>
</html>
