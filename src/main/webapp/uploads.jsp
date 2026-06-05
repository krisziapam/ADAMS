<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Upload, model.RequirementType, model.Student" %>

<%
    // ===== AUTH CHECK =====
    model.User currentUser = (model.User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ===== STUDENT OBJECT =====
    Student student = (Student) request.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/students?error=Student+not+found");
        return;
    }

    int studentId = student.getStudentId();

    // Safe display values
    String studentName  = student.getFormattedName() != null
                          ? student.getFormattedName() : "-";
    String studentEmail = student.getEmail()        != null
                          ? student.getEmail()       : "-";
    String studentPhone = student.getPhone()        != null
                          ? student.getPhone()       : "-";
    String studentBirth = student.getBirthDate()    != null
                          ? student.getBirthDate().toString() : "Not specified";
    String studentRem   = student.getRemarks()      != null
                          ? student.getRemarks()    : "";

    // ===== REQUIREMENTS & UPLOADS =====
    List<RequirementType> requirements =
        (List<RequirementType>) request.getAttribute("requirements");
    List<Upload> uploadList =
        (List<Upload>) request.getAttribute("uploadList");

    if (requirements == null) requirements = new ArrayList<>();
    if (uploadList    == null) uploadList   = new ArrayList<>();

    // ===== PROGRESS COUNTS =====
    int totalReqs    = requirements.size();
    int uploadedReqs = uploadList.size();
    int percent      = (totalReqs > 0) ? (uploadedReqs * 100 / totalReqs) : 0;
    boolean isComplete = (totalReqs > 0) && (uploadedReqs >= totalReqs);

    // ===== MESSAGES =====
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    String _theme =
        (String) session.getAttribute("theme");
    if (_theme == null) _theme = "normal";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
    <link rel="stylesheet"
      href="<%= request.getContextPath()
      %>/css/themes.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Documents | ADAMS</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }

        body {
            font-family:'Segoe UI', Arial, sans-serif;
            background:#f4f4f4;
        }

        .main {
            padding:30px;
            max-width:1050px;
            margin:0 auto;
        }

        /* ── BACK BUTTON ── */
        .btn-back {
            display:inline-block;
            margin-bottom:20px;
            padding:8px 16px;
            background:#555;
            color:#fff;
            text-decoration:none;
            border-radius:4px;
            font-size:13px;
            transition:background 0.2s;
        }
        .btn-back:hover { background:#333; }

        /* ── PAGE HEADER ── */
        .page-header h2 {
            color:#6b0000;
            font-size:22px;
            margin-bottom:14px;
        }

        /* ── STUDENT INFO CARD ── */
        .student-card {
            background:#fff;
            border-radius:8px;
            box-shadow:0 2px 6px rgba(0,0,0,0.1);
            overflow:hidden;
            margin-bottom:20px;
        }
        .student-card-header {
            background:#6d0f0f;
            color:#fff;
            padding:12px 16px;
            font-weight:600;
            font-size:14px;
            display:flex;
            justify-content:space-between;
            align-items:center;
        }
        .student-card-body {
            padding:16px;
            display:flex;
            flex-wrap:wrap;
            gap:16px;
        }
        .student-field {
            display:flex;
            flex-direction:column;
            min-width:150px;
            flex:1;
        }
        .field-label {
            font-size:11px;
            font-weight:700;
            color:#6d0f0f;
            text-transform:uppercase;
            margin-bottom:3px;
        }
        .field-value {
            font-size:13px;
            color:#333;
        }

        /* ── PROGRESS ── */
        .progress-wrapper {
            width:100%;
            margin-top:8px;
            padding-top:12px;
            border-top:1px solid #f0f0f0;
        }
        .progress-label {
            font-size:12px;
            color:#555;
            margin-bottom:6px;
            display:flex;
            justify-content:space-between;
        }
        .progress-track {
            width:100%;
            background:#eee;
            border-radius:20px;
            height:10px;
            overflow:hidden;
        }
        .progress-fill {
            height:100%;
            background:#6d0f0f;
            border-radius:20px;
            transition:width 0.3s ease;
        }

        /* ── STATUS BADGE ── */
        .status-badge {
            padding:4px 12px;
            border-radius:20px;
            font-size:12px;
            font-weight:bold;
        }
        .status-complete { background:#e8f5e9; color:#2e7d32; }
        .status-missing  { background:#fdecea; color:#b71c1c; }

        /* ── ALERTS ── */
        .alert-success {
            background:#e8f5e9;
            color:#2e7d32;
            padding:10px 15px;
            border-left:4px solid #2e7d32;
            border-radius:4px;
            margin-bottom:15px;
            font-size:13px;
        }
        .alert-error {
            background:#fdecea;
            color:#b71c1c;
            padding:10px 15px;
            border-left:4px solid #b71c1c;
            border-radius:4px;
            margin-bottom:15px;
            font-size:13px;
        }

        /* ── TABLE ── */
        table {
            width:100%;
            border-collapse:collapse;
            background:#fff;
            border-radius:8px;
            overflow:hidden;
            box-shadow:0 2px 4px rgba(0,0,0,0.1);
        }
        thead { background:#6b0000; color:#fff; }
        thead th {
            padding:12px 15px;
            text-align:left;
            font-size:13px;
        }
        tbody tr { border-bottom:1px solid #eee; }
        tbody tr:hover { background:#fdf5f5; }
        tbody td {
            padding:12px 15px;
            font-size:13px;
            vertical-align:middle;
        }

        /* ── ROW BADGES ── */
        .badge-submitted {
            background:#e8f5e9;
            color:#2e7d32;
            padding:4px 10px;
            border-radius:20px;
            font-size:12px;
            font-weight:bold;
            white-space:nowrap;
        }
        .badge-missing {
            background:#fdecea;
            color:#b71c1c;
            padding:4px 10px;
            border-radius:20px;
            font-size:12px;
            font-weight:bold;
            white-space:nowrap;
        }

        /* ── BUTTONS ── */
        .btn {
            padding:6px 12px;
            border:none;
            border-radius:4px;
            cursor:pointer;
            font-size:12px;
            text-decoration:none;
            display:inline-block;
            transition:background 0.2s;
        }
        .btn-upload {
            background:#6b0000;
            color:#fff;
        }
        .btn-upload:hover { background:#8b0000; }

        .btn-view {
            background:#1565c0;
            color:#fff;
        }
        .btn-view:hover { background:#0d47a1; }

        /* ── UPLOAD + VIEW CELL ── */
        .action-cell {
            display:flex;
            align-items:center;
            gap:8px;
            flex-wrap:wrap;
        }
        .upload-form {
            display:flex;
            align-items:center;
            gap:6px;
            flex-wrap:wrap;
        }
        .upload-form input[type="file"] { font-size:12px; }

        .empty-row td {
            text-align:center;
            color:#999;
            padding:24px;
        }

        /* ── FILE PREVIEW MODAL ── */
        .modal {
            display:none;
            position:fixed;
            inset:0;
            background:rgba(0,0,0,0.65);
            justify-content:center;
            align-items:center;
            z-index:9999;
            padding:16px;
        }
        .modal.show { display:flex; }
        .modal-content {
            background:#fff;
            width:min(780px, 95vw);
            max-height:90vh;
            border-radius:8px;
            overflow:hidden;
            box-shadow:0 12px 40px rgba(0,0,0,0.4);
            display:flex;
            flex-direction:column;
        }
        .modal-header {
            background:#6d0f0f;
            color:#fff;
            padding:12px 16px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            font-weight:600;
            font-size:14px;
            flex-shrink:0;
        }
        .modal-body {
            flex:1;
            overflow:auto;
            padding:0;
            display:flex;
            flex-direction:column;
        }
        .modal-footer {
            padding:12px 16px;
            display:flex;
            justify-content:flex-end;
            gap:10px;
            border-top:1px solid #eee;
            flex-shrink:0;
        }

        /* file preview area */
        #previewFrame {
            width:100%;
            flex:1;
            min-height:420px;
            border:none;
        }
        #previewImg {
            max-width:100%;
            max-height:500px;
            display:block;
            margin:16px auto;
            border-radius:4px;
        }
        #previewUnsupported {
            padding:30px;
            text-align:center;
            color:#555;
            font-size:14px;
        }

        .close-x {
            background:transparent;
            border:none;
            color:#fff;
            font-size:20px;
            cursor:pointer;
            line-height:1;
        }

        .btn-download {
            background:#2e7d32;
            color:#fff;
        }
        .btn-download:hover { background:#1b5e20; }

        .btn-close-modal {
            background:#6c757d;
            color:#fff;
        }
        .btn-close-modal:hover { background:#5a6268; }

        /* uploaded-at note */
        .uploaded-note {
            font-size:11px;
            color:#888;
            margin-top:3px;
        }
    </style>
</head>
<body class="theme-<%= _theme %>">

<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <!-- BACK BUTTON -->
    <a href="<%= request.getContextPath() %>/students" class="btn-back">
        &#8592; Back to Students
    </a>

    <!-- PAGE HEADER -->
    <div class="page-header">
        <h2>Upload Documents</h2>
    </div>

    <!-- ═══════════════════════════════
         STUDENT INFO CARD
    ═══════════════════════════════ -->
    <div class="student-card">
        <div class="student-card-header">
            <span>&#128100; Student Information</span>
            <span class="status-badge <%= isComplete ? "status-complete" : "status-missing" %>">
                <%= isComplete ? "&#10003; Complete" : "&#10007; Incomplete" %>
            </span>
        </div>
        <div class="student-card-body">

            <div class="student-field">
                <span class="field-label">Student ID</span>
                <span class="field-value">#<%= studentId %></span>
            </div>
            <div class="student-field">
                <span class="field-label">Full Name</span>
                <span class="field-value"><%= studentName %></span>
            </div>
            <div class="student-field">
                <span class="field-label">Email</span>
                <span class="field-value"><%= studentEmail %></span>
            </div>
            <div class="student-field">
                <span class="field-label">Phone</span>
                <span class="field-value"><%= studentPhone %></span>
            </div>
            <div class="student-field">
                <span class="field-label">Birth Date</span>
                <span class="field-value"><%= studentBirth %></span>
            </div>
            <% if (!studentRem.isEmpty()) { %>
            <div class="student-field">
                <span class="field-label">Remarks</span>
                <span class="field-value"><%= studentRem %></span>
            </div>
            <% } %>

            <!-- PROGRESS BAR -->
            <div class="progress-wrapper">
                <div class="progress-label">
                    <span>Documents Submitted:
                        <b><%= uploadedReqs %></b> / <b><%= totalReqs %></b>
                    </span>
                    <span><b><%= percent %>%</b></span>
                </div>
                <div class="progress-track">
                    <div class="progress-fill"
                         style="width:<%= percent %>%;"></div>
                </div>
            </div>

        </div>
    </div>

    <!-- ALERTS -->
    <% if (success != null && !success.isEmpty()) { %>
        <div class="alert-success">&#10003; <%= success %></div>
    <% } %>
    <% if (error != null && !error.isEmpty()) { %>
        <div class="alert-error">&#10007; <%= error %></div>
    <% } %>

    <!-- ═══════════════════════════════
         REQUIREMENTS TABLE
    ═══════════════════════════════ -->
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Requirement</th>
                <th>Status</th>
                <th>Uploaded File</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>

        <% if (requirements.isEmpty()) { %>
            <tr class="empty-row">
                <td colspan="5">No requirements found.</td>
            </tr>
        <% } %>

        <%
            int rowNum = 1;
            for (RequirementType req : requirements) {

                // Find matching upload for this requirement
                Upload matchedUpload = null;
                for (Upload u : uploadList) {
                    if (u.getRequirementId() == req.getRequirementId()) {
                        matchedUpload = u;
                        break;
                    }
                }
                boolean uploaded = (matchedUpload != null);
        %>
            <tr>
                <!-- ROW # -->
                <td><%= rowNum++ %></td>

                <!-- REQUIREMENT NAME -->
                <td><%= req.getRequirementName() %></td>

                <!-- STATUS -->
                <td>
                    <% if (uploaded) { %>
                        <span class="badge-submitted">&#10003; Submitted</span>
                        <% if (matchedUpload.getUploadedAt() != null) { %>
                            <div class="uploaded-note">
                                <%= matchedUpload.getUploadedAt() %>
                            </div>
                        <% } %>
                    <% } else { %>
                        <span class="badge-missing">&#10007; Missing</span>
                    <% } %>
                </td>

                <!-- UPLOADED FILE NAME -->
                <td>
                    <% if (uploaded) { %>
                        <span style="font-size:12px; color:#333;">
                            &#128196; <%= matchedUpload.getFileName() %>
                        </span>
                    <% } else { %>
                        <span style="font-size:12px; color:#bbb;">
                            — No file yet
                        </span>
                    <% } %>
                </td>

                <!-- ACTIONS: VIEW + UPLOAD -->
                <td>
                    <div class="action-cell">

                        <!-- VIEW BUTTON — only if file exists -->
                        <% if (uploaded) { %>
                            <button type="button"
                                    class="btn btn-view"
                                    onclick="openPreview(
                                        '<%= req.getRequirementName()
                                              .replace("'", "\\'") %>',
                                        '<%= request.getContextPath() %>/view-file?studentId=<%= studentId %>&requirementId=<%= req.getRequirementId() %>',
                                        '<%= matchedUpload.getFileName()
                                              .replace("'", "\\'") %>'
                                    )">
                                &#128065; View
                            </button>
                        <% } %>

                        <!-- UPLOAD FORM — with client-side validation -->
                        <form class="upload-form"
                            action="<%= request.getContextPath() %>/upload-file"
                            method="post"
                            enctype="multipart/form-data"
                            onsubmit="return validateFile(this)">
                            <input type="hidden" name="studentId"
                                value="<%= studentId %>">
                            <input type="hidden" name="requirementId"
                                value="<%= req.getRequirementId() %>">
                            <input type="file" name="file" required
                                accept=".jpg,.jpeg,.png,.pdf"
                                onchange="previewFileName(this)">
                            <button type="submit" class="btn btn-upload">
                                <%= uploaded ? "&#8593; Replace" : "&#8593; Upload" %>
                            </button>
                        </form>

                    </div>
                </td>
            </tr>
        <% } %>

        </tbody>
    </table>

</div><!-- end .main -->


<!-- ═══════════════════════════════════════
     FILE PREVIEW MODAL
═══════════════════════════════════════ -->
<div id="previewModal" class="modal"
     onclick="if(event.target===this) closePreview()">
    <div class="modal-content" onclick="event.stopPropagation()">

        <div class="modal-header">
            <span id="previewTitle">File Preview</span>
            <button class="close-x" onclick="closePreview()">×</button>
        </div>

        <div class="modal-body" id="previewBody">
            <!-- content injected by JS -->
        </div>

        <div class="modal-footer">
            <a id="downloadLink" href="#" download
               class="btn btn-download">
                &#11015; Download
            </a>
            <button class="btn btn-close-modal"
                    onclick="closePreview()">Close</button>
        </div>

    </div>
</div>


<script>
// ── OPEN PREVIEW MODAL ──
function openPreview(reqName, fileUrl, fileName) {

    document.getElementById('previewTitle').textContent =
        '📄 ' + reqName + ' — ' + fileName;

    document.getElementById('downloadLink').href     = fileUrl;
    document.getElementById('downloadLink').download = fileName;

    const body = document.getElementById('previewBody');
    body.innerHTML = ''; // clear previous

    // Detect file type by extension
    const ext = fileName.split('.').pop().toLowerCase();

    if (['jpg','jpeg','png','gif','bmp','webp'].includes(ext)) {
        // ── IMAGE PREVIEW ──
        const img = document.createElement('img');
        img.id  = 'previewImg';
        img.src = fileUrl;
        img.alt = fileName;
        body.appendChild(img);

    } else if (ext === 'pdf') {
        // ── PDF PREVIEW ──
        const iframe = document.createElement('iframe');
        iframe.id  = 'previewFrame';
        iframe.src = fileUrl;
        body.appendChild(iframe);

    } else {
        // ── UNSUPPORTED — show download prompt ──
        const div = document.createElement('div');
        div.id = 'previewUnsupported';
        div.innerHTML =
            '<p style="font-size:40px; margin-bottom:12px;">📁</p>' +
            '<p><b>' + fileName + '</b></p>' +
            '<p style="margin-top:8px; color:#888;">'+
            'Preview not available for this file type.<br>' +
            'Use the Download button below to open it.</p>';
        body.appendChild(div);
    }

    document.getElementById('previewModal').classList.add('show');
}

// ── CLOSE PREVIEW MODAL ──
function closePreview() {
    document.getElementById('previewModal').classList.remove('show');
    document.getElementById('previewBody').innerHTML = ''; // stop any streams
}

// ── ESC KEY CLOSES MODAL ──
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closePreview();
});

// ── FILE VALIDATION BEFORE SUBMIT ──
function validateFile(form) {
    const input    = form.querySelector('input[type="file"]');
    const file     = input.files[0];

    if (!file) {
        showAlert('Please select a file first.', 'warning');
        return false;
    }

    // 1. Check extension
    const allowedExt  = ['jpg', 'jpeg', 'png', 'pdf'];
    const ext = file.name.split('.').pop().toLowerCase();

    if (!allowedExt.includes(ext)) {
        alert('❌ Invalid file type: ".' + ext + '"\n\nOnly these are allowed:\n• .jpg\n• .jpeg\n• .png\n• .pdf');
        input.value = '';
        return false;
    }

    // 2. Check filename for special characters
    //    Get name without extension
    const nameWithoutExt = file.name
        .substring(0, file.name.lastIndexOf('.'));

    const validName = /^[a-zA-Z0-9 _\-]+$/.test(nameWithoutExt);

    if (!validName) {
        alert('❌ Invalid file name: "' + file.name + '"\n\n'
            + 'File names may only contain:\n'
            + '• Letters (a-z, A-Z)\n'
            + '• Numbers (0-9)\n'
            + '• Underscore ( _ )\n'
            + '• Hyphen ( - )\n\n'
            + 'Please rename your file and try again.');
        input.value = '';
        return false;
    }

    // 3. Check file size (10MB)
    if (file.size > 10 * 1024 * 1024) {
        alert('❌ File too large.\n\nMaximum allowed size is 10MB.\nYour file: '
            + (file.size / 1024 / 1024).toFixed(2) + 'MB');
        input.value = '';
        return false;
    }

    return true; // ✅ All good — allow submit
}
</script>

<%@ include file="includes/modal-system.jsp" %>
</body>
</html>
