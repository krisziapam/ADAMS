<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Name Migration Tool - ADAMS</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        * { box-sizing: border-box; }
        body { background: #f4f4f4; font-family: 'Segoe UI', sans-serif; }

        .migration-container { max-width: 1300px; margin: 30px auto; padding: 0 20px; }

        /* ── Header ── */
        .migration-header {
            background: linear-gradient(135deg, #800000, #5c0000);
            color: white; padding: 25px 30px;
            border-radius: 10px 10px 0 0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .migration-header h2 { margin: 0; font-size: 1.4em; }

        /* ── Stats Cards ── */
        .stats-row {
            display: flex; gap: 15px; padding: 20px 30px;
            background: white; border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }
        .stat-card {
            flex: 1; padding: 15px; border-radius: 8px;
            text-align: center; border: 1px solid #eee;
        }
        .stat-card.done { background: #d4edda; border-color: #c3e6cb; }
        .stat-card.pending { background: #fff3cd; border-color: #ffeaa7; }
        .stat-card.archived { background: #e8eaf6; border-color: #c5cae9; }
        .stat-number { font-size: 2em; font-weight: bold; }
        .stat-label { font-size: 0.85em; color: #666; margin-top: 5px; }

        /* ── Progress Bar ── */
        .progress-section { padding: 15px 30px; background: white;
            border-left: 1px solid #ddd; border-right: 1px solid #ddd; }
        .progress-bar-container {
            background: #eee; border-radius: 20px; height: 30px;
            overflow: hidden; position: relative;
        }
        .progress-bar-fill {
            height: 100%; border-radius: 20px;
            background: linear-gradient(90deg, #28a745, #20c997);
            transition: width 0.5s ease; display: flex;
            align-items: center; justify-content: center;
            color: white; font-weight: bold; font-size: 0.85em;
            min-width: 40px;
        }

        /* ── Tabs ── */
        .tab-row {
            display: flex; gap: 0; padding: 0 30px;
            background: white; border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }
        .tab-btn {
            padding: 12px 25px; cursor: pointer;
            border: none; background: #f0f0f0; font-size: 0.95em;
            border-bottom: 3px solid transparent; color: #666;
        }
        .tab-btn.active {
            background: white; color: #800000;
            border-bottom: 3px solid #800000; font-weight: bold;
        }
        .tab-btn:hover { background: #f9f9f9; }
        .tab-badge {
            background: #800000; color: white; padding: 2px 8px;
            border-radius: 10px; font-size: 0.8em; margin-left: 5px;
        }
        .tab-badge.zero { background: #28a745; }

        /* ── Table ── */
        .content-area {
            padding: 20px 30px; background: white;
            border: 1px solid #ddd; border-top: none;
            border-radius: 0 0 10px 10px;
        }
        table { width: 100%; border-collapse: collapse; }
        th {
            background: #f8f8f8; padding: 12px 10px;
            text-align: left; border-bottom: 2px solid #ddd;
            font-size: 0.9em; color: #555;
        }
        td { padding: 10px; border-bottom: 1px solid #eee; vertical-align: middle; }
        tr:hover { background: #fafafa; }

        .original-name {
            background: #fff3cd; padding: 6px 12px;
            border-radius: 4px; font-weight: bold;
            font-size: 0.9em; display: inline-block;
        }
        .preview-name {
            color: #28a745; font-weight: bold;
            font-size: 0.85em; margin-top: 4px;
        }

        input[type="text"] {
            width: 100%; padding: 8px 10px; border: 1px solid #ccc;
            border-radius: 5px; font-size: 0.9em;
            transition: border-color 0.2s;
        }
        input[type="text"]:focus {
            border-color: #800000; outline: none;
            box-shadow: 0 0 4px rgba(128,0,0,0.2);
        }

        /* ── Buttons ── */
        .btn-migrate {
            background: #800000; color: white; padding: 12px 30px;
            border: none; border-radius: 6px; font-size: 1em;
            cursor: pointer; font-weight: bold;
        }
        .btn-migrate:hover { background: #5c0000; }
        .btn-back {
            background: #6c757d; color: white; padding: 10px 20px;
            border: none; border-radius: 6px; cursor: pointer;
            text-decoration: none; display: inline-block;
        }
        .btn-back:hover { background: #5a6268; }

        /* ── Alerts ── */
        .success-msg {
            background: #d4edda; color: #155724; padding: 15px;
            border-radius: 6px; margin-bottom: 15px;
            border: 1px solid #c3e6cb; font-weight: 500;
        }
        .all-done { text-align: center; padding: 60px 20px; }
        .all-done h3 { font-size: 1.5em; color: #155724; }
        .all-done p { color: #666; }

        .hint-text { color: #888; font-size: 0.85em; margin-bottom: 15px; }
    </style>
</head>
<body>

<div class="migration-container">

    <!-- ══ Header ══ -->
    <div class="migration-header">
        <h2>📝 Name Migration Tool</h2>
        <a href="students" class="btn-back">← Back to Students</a>
    </div>

    <!-- ══ Stats Cards ══ -->
    <div class="stats-row">
        <div class="stat-card done">
            <div class="stat-number">${alreadyMigrated}</div>
            <div class="stat-label">✅ Students Migrated</div>
        </div>
        <div class="stat-card pending">
            <div class="stat-number">${activeCount}</div>
            <div class="stat-label">⏳ Students Pending</div>
        </div>
        <div class="stat-card done">
            <div class="stat-number">${archivedMigrated}</div>
            <div class="stat-label">✅ Archived Migrated</div>
        </div>
        <div class="stat-card archived">
            <div class="stat-number">${archivedCount}</div>
            <div class="stat-label">📦 Archived Pending</div>
        </div>
    </div>

    <!-- ══ Progress Bar ══ -->
    <div class="progress-section">
        <c:set var="totalAll" value="${totalStudents + totalArchived}" />
        <c:set var="migratedAll" value="${alreadyMigrated + archivedMigrated}" />
        <c:set var="pct" value="${totalAll > 0 ? Math.round(migratedAll * 100.0 / totalAll) : 100}" />
        <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
            <span style="font-weight:bold; color:#333;">Overall Progress</span>
            <span style="color:#666;">${migratedAll} / ${totalAll} records</span>
        </div>
        <div class="progress-bar-container">
            <div class="progress-bar-fill" style="width: ${pct}%">
                ${pct}%
            </div>
        </div>
    </div>

    <!-- ══ Tabs ══ -->
    <div class="tab-row">
        <a href="name-migration?tab=active" class="tab-btn ${tab == 'active' ? 'active' : ''}">
            📋 Active Students
            <span class="tab-badge ${activeCount == 0 ? 'zero' : ''}">${activeCount}</span>
        </a>
        <a href="name-migration?tab=archived" class="tab-btn ${tab == 'archived' ? 'active' : ''}">
            📦 Archived Students
            <span class="tab-badge ${archivedCount == 0 ? 'zero' : ''}">${archivedCount}</span>
        </a>
    </div>

    <!-- ══ Content Area ══ -->
    <div class="content-area">

        <c:if test="${migratedCount != null}">
            <div class="success-msg">
                ✅ Successfully migrated <strong>${migratedCount}</strong> record(s)!
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty unparsedStudents}">
                <div class="all-done">
                    <h3>🎉 All Done!</h3>
                    <p>All <strong>${tab == 'archived' ? 'archived' : 'active'}</strong>
                       student records have been migrated.</p>
                    <c:if test="${tab == 'active' && archivedCount > 0}">
                        <p style="margin-top:15px;">
                            📦 <a href="name-migration?tab=archived"
                                  style="color:#800000; font-weight:bold;">
                                ${archivedCount} archived record(s)</a> still need migration.
                        </p>
                    </c:if>
                    <a href="students" class="btn-back" style="margin-top:20px;">← Back to Students</a>
                </div>
            </c:when>

            <c:otherwise>
                <p class="hint-text">
                    🧠 Names are <strong>auto-suggested</strong> by our smart parser.
                    <strong>Review and correct</strong> before saving —
                    especially multi-word surnames
                    (e.g., <em>Dela Cruz</em>, <em>De Leon</em>, <em>San Juan</em>).
                </p>

                <form method="post" action="name-migration">
                    <input type="hidden" name="tab" value="${tab}">
                    <input type="hidden" name="page" value="${currentPage}">
                    <table>
                        <thead>
                            <tr>
                                <th style="width:4%">#</th>
                                <th style="width:6%">ID</th>
                                <th style="width:22%">Original Name</th>
                                <th style="width:18%">Last Name *</th>
                                <th style="width:18%">First Name *</th>
                                <th style="width:14%">Middle Name</th>
                                <th style="width:18%">Preview</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="student" items="${unparsedStudents}" varStatus="idx">
                                <tr>
                                    <td>${idx.index + 1}</td>
                                    <td>${student.studentId}</td>
                                    <td>
                                        <span class="original-name">
                                            ${student.studentName}
                                        </span>
                                        <input type="hidden" name="studentId"
                                               value="${student.studentId}">
                                    </td>
                                    <td>
                                        <input type="text" name="lastName"
                                               value="${suggestions[idx.index][0]}"
                                               required
                                               oninput="updatePreview(this)">
                                    </td>
                                    <td>
                                        <input type="text" name="firstName"
                                               value="${suggestions[idx.index][1]}"
                                               required
                                               oninput="updatePreview(this)">
                                    </td>
                                    <td>
                                        <input type="text" name="middleName"
                                               value="${suggestions[idx.index][2]}"
                                               oninput="updatePreview(this)">
                                    </td>
                                    <td>
                                        <div class="preview-name">
                                            ${previews[idx.index]}
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <div style="display:flex; justify-content:space-between;
                                align-items:center; margin-top:20px;">
                        <div>
                            <a href="students" class="btn-back">Cancel</a>
                            <span style="margin-left:15px; color:#666;">
                                Page ${currentPage} of ${totalPages}
                                (${totalRecords} total records)
                            </span>
                        </div>
                        <button type="submit" class="btn-migrate">
                            ✅ Migrate ${unparsedStudents.size()} Record(s)
                        </button>
                    </div>
                </form>

                <%-- ── Pagination Controls ── --%>
                <c:if test="${totalPages > 1}">
                    <div style="display:flex; justify-content:center;
                                gap:5px; margin-top:20px; flex-wrap:wrap;">

                        <%-- Previous --%>
                        <c:if test="${currentPage > 1}">
                            <a href="name-migration?tab=${tab}&page=${currentPage - 1}"
                               style="padding:8px 14px; border:1px solid #ddd;
                                      border-radius:5px; text-decoration:none;
                                      color:#800000;">← Prev</a>
                        </c:if>

                        <%-- Page Numbers --%>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p == currentPage}">
                                    <span style="padding:8px 14px; background:#800000;
                                                 color:white; border-radius:5px;
                                                 font-weight:bold;">${p}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="name-migration?tab=${tab}&page=${p}"
                                       style="padding:8px 14px; border:1px solid #ddd;
                                              border-radius:5px; text-decoration:none;
                                              color:#333;">${p}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <%-- Next --%>
                        <c:if test="${currentPage < totalPages}">
                            <a href="name-migration?tab=${tab}&page=${currentPage + 1}"
                               style="padding:8px 14px; border:1px solid #ddd;
                                      border-radius:5px; text-decoration:none;
                                      color:#800000;">Next →</a>
                        </c:if>
                    </div>
                </c:if>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- ══ Live Preview Script ══ -->
<script>
function updatePreview(input) {
    var row = input.closest('tr');
    var ln  = row.querySelector('input[name="lastName"]').value.trim().toUpperCase();
    var fn  = row.querySelector('input[name="firstName"]').value.trim();
    var mn  = row.querySelector('input[name="middleName"]').value.trim();

    var preview = '';
    if (ln) preview = ln;
    if (fn) {
        if (preview) preview += ', ';
        preview += fn;
    }
    if (mn) {
        preview += ' ' + mn.charAt(0) + '.';
    }

    row.querySelector('.preview-name').textContent = preview || '—';
}
</script>

</body>
</html>