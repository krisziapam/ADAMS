<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.Student" %>

<%
    Student student = (Student) request.getAttribute("student");
    int submittedCount = (Integer) request.getAttribute("submittedCount");
    int totalRequirements = (Integer) request.getAttribute("totalRequirements");
    boolean isComplete = (Boolean) request.getAttribute("isComplete");
%>

<!DOCTYPE html>
<html>
<head>
    <link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
<title>Report Verification</title>
<style>
body {
    font-family: Arial, sans-serif;
    background: #f4f4f4;
    padding: 40px;
}
.box {
    max-width: 600px;
    margin: auto;
    background: #fff;
    padding: 30px;
    border-radius: 6px;
    box-shadow: 0 2px 10px rgba(0,0,0,.1);
}
.status-ok {
    color: green;
    font-weight: bold;
}
.status-bad {
    color: red;
    font-weight: bold;
}
</style>
</head>
<body>

<%-- ✅ PUP HEADER --%>
<jsp:include page="/includes/print-header.jsp" />

<div class="box">
    <h2>✔ VERIFIED BY SYSTEM</h2>

    <p>
        This document has been verified by the
        <b>ADAMS - Automated Document Admission Management System</b>.
    </p>

    <hr>

    <p><b>Student ID:</b> <%= student.getStudentId() %></p>
    <p><b>Student Name:</b> <%= student.getFormattedName() %></p>

    <p>
        <b>Submission Status:</b>
        <span class="<%= isComplete ? "status-ok" : "status-bad" %>">
            <%= isComplete ? "COMPLETED" : "INCOMPLETE" %>
        </span>
    </p>

    <p>
        Submitted <b><%= submittedCount %></b> of
        <b><%= totalRequirements %></b> requirements.
    </p>

    <hr>

    <p style="font-size:12px; font-style:italic;">
        This page serves as an official verification endpoint.
        If accessed via QR code, the printed report is authentic.
    </p>
</div>

<%-- ✅ PUP FOOTER --%>
<jsp:include page="/includes/print-footer.jsp" />


</body>
</html>
