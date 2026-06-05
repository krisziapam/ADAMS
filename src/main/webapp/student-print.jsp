<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="
    java.util.*,
    java.text.SimpleDateFormat,
    model.Student,
    model.RequirementType,
    model.Upload,
    model.User" %>

<%
    /* =========================
       ALL VARIABLES — ONE PLACE
       NO DUPLICATES
       ========================= */

    Student student =
        (Student) request.getAttribute("student");

    List<RequirementType> requirements =
        (List<RequirementType>)
        request.getAttribute("requirements");

    List<Upload> uploads =
        (List<Upload>)
        request.getAttribute("uploads");

    Integer _submitted =
        (Integer) request.getAttribute(
            "submittedCount");
    Integer _total =
        (Integer) request.getAttribute(
            "totalRequirements");
    Boolean _complete =
        (Boolean) request.getAttribute(
            "isComplete");

    int submittedCount =
        _submitted != null ? _submitted : 0;
    int totalRequirements =
        _total != null ? _total : 0;
    boolean isComplete =
        _complete != null ? _complete : false;

    // ✅ Single declaration — no duplicates
    String refNo =
        (String) request.getAttribute("refNo");
    String generatedBy =
        (String) request.getAttribute("generatedBy");
    String categoryName =
        (String) request.getAttribute("categoryName");
    String qrCode =
        (String) request.getAttribute("qrCode");
    String printedBy =
        (String) request.getAttribute("printedBy");

    // ✅ Single date — no duplicates
    Date printedAt =
        (Date) request.getAttribute("printedAt");

    // ✅ Null safety
    if (refNo == null)
        refNo = "VDM-N/A";
    if (generatedBy == null)
        generatedBy = "—";
    if (categoryName == null)
        categoryName = "—";
    if (printedBy == null)
        printedBy = "—";
    if (printedAt == null)
        printedAt = new Date();

    // ✅ Aliases for footer/header
    Date generatedAt = printedAt;

    // ✅ ONE formatter
    SimpleDateFormat dtf =
        new SimpleDateFormat(
            "MMM dd, yyyy hh:mm a");

    // ✅ Pre-formatted date string
    String formattedDate = dtf.format(printedAt);
%>

<!DOCTYPE html>
<html>
<head>
    <link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
<meta charset="UTF-8">
<title>Student Submission Report</title>

<style>
* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family: Arial, sans-serif;
    background: #fff;
    color: #000;
    padding: 10px 20px;
}

/* ── PRINT BUTTON ── */
.no-print {
    text-align: right;
    margin-bottom: 15px;
}
.no-print button {
    padding: 8px 16px;
    background: #6d0f0f;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
}

/* ── HEADER BOX ── */
.header-box {
    width: 100%;
    border-collapse: collapse;
    border: 1px solid #000;
    margin-bottom: 20px;
}
.header-box .title-cell {
    padding: 20px 24px;
    vertical-align: middle;
}
.header-box .title-cell h1 {
    font-size: 24px;
    font-weight: bold;
    margin: 0;
}
.header-box .qr-cell {
    width: 150px;
    border-left: 1px solid #000;
    text-align: center;
    vertical-align: top;
    padding: 10px;
}
.header-box .qr-cell p {
    font-size: 11px;
    color: #555;
    margin-bottom: 8px;
}

/* ── INFO TABLE ── */
.info-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 25px;
    font-size: 13px;
}
.info-table td {
    padding: 8px 12px;
    border: 1px solid #ccc;
}
.info-table .label {
    width: 160px;
    font-weight: bold;
    background: #f5f5f5;
    white-space: nowrap;
}

/* ── REQUIREMENTS TABLE ── */
.req-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
    font-size: 13px;
}
.req-table th {
    background: #6d0f0f;
    color: #fff;
    padding: 10px 12px;
    text-align: left;
}
.req-table td {
    padding: 9px 12px;
    border-bottom: 1px solid #ddd;
}
.req-table tr:nth-child(even) td {
    background: #fafafa;
}

/* ── COMPLETION ── */
.completion {
    text-align: center;
    margin: 20px 0 10px 0;
    font-size: 16px;
}
.status-complete { color: green; font-weight: bold; }
.status-incomplete { color: red; font-weight: bold; }

/* ── VERIFIED FOOTER ── */
.verified {
    margin-top: 25px;
    text-align: center;
    padding: 10px;
    border-top: 1px solid #ddd;
    border-bottom: 1px solid #ddd;
}
.verified p:first-child {
    font-weight: bold;
    font-size: 13px;
}
.verified p:last-child {
    font-size: 11px;
    font-style: italic;
    color: #555;
    margin-top: 4px;
}

/* ── PRINT META ── */
.print-meta {
    font-size: 11px;
    color: #555;
    margin-top: 14px;
}

/* ── SIGNATURE ── */
.signature {
    margin-top: 30px;
    font-size: 13px;
    line-height: 2;
}

/* ========== CLOSE TAB BUTTON ========== */
.btn-close-tab {
    padding: 10px 16px;
    background: #e81123;
    color: #fff;
    border: none;
    border-radius: 4px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-close-tab:hover {
    background: #c50f1f;
}

/* ✅ Hide when printing */
@media print {
    .btn-window-close {
        display: none !important;
    }
}

/* ── PRINT STYLES ── */
@media print {
    .no-print,
    [style*="display: flex"][style*="justify-content: flex-end"] {
        display: none !important;
    }

@media print {
    th {
        border: 1.5px solid #000 !important;
    }
}

:root {
    --maroon: #6d0f0f;
    --light-gray: #f5f5f5;
    --border-gray: #ccc;
    --green: #2e7d32;
    --red: #c62828;
    }

@media print {
    /* ✅ TIGHTER — accounts for PUP header + fixed footer */
    @page {
        size: A4;
        margin-top:    0.5cm;
        margin-bottom: 2cm;
        margin-left:   1.27cm;
        margin-right:  1.27cm;
    }
    body {
        margin: 0;
        padding: 0;
    }
    /* keep colors */
    * {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }
}
/* ===== BASE PRINT TYPOGRAPHY ===== */
body {
    font-size: 12px;
    font-family: Arial, Helvetica, sans-serif;
}

h1 {
    font-size: 24px;
}

h2 {
    font-size: 14px;
}

/* Tables */
table {
    font-size: 12px;
}

th {
    font-size: 13px;
    font-weight: bold;
}

td {
    font-size: 12px;
}
}
</style>
</head>
<body>

<!-- BUTTONS — no-print -->
<div class="no-print" style="
    display:flex;
    justify-content:flex-end;
    gap:10px;
    margin-bottom:15px;">

    <!-- 🖨 PRINT BUTTON -->
    <button
        onclick="window.print()"
        style="
            padding: 8px 16px;
            background: #6d0f0f;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;">
        🖨 Print
    </button>

    <!-- 📥 DOWNLOAD PDF BUTTON -->
    <a href="<%= request.getContextPath() %>/student-pdf?studentId=<%= student.getStudentId() %>"
       style="
           padding: 8px 16px;
           background: #6d0f0f;
           color: #fff;
           border-radius: 4px;
           cursor: pointer;
           font-size: 13px;
           text-decoration: none;
           display: inline-block;">
        📥 Download PDF
    </a>

    <%-- ✕ CLOSE TAB BUTTON --%>
        <button class="btn-close-tab"
                onclick="closeTab()"
                title="Close this tab">
            ✕
        </button>

</div>

<%-- ✅ PUP HEADER --%>
<jsp:include page="/includes/print-header.jsp" />

<!-- REFERENCE NUMBER -->
<%-- ══ UNIFIED HEADER ══ --%>

<%-- ROW 2: Ref No + Campus + Printed by + Date --%>
<table style="width:100%;
              border-collapse:collapse;
              margin-bottom:12px;">
    <tr>
        <%-- LEFT: Ref No --%>
        <td style="
            border:1px solid #ccc;
            padding:8px 12px;
            font-size:11px;
            width:50%;">
            <b>Reference No:</b><br>
            <span style="
                font-family:'Courier New',monospace;
                color:#6d0f0f;
                font-weight:bold;
                font-size:13px;
                letter-spacing:1px;">
                <%= refNo %>
            </span>
        </td>
        <%-- RIGHT: Campus + Printed by + Date --%>
        <td style="
            border:1px solid #ccc;
            border-left:none;
            padding:8px 12px;
            font-size:11px;
            width:50%;
            text-align:right;">
            <b>Campus:</b> Sta. Mesa (MN0)
            <br>
            <b>Printed by:</b> <%= generatedBy %>
            &nbsp;|&nbsp;
            <b>Date:</b> <%= formattedDate %>
        </td>
    </tr>
</table>

<!-- MAIN TITLE + QR HEADER -->
<table style="
    width:100%;
    border-collapse:collapse;
    border:1px solid #000;
    margin-bottom:20px;">
    <tr>
        <td style="padding:18px 22px;
            vertical-align:middle;">
            <h1 style="
                margin:0;
                font-size:24px;
                font-weight:bold;
                color:#6d0f0f;">
                Student Submission Report
            </h1>
        </td>

        <td style="
            width:140px;
            border-left:1px solid #000;
            text-align:center;
            vertical-align:middle;
            padding:10px;">
            <% if (qrCode != null && !qrCode.isEmpty()) { %>
                <img
                    src="data:image/png;base64,<%= qrCode %>"
                    width="110"
                    alt="QR Verification Code" />
            <% } %>
        </td>
    </tr>
</table>

<!-- ══════════════════════════
     STUDENT INFO
══════════════════════════ -->
<table style="
    width:100%;
    border-collapse:collapse;
    font-size:13px;
    margin-bottom:18px;
">
    <tr>
        <td style="background:#f5f5f5; border:1px solid #999; padding:8px; font-weight:bold;">
            Student ID
        </td>
        <td style="border:1px solid #999; padding:8px;">
            <%= student.getStudentId() %>
        </td>
    </tr>
    <tr>
        <td style="background:#f5f5f5; border:1px solid #999; padding:8px; font-weight:bold;">
            Student Name
        </td>
        <td style="border:1px solid #999; padding:8px;">
            <%= student.getFormattedName() %>
        </td>
    </tr>
    <tr>
        <td style="background:#f5f5f5; border:1px solid #999; padding:8px; font-weight:bold;">
            Category
        </td>
        <td style="border:1px solid #999; padding:8px;">
            <%= categoryName %>
        </td>
    </tr>
    <tr>
        <td style="background:#f5f5f5; border:1px solid #999; padding:8px; font-weight:bold;">
            Email
        </td>
        <td style="border:1px solid #999; padding:8px;">
            <%= student.getEmail() %>
        </td>
    </tr>
    <tr>
        <td style="background:#f5f5f5; border:1px solid #999; padding:8px; font-weight:bold;">
            Generated By
        </td>
        <td style="border:1px solid #999; padding:8px;">
            <%= generatedBy %>
        </td>
    </tr>
</table>

<!-- ══════════════════════════
     REQUIREMENTS STATUS
══════════════════════════ -->
<h2 style="
    text-align:center;
    color:#6d0f0f;
    margin-bottom:6px;
">
    Requirements Status
</h2>

<table style="
    width:100%;
    border-collapse:collapse;
    font-size:13px;
    margin-bottom:16px;
">
    <!-- HEADER -->
    <tr>
    <th style="background:#6d0f0f; color:#fff; border:1px solid #999; padding:7px; text-align:left;">#</th>
    <th style="background:#6d0f0f; color:#fff; border:1px solid #999; padding:7px; text-align:left;">Requirement</th>
    <th style="background:#6d0f0f; color:#fff; border:1px solid #999; padding:7px; text-align:left;">Status</th>
</tr>
<%
int row = 1;
for (RequirementType r : requirements) {
    boolean submitted = false;
    for (Upload u : uploads) {
        if (u.getRequirementId() == r.getRequirementId()
                && u.getFileName() != null) {
            submitted = true;
            break;
        }
    }
%>
    <tr>
        <td style="border:1px solid #999; padding:7px; text-align:left;">
        <%= row++ %>
        </td>

        <td style="border:1px solid #999; padding:7px; text-align:left;">
            <%= r.getRequirementName() %>
        </td>

        <td style="
            border:1px solid #999;
            padding:7px;
            text-align:left;
            font-weight:bold;
            color:<%= submitted ? "#2e7d32" : "#c62828" %>;
        ">
            <%= submitted ? "Submitted" : "Not Submitted" %>
        </td>
    </tr>
<% } %>
</table>

<%-- ✅ PUP FOOTER (replaces your old verified footer) --%>
<jsp:include page="/includes/print-footer.jsp" />

<!-- ══════════════════════════
     COMPLETION STATUS
══════════════════════════ 
<div class="completion">
    <strong>Completion Status:
        <span class="<%= isComplete
            ? "status-complete"
            : "status-incomplete" %>">
            <%= isComplete ? "COMPLETED" : "INCOMPLETE" %>
        </span>
    </strong>
</div>-->

<!-- ══════════════════════════
     SIGNATURE
══════════════════════════ -->
<div class="signature">
    <p>Prepared by: _____________________________</p>
    <p>Date: _____________________________</p>
</div>

<script>
function closeTab() {
    window.close();
    // Fallback if browser blocks it
    setTimeout(function() {
        window.history.back();
    }, 300);
}
</script>
</body>
</html>