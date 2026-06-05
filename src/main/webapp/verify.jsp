<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="
    model.PrintLog,
    java.text.SimpleDateFormat" %>

<%
    String refNo =
        (String) request.getAttribute("refNo");
    PrintLog log =
        (PrintLog) request.getAttribute("printLog");

    SimpleDateFormat dtf =
        new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    String ctx = request.getContextPath();

    // ✅ Pre-build URLs
    String actionUrl  = ctx + "/verify";
    String dashUrl    = ctx + "/dashboard";
    String inputVal   = (refNo != null) ? refNo : "";

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
<title>Verify Document | ADAMS</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family: 'Segoe UI', sans-serif;
    background: #f4f4f4;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 30px;
}

.verify-card {
    background: #fff;
    border-radius: 8px;
    padding: 40px;
    max-width: 600px;
    width: 100%;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.verify-card h1 {
    color: #6d0f0f;
    font-size: 22px;
    margin-bottom: 8px;
}

.verify-card > p {
    color: #777;
    font-size: 13px;
    margin-bottom: 24px;
}

.search-box {
    display: flex;
    gap: 8px;
    margin-bottom: 24px;
}

.search-box input {
    flex: 1;
    padding: 10px 14px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 13px;
    font-family: 'Courier New', monospace;
    letter-spacing: 1px;
}

.search-box input:focus {
    outline: none;
    border-color: #6d0f0f;
}

.search-box button {
    padding: 10px 20px;
    background: #6d0f0f;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
}

.search-box button:hover {
    background: #5a0c0c;
}

.result-found {
    background: #e8f5e9;
    border: 1px solid #2e7d32;
    border-left: 5px solid #2e7d32;
    border-radius: 4px;
    padding: 20px;
}

.result-found h2 {
    color: #2e7d32;
    font-size: 16px;
    margin-bottom: 14px;
}

.result-not-found {
    background: #ffebee;
    border: 1px solid #c62828;
    border-left: 5px solid #c62828;
    border-radius: 4px;
    padding: 20px;
}

.result-not-found h2 {
    color: #c62828;
    font-size: 16px;
    margin-bottom: 8px;
}

.result-not-found p {
    color: #555;
    font-size: 13px;
    margin-top: 6px;
}

.ref-display {
    font-family: 'Courier New', monospace;
    font-size: 16px;
    font-weight: bold;
    color: #6d0f0f;
    letter-spacing: 2px;
    padding: 10px;
    background: #f9f9f9;
    border: 1px solid #ddd;
    border-radius: 4px;
    text-align: center;
    margin-bottom: 16px;
}

.info-row {
    display: flex;
    gap: 8px;
    margin-bottom: 8px;
    font-size: 13px;
}

.info-label {
    font-weight: bold;
    color: #555;
    width: 150px;
    flex-shrink: 0;
}

.back-link {
    display: inline-block;
    margin-top: 20px;
    color: #6d0f0f;
    text-decoration: none;
    font-size: 13px;
    font-weight: bold;
}

.back-link:hover {
    text-decoration: underline;
}

.vandam-badge {
    text-align: center;
    margin-top: 24px;
    padding-top: 16px;
    border-top: 1px solid #eee;
    font-size: 11px;
    color: #aaa;
}
</style>
</head>
<body class="theme-<%= _theme %>">

<div class="verify-card">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <h1>&#128269; Document Verification</h1>
    <p>
        Enter a reference number to verify
        a document printed by the
        ADAMS - Automated Document Admission Management System.
    </p>

    <%-- ✅ SEARCH FORM --%>
    <form action="<%= actionUrl %>"
          method="get"
          class="search-box">
        <input type="text"
               name="ref"
               value="<%= inputVal %>"
               placeholder=
               "VDM-20260417-S023-MN0-1234567"
               required>
        <button type="submit">
            &#128269; Verify
        </button>
    </form>

    <%-- ✅ RESULT SECTION --%>
    <% if (refNo != null
            && !refNo.trim().isEmpty()) { %>

        <% if (log != null) { %>

        <%-- ✅ FOUND --%>
        <div class="result-found">
            <h2>&#9989; Document Verified</h2>

            <div class="ref-display">
                <%= log.getRefNo() %>
            </div>

            <div class="info-row">
                <span class="info-label">
                    Document Type:
                </span>
                <span>
                    <%= log.getDocumentType()
                        .replace("_", " ") %>
                </span>
            </div>

            <% if (log.getStudentName() != null
                    && !log.getStudentName()
                           .isEmpty()) { %>
            <div class="info-row">
                <span class="info-label">
                    Student:
                </span>
                <span>
                    <%= log.getStudentName() %>
                </span>
            </div>
            <div class="info-row">
                <span class="info-label">
                    Email:
                </span>
                <span>
                    <%= log.getEmail() %>
                </span>
            </div>
            <% } %>

            <div class="info-row">
                <span class="info-label">
                    Printed By:
                </span>
                <span>
                    <%= log.getPrintedByName() %>
                </span>
            </div>

            <div class="info-row">
                <span class="info-label">
                    Printed At:
                </span>
                <span>
                    <%= dtf.format(
                        log.getPrintedAt()) %>
                </span>
            </div>

            <div class="info-row">
                <span class="info-label">
                    Campus:
                </span>
                <span>
                    Sta. Mesa
                    (<%= log.getCampusCode() %>)
                </span>
            </div>
        </div>

        <% } else { %>

        <%-- ❌ NOT FOUND --%>
        <div class="result-not-found">
            <h2>&#10060; Document Not Found</h2>
            <p>
                No document found with reference:
                <b><%= refNo %></b>
            </p>
            <p>
                This document may be invalid
                or not registered in the system.
            </p>
        </div>

        <% } %>
    <% } %>

    <%-- ✅ BACK LINK --%>
    <a href="<%= dashUrl %>"
       class="back-link">
        &#8592; Back to Dashboard
    </a>

    <div class="vandam-badge">
        ADAMS - Automated Document Admission Management System
        &nbsp;|&nbsp;
        Sta. Mesa Campus (MN0)
    </div>

</div>

</body>
</html>
