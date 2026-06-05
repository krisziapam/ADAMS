<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="
    java.util.*,
    java.text.SimpleDateFormat,
    model.StudentReportRow,
    model.RequirementType" %>

<%
    /* =========================
       DATA
       ========================= */
    List<StudentReportRow> rows =
        (List<StudentReportRow>)
        request.getAttribute("reportRows");

    List<RequirementType> requirements =
        (List<RequirementType>)
        request.getAttribute("requirements");

    Integer _total      =
        (Integer) request.getAttribute("totalStudents");
    Integer _complete   =
        (Integer) request.getAttribute("totalComplete");
    Integer _incomplete =
        (Integer) request.getAttribute("totalIncomplete");
    Integer _rate       =
        (Integer) request.getAttribute("completionRate");

    int totalStudents   =
        _total      != null ? _total      : 0;
    int totalComplete   =
        _complete   != null ? _complete   : 0;
    int totalIncomplete =
        _incomplete != null ? _incomplete : 0;
    int completionRate  =
        _rate       != null ? _rate       : 0;

    String generatedBy =
        (String) request.getAttribute("generatedBy");
    Date generatedAt   =
        (Date)   request.getAttribute("generatedAt");

    SimpleDateFormat dtf =
        new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    if (rows         == null) rows         = new ArrayList<>();
    if (requirements == null) requirements = new ArrayList<>();
    if (generatedBy  == null) generatedBy  = "—";
    if (generatedAt  == null) generatedAt  = new Date();

    int rowsPerPage = 20;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>All Students Report | ADAMS</title>
<style>

* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family: Arial, sans-serif;
    background: #fff;
    color: #000;
    padding: 10px 20px;
}

/* BUTTONS */
.btn-secondary { background:#6c757d; color:#fff; }

.no-print {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-bottom: 16px;
}
.no-print a,
.no-print button {
    padding: 8px 18px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    display: inline-block;
}
.btn-print { background:#6d0f0f; color:#fff; }
.btn-pdf   { background:#2e7d32; color:#fff; }

/* GENERATED HEADER */
.gen-header {
    width:100%; border-collapse:collapse;
    margin-bottom:6px;
}
.gen-header td {
    background:#f5f5f5; border:1px solid #ccc;
    padding:6px 10px; font-size:11px; color:#333;
}

/* TITLE */
.title-table {
    width:100%; border-collapse:collapse;
    border:1px solid #000; margin-bottom:20px;
}
.title-table .title-cell {
    padding:18px 22px; vertical-align:middle;
}
.title-table h1 {
    font-size:22px; font-weight:bold;
    color:#6d0f0f; margin:0;
}
.title-table .sub {
    font-size:12px; color:#555; margin-top:4px;
}

/* STATS */
.stats-table {
    width:100%; border-collapse:collapse;
    margin-bottom:20px; font-size:13px;
}
.stats-table td {
    border:1px solid #ccc; padding:8px 12px;
}
.stats-table .label {
    background:#f5f5f5; font-weight:bold; width:200px;
}

/* TABLE */
.report-table {
    width:100%; border-collapse:collapse;
    font-size:12px; margin-bottom:20px;
    table-layout:fixed;
}
.report-table th {
    background:#6d0f0f; color:#fff;
    padding:8px 10px; text-align:left;
    border:1px solid #999;
}
.report-table td {
    padding:7px 10px; border:1px solid #999;
    text-align:left; word-wrap:break-word;
}
.report-table tr:nth-child(even) td {
    background:#fafafa;
}

/* STATUS */
.status-complete   { color:#2e7d32; font-weight:bold; }
.status-incomplete { color:#c62828; font-weight:bold; }

/* VERIFIED */
.verified {
    text-align:center;
    border-top:1px solid #ccc;
    border-bottom:1px solid #ccc;
    padding:10px; margin-top:20px;
}
.verified p:first-child {
    font-weight:bold; font-size:13px; color:#6d0f0f;
}
.verified p:last-child {
    font-size:11px; font-style:italic;
    color:#555; margin-top:4px;
}

/* SIGNATURE */
.signature {
    margin-top:30px; font-size:13px; line-height:2.2;
}

/* PAGE BREAK */
.page-break {
    page-break-after: always;
}

/* PRINT FOOTER */
.print-footer { display:none; }

/* PRINT */
@media print {

    /* ✅ TIGHTER — accounts for PUP header + fixed footer */
    @page {
        size: A4;
        margin-top:    0.5cm;
        margin-bottom: 2cm;
        margin-left:   1.27cm;
        margin-right:  1.27cm;
    }

    .no-print { display:none !important; }

    * {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }

    body { padding-bottom: 80px; }

    .report-table tr {
        page-break-inside: avoid;
    }

    .print-footer {
        display: block;
        position: fixed;
        bottom: 0; left: 0; right: 0;
        height: 1cm;
        background: #fff;
        text-align: center;
        font-size: 10px;
        color: #555;
        padding-top: 6px;
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
        margin-bottom: 1px;
    }

    .footer-meta {
        font-style: italic;
        font-size: 9px;
    }
}
</style>
</head>
<body>

<%-- ══ BUTTONS ══ --%>
<div class="no-print">
    <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-secondary">
        &#8592; Back to Dashboard
    </a>
    <button class="btn-print"
            onclick="window.print()">
        🖨 Print
    </button>
    <a href="<%= request.getContextPath()
    %>/dashboard-report-pdf"
       class="btn-pdf">
        📥 Download PDF
    </a>
</div>

<%-- ✅ PUP HEADER --%>
<jsp:include page="/includes/print-header.jsp" />

<%-- ══ GENERATED ON ══ --%>
<table class="gen-header">
    <tr>
        <td>
            <b>Generated on:</b>
            <%= dtf.format(generatedAt) %>
            &nbsp;|&nbsp;
            <b>Generated by:</b>
            <%= generatedBy %>
        </td>
    </tr>
</table>

<%-- ══ TITLE ══ --%>
<table class="title-table">
    <tr>
        <td class="title-cell">
            <h1>All Students Submission Report</h1>
            <p class="sub">
                ADAMS - Automated Document Admission Management System
                — Read-Only Summary
            </p>
        </td>
    </tr>
</table>

<%-- ══ STATS ══ --%>
<table class="stats-table">
    <tr>
        <td class="label">Total Students</td>
        <td><%= totalStudents %></td>
        <td class="label">Completion Rate</td>
        <td><b><%= completionRate %>%</b></td>
    </tr>
    <tr>
        <td class="label">Completed</td>
        <td class="status-complete">
            <%= totalComplete %>
        </td>
        <td class="label">Incomplete</td>
        <td class="status-incomplete">
            <%= totalIncomplete %>
        </td>
    </tr>
</table>

<%-- ══ MAIN TABLE ══ --%>
<%
    boolean tableOpen = false;
    int rowCount = 0;

    if (rows.isEmpty()) {
%>
<table class="report-table"
       style="table-layout:fixed; width:100%;">
    <colgroup>
        <col style="width:5%;">
        <col style="width:22%;">
        <col style="width:15%;">
        <col style="width:28%;">
        <col style="width:12%;">
        <col style="width:15%;">
    </colgroup>
    <thead>
        <tr>
            <th>#</th>
            <th>Student Name</th>
            <th>Category</th>
            <th>Email</th>
            <th>Submitted</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td colspan="6"
                style="text-align:center;
                       color:#999; padding:20px;">
                No students found.
            </td>
        </tr>
    </tbody>
</table>

<%
    } else {

        for (int idx = 0; idx < rows.size(); idx++) {

            StudentReportRow row = rows.get(idx);

            // ✅ Open new table every 20 rows
            if (idx % rowsPerPage == 0) {

                // Close previous table if open
                if (tableOpen) {
%>
    </tbody>
</table>

<%-- PAGE BREAK --%>
<div class="page-break"></div>

<%
                }
%>

<%-- ✅ TABLE HEADER (repeats every page) --%>
<table class="report-table"
       style="table-layout:fixed; width:100%;">
    <colgroup>
        <col style="width:5%;">
        <col style="width:22%;">
        <col style="width:15%;">
        <col style="width:28%;">
        <col style="width:12%;">
        <col style="width:15%;">
    </colgroup>
    <thead>
        <tr>
            <th>#</th>
            <th>Student Name</th>
            <th>Category</th>
            <th>Email</th>
            <th>Submitted</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>

<%
                tableOpen = true;
            }

            // ✅ Cap submitted at total
            int safeSubmitted = (row.totalRequirements > 0)
                ? Math.min(row.submittedCount,
                           row.totalRequirements)
                : row.submittedCount;

            boolean isComplete =
                row.totalRequirements > 0
                && safeSubmitted >= row.totalRequirements;
%>
        <tr>
            <td style="border:1px solid #999; padding:7px;">
                <%= idx + 1 %>
            </td>
            <td style="border:1px solid #999; padding:7px;
                       word-wrap:break-word;">
                <%= row.studentName %>
            </td>
            <td style="border:1px solid #999; padding:7px;
                       word-wrap:break-word;">
                <%= row.categoryName %>
            </td>
            <td style="border:1px solid #999; padding:7px;
                       word-wrap:break-word; font-size:11px;">
                <%= row.email %>
            </td>
            <td style="border:1px solid #999; padding:7px;
                       text-align:center;">
                <%= safeSubmitted %>
                /
                <%= row.totalRequirements %>
            </td>
            <td style="border:1px solid #999; padding:7px;
                font-weight:bold;
                color:<%= isComplete
                    ? "#2e7d32" : "#c62828" %>;">
                <%= isComplete ? "COMPLETED" : "INCOMPLETE" %>
            </td>
        </tr>

<%
        } // end for

        if (tableOpen) {
%>
    </tbody>
</table>
<%
        }
    }
%>

<%-- ══ SIGNATURE ══ --%>
<div class="signature">
    <p>Prepared by: _____________________________</p>
    <p>Date: ____________________________________</p>
</div>

<%-- ✅ PUP FOOTER (replaces old print-footer div) --%>
<jsp:include page="/includes/print-footer.jsp" />



</body>
</html>
