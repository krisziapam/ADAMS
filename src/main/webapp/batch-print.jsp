<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="
    java.util.*,
    java.text.SimpleDateFormat,
    model.RequirementType,
    model.Upload,
    servlet.BatchPrintServlet.BatchStudentRow" %>

<%
    List<BatchStudentRow> batchRows =
        (List<BatchStudentRow>)
        request.getAttribute("batchRows");

    String generatedBy =
        (String) request.getAttribute("generatedBy");
    Date generatedAt =
        (Date) request.getAttribute("generatedAt");

    SimpleDateFormat dtf =
        new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    if (batchRows   == null) batchRows   = new ArrayList<>();
    if (generatedBy == null) generatedBy = "—";
    if (generatedAt == null) generatedAt = new Date();

    String formattedDate = dtf.format(generatedAt);

    int batchTotal = batchRows.size();
    int batchIdx   = 0;
%>

<!DOCTYPE html>
<html>
<head>
    <link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
<meta charset="UTF-8">
<title>Batch Print | ADAMS</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family: Arial, sans-serif;
    background: #fff;
    padding: 10px 20px;
    color: #000;
}

/* ── TOOLBAR ── */
.no-print {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
    padding: 12px 16px;
    background: #f5f5f5;
    border: 1px solid #ddd;
    border-radius: 6px;
}
.no-print span {
    font-size: 13px;
    color: #555;
    font-weight: bold;
}
.btn-print {
    padding: 10px 24px;
    background: #6d0f0f;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    transition: background 0.2s;
}
.btn-print:hover { background: #5a0c0c; }
.btn-back {
    padding: 10px 16px;
    background: #eee;
    color: #555;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    display: inline-block;
}

/* ── STUDENT BLOCK ── */
.student-block {
    margin-bottom: 30px;
    padding-bottom: 10px;
}
/* ========== WINDOWS-STYLE CLOSE BUTTON ========== */
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

/* ── PRINT ── */
@media print {

    .no-print { display: none !important; }

    /* ✅ TIGHTER — accounts for PUP header + fixed footer */
        @page {
            size: A4;
            margin-top:    0.5cm;
            margin-bottom: 2cm;
            margin-left:   1.27cm;
            margin-right:  1.27cm;
        }

    * {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }

    body { padding-bottom: 60px; }

    /* ✅ Each student = one page */
    .student-block {
        page-break-after: always;
        page-break-inside: avoid;
    }

    /* ✅ Last block — no blank extra page */
    .student-block:last-of-type {
        page-break-after: avoid !important;
    }

    /* ✅ Fixed footer — every page */
    .print-footer {
        display: block;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        height: 1.5cm;
        background: #fff;
        text-align: center;
        font-size: 10px;
        color: #555;
        padding-top: 5px;
    }
    .footer-line {
        border-top: 1px solid #aaa;
        width: 90%;
        margin: 0 auto 4px auto;
    }
    .footer-text {
        font-weight: bold;
        color: #6d0f0f;
        font-size: 10px;
        margin-bottom: 2px;
    }
    .footer-meta {
        font-style: italic;
        font-size: 9px;
        color: #555;
    }
}
</style>
</head>
<body>

<%-- ══ TOOLBAR ══ --%>
<div class="no-print">
    <span>
        🖨 Batch Print —
        <b><%= batchTotal %></b> students selected
    </span>
    <div style="display:flex; gap:10px;">
        <button class="btn-print"
                onclick="window.print()">
            🖨 Print All (<%= batchTotal %> pages)
        </button>

        <%-- ✕ CLOSE TAB BUTTON --%>
        <button class="btn-close-tab"
                onclick="closeTab()"
                title="Close this tab">
            ✕
        </button>
    </div>
</div>

<%-- ══ STUDENT BLOCKS ══ --%>
<%
    for (BatchStudentRow row : batchRows) {
        batchIdx++;
        boolean isLast = (batchIdx == batchTotal);
%>

<%-- ✅ PUP HEADER (on every student page) --%>
    <jsp:include page="/includes/print-header.jsp" />

<div class="student-block"
     style="<%= isLast
         ? "page-break-after:avoid;"
         : "page-break-after:always;" %>">

    <%-- ══ REF HEADER ══ --%>
    <table style="
        width:100%;
        border-collapse:collapse;
        margin-bottom:6px;">
        <tr>
            <td style="
                width:55%;
                border:1px solid #ccc;
                padding:8px 12px;
                background:#f5f5f5;
                font-size:11px;
                vertical-align:middle;">
                <b>Reference No:</b><br>
                <span style="
                    font-family:'Courier New',monospace;
                    font-weight:bold;
                    color:#6d0f0f;
                    font-size:13px;
                    letter-spacing:1px;">
                    <%= row.refNo %>
                </span>
            </td>
            <td style="
                width:45%;
                border:1px solid #ccc;
                border-left:none;
                padding:8px 12px;
                background:#f5f5f5;
                font-size:11px;
                text-align:right;
                vertical-align:middle;">
                <b>Campus:</b>
                Sta. Mesa (MN0)<br>
                <b>Printed by:</b>
                <%= generatedBy %>
                &nbsp;|&nbsp;
                <b>Date:</b>
                <%= formattedDate %>
            </td>
        </tr>
    </table>

    <%-- ══ TITLE + QR ══ --%>
    <table style="
        width:100%;
        border-collapse:collapse;
        border:1px solid #000;
        margin-bottom:12px;">
        <tr>
            <td style="
                width:75%;
                padding:18px 20px;
                vertical-align:middle;">
                <h2 style="
                    color:#6d0f0f;
                    font-size:20px;
                    font-family:Arial,sans-serif;
                    margin:0;">
                    Student Submission Report
                </h2>
            </td>
            <td style="
                width:25%;
                padding:10px;
                text-align:center;
                vertical-align:middle;
                border-left:1px solid #ccc;">
                <% if (row.qrCode != null
                        && !row.qrCode.isEmpty()) { %>
                <img src="data:image/png;base64,<%=
                        row.qrCode %>"
                     style="width:85px; height:85px;"
                     alt="QR Code">
                <br>
                <span style="
                    font-size:8px; color:#999;">
                    Scan to verify
                </span>
                <% } else { %>
                <span style="
                    font-size:9px; color:#ccc;">
                    No QR
                </span>
                <% } %>
            </td>
        </tr>
    </table>

    <%-- ══ STUDENT INFO ══ --%>
    <table style="
        width:100%;
        border-collapse:collapse;
        margin-bottom:10px;
        font-size:12px;">
        <tr>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;
                background:#f5f5f5;
                font-weight:bold;
                width:160px;">
                Student ID
            </td>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;">
                <%= row.student.getStudentId() %>
            </td>
        </tr>
        <tr>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;
                background:#f5f5f5;
                font-weight:bold;">
                Student Name
            </td>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;">
                <%= row.student.getFormattedName() %>
            </td>
        </tr>
        <tr>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;
                background:#f5f5f5;
                font-weight:bold;">
                Category
            </td>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;">
                <%= row.categoryName %>
            </td>
        </tr>
        <tr>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;
                background:#f5f5f5;
                font-weight:bold;">
                Email
            </td>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;">
                <%= row.student.getEmail() != null
                    ? row.student.getEmail()
                    : "—" %>
            </td>
        </tr>
        <tr>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;
                background:#f5f5f5;
                font-weight:bold;">
                Generated By
            </td>
            <td style="
                border:1px solid #ccc;
                padding:6px 10px;">
                <%= generatedBy %>
            </td>
        </tr>
    </table>

    <%-- ══ REQUIREMENTS STATUS ══ --%>
    <p style="
        text-align:center;
        color:#6d0f0f;
        font-size:13px;
        font-weight:bold;
        margin-bottom:6px;">
        Requirements Status
    </p>

    <table style="
        width:100%;
        border-collapse:collapse;
        font-size:12px;
        margin-bottom:8px;">
        <thead>
            <tr>
                <th style="
                    background:#6d0f0f;
                    color:#fff;
                    padding:6px 10px;
                    text-align:left;
                    border:1px solid #999;
                    width:40px;">#
                </th>
                <th style="
                    background:#6d0f0f;
                    color:#fff;
                    padding:6px 10px;
                    text-align:left;
                    border:1px solid #999;">
                    Requirement
                </th>
                <th style="
                    background:#6d0f0f;
                    color:#fff;
                    padding:6px 10px;
                    text-align:left;
                    border:1px solid #999;
                    width:130px;">
                    Status
                </th>
            </tr>
        </thead>
        <tbody>
        <%
            int rNum = 1;
            for (RequirementType r :
                    row.requirements) {
                boolean ok = false;
                for (Upload u : row.uploads) {
                    if (u.getRequirementId()
                            == r.getRequirementId()
                        && u.getFileName() != null) {
                        ok = true;
                        break;
                    }
                }
                String rowBg = (rNum % 2 == 0)
                    ? "#fafafa" : "#ffffff";
        %>
            <tr>
                <td style="
                    padding:5px 10px;
                    border:1px solid #ccc;
                    background:<%= rowBg %>;">
                    <%= rNum++ %>
                </td>
                <td style="
                    padding:5px 10px;
                    border:1px solid #ccc;
                    background:<%= rowBg %>;">
                    <%= r.getRequirementName() %>
                </td>
                <td style="
                    padding:5px 10px;
                    border:1px solid #ccc;
                    background:<%= rowBg %>;
                    font-weight:bold;
                    color:<%= ok
                        ? "#2e7d32"
                        : "#c62828" %>;">
                    <%= ok
                        ? "Submitted"
                        : "Not Submitted" %>
                </td>
            </tr>
        <%
            } // ✅ end requirements loop
        %>
        </tbody>
    </table>

    <%-- ══ COMPLETION STATUS ══ --%>
    <div style="
        text-align:center;
        font-size:13px;
        margin:8px 0;">
        <b>Completion Status:</b>
        <span style="
            font-weight:bold;
            color:<%= row.isComplete
                ? "#2e7d32" : "#c62828" %>;">
            <%= row.isComplete
                ? "COMPLETED"
                : "INCOMPLETE" %>
        </span>
        <br>
        <span style="font-size:12px; color:#555;">
            Submitted
            <b><%= row.submittedCount %></b>
            of
            <b><%= row.requirements.size() %></b>
            requirements.
        </span>
    </div>

    <%-- ══ PRINT META + SIGNATURE ══ --%>
    <div style="
        font-size:12px;
        margin-top:10px;
        line-height:2.2;">
        <p>
            <b>Printed By:</b>
            <%= generatedBy %>
        </p>
        <p>
            <b>Printed At:</b>
            <%= formattedDate %>
        </p>
        <p>
            Prepared by:
            _____________________________
        </p>
        <p>
            Date:
            _____________________________
        </p>
    </div>

</div>
<%-- ══ END STUDENT BLOCK ══ --%>

<%
    } // ✅ END main for loop
%>

<%-- ✅ PUP FOOTER --%>
<jsp:include page="/includes/print-footer.jsp" />

<script>
window.onload = function() {
    setTimeout(function() {
        window.print();
    }, 800);
};


function closeTab() {
    // Try closing the tab (works if opened via script/target="_blank")
    window.close();

    // Fallback: if browser blocks window.close(), go back
    setTimeout(function() {
        window.location.href =
            '<%= request.getContextPath() %>/students';
    }, 300);
}

</script>

</body>
</html>
