<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.User, java.util.LinkedHashMap" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (request.getAttribute("totalStudents") == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    boolean isAdmin = currentUser.getRole() != null &&
            "admin".equalsIgnoreCase(currentUser.getRole());

    boolean isSuperAdmin = currentUser.getRole() != null &&
            "superadmin".equalsIgnoreCase(currentUser.getRole());

    // ===== GET DASHBOARD DATA =====
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    if (totalStudents == null) totalStudents = 0;

    Integer incompleteRequirements = (Integer) request.getAttribute("incompleteRequirements");
    if (incompleteRequirements == null) incompleteRequirements = 0;

    Integer completeRequirements = (Integer) request.getAttribute("completeRequirements");
    if (completeRequirements == null) completeRequirements = 0;

    Integer completionRate = (Integer) request.getAttribute("completionRate");
    if (completionRate == null) completionRate = 0;

    Map<String, int[]> categoryBreakdown = (Map<String, int[]>) request.getAttribute("categoryBreakdown");
    if (categoryBreakdown == null) categoryBreakdown = new LinkedHashMap<>();

    String _theme = (String) session.getAttribute("theme");
    if (_theme == null) _theme = "normal";

    String successMsg = request.getParameter("success");
    String errorMsg   = request.getParameter("error");

    // Build category data for charts
    StringBuilder catLabels = new StringBuilder("[");
    StringBuilder catData = new StringBuilder("[");
    StringBuilder catColors = new StringBuilder("[");
    String[] chartColors = {
        "#800000", "#c62828", "#e53935", "#ef5350",
        "#1565c0", "#1976d2", "#42a5f5",
        "#2e7d32", "#43a047", "#66bb6a",
        "#f57c00", "#ffa726", "#7b1fa2", "#ab47bc"
    };
    int colorIdx = 0;
    for (Map.Entry<String, int[]> entry : categoryBreakdown.entrySet()) {
        if (colorIdx > 0) {
            catLabels.append(",");
            catData.append(",");
            catColors.append(",");
        }
        catLabels.append("\"").append(entry.getKey()).append("\"");
        catData.append(entry.getValue()[1]);
        catColors.append("\"").append(chartColors[colorIdx % chartColors.length]).append("\"");
        colorIdx++;
    }
    catLabels.append("]");
    catData.append("]");
    catColors.append("]");
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
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <meta charset="UTF-8">
    <title>Dashboard - ADAMS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f0f2f5;
            display: flex;
            min-height: 100vh;
        }

        /* ══════════════════════════════
           MAIN CONTENT
           ══════════════════════════════ */
        .main {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
        }

        /* ── Header Bar ── */
        .dash-header {
            background: linear-gradient(135deg, #800000 0%, #4a0000 100%);
            padding: 25px 30px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 15px rgba(128,0,0,0.3);
            color: white;
        }

        .dash-header h1 {
            font-size: 24px;
            font-weight: 700;
        }

        .dash-header .greeting {
            font-size: 14px;
            opacity: 0.9;
        }

        .dash-header-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .btn-header {
            padding: 8px 18px;
            background: rgba(255,255,255,0.15);
            color: white;
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
            cursor: pointer;
        }

        .btn-header:hover {
            background: rgba(255,255,255,0.25);
            transform: translateY(-1px);
        }

        /* ── KPI Cards ── */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @keyframes countUp {
            from { opacity: 0; transform: scale(0.5); }
            to   { opacity: 1; transform: scale(1); }
        }

        @keyframes shimmer {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .kpi-card {
            background: white;
            border-radius: 12px;
            padding: 22px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            animation: slideUp 0.6s ease forwards;
            opacity: 0;
        }

        .kpi-card:nth-child(1) { animation-delay: 0.1s; }
        .kpi-card:nth-child(2) { animation-delay: 0.2s; }
        .kpi-card:nth-child(3) { animation-delay: 0.3s; }
        .kpi-card:nth-child(4) { animation-delay: 0.4s; }

        .kpi-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .kpi-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
        }

        .kpi-card.total::before    { background: linear-gradient(90deg, #1565c0, #42a5f5); }
        .kpi-card.complete::before { background: linear-gradient(90deg, #2e7d32, #66bb6a); }
        .kpi-card.pending::before  { background: linear-gradient(90deg, #f57c00, #ffa726); }
        .kpi-card.rate::before     { background: linear-gradient(90deg, #7b1fa2, #ce93d8); }

        .kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin-bottom: 12px;
        }

        .kpi-card.total .kpi-icon    { background: #e3f2fd; color: #1565c0; }
        .kpi-card.complete .kpi-icon { background: #e8f5e9; color: #2e7d32; }
        .kpi-card.pending .kpi-icon  { background: #fff3e0; color: #f57c00; }
        .kpi-card.rate .kpi-icon     { background: #f3e5f5; color: #7b1fa2; }

        .kpi-label {
            font-size: 13px;
            color: #888;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }

        .kpi-value {
            font-size: 32px;
            font-weight: 800;
            color: #222;
            line-height: 1;
        }

        .kpi-sub {
            font-size: 12px;
            color: #aaa;
            margin-top: 6px;
        }

        /* ── Animated Completion Ring ── */
        .kpi-ring-container {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .kpi-ring {
            position: relative;
            width: 64px;
            height: 64px;
        }

        .kpi-ring svg {
            transform: rotate(-90deg);
            width: 64px;
            height: 64px;
        }

        .kpi-ring .ring-bg {
            fill: none;
            stroke: #eee;
            stroke-width: 6;
        }

        .kpi-ring .ring-fill {
            fill: none;
            stroke-width: 6;
            stroke-linecap: round;
            transition: stroke-dashoffset 1.5s ease;
        }

        .kpi-ring .ring-text {
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            font-size: 14px;
            font-weight: 800;
            color: #333;
        }

        /* ── Charts Row ── */
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 25px;
        }

        .chart-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            animation: slideUp 0.8s ease forwards;
            opacity: 0;
            animation-delay: 0.5s;
        }

        .chart-card h2 {
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        .chart-card h2 i {
            margin-right: 8px;
            color: #800000;
        }

        /* ── Category Breakdown Cards ── */
        .breakdown-section {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            animation: slideUp 0.8s ease forwards;
            opacity: 0;
            animation-delay: 0.7s;
        }

        .breakdown-section h2 {
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        .breakdown-section h2 i {
            margin-right: 8px;
            color: #800000;
        }

        .breakdown-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
        }

        .cat-card {
            padding: 18px;
            background: linear-gradient(135deg, #fafafa, #f5f5f5);
            border-radius: 10px;
            border-left: 4px solid #800000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
            text-decoration: none;
            color: inherit;
            position: relative;
            overflow: hidden;
        }

        .cat-card:hover {
            background: linear-gradient(135deg, #fdf0f0, #fce4ec);
            border-left-color: #c62828;
            transform: translateX(4px);
            box-shadow: 3px 3px 12px rgba(128,0,0,0.12);
        }

        .cat-card .cat-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .cat-card .cat-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: #800000;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }

        .cat-card:hover .cat-icon {
            background: #c62828;
            animation: pulse 0.6s ease;
        }

        .cat-card .cat-name {
            font-size: 14px;
            font-weight: 600;
            color: #333;
        }

        .cat-card .cat-badge {
            background: #800000;
            color: white;
            padding: 6px 14px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 14px;
            transition: all 0.3s;
        }

        .cat-card:hover .cat-badge {
            background: #c62828;
            transform: scale(1.1);
        }

        .cat-card::after {
            content: '→';
            position: absolute;
            right: 15px;
            opacity: 0;
            transition: opacity 0.3s;
            color: #800000;
            font-weight: bold;
            font-size: 18px;
        }

        .cat-card:hover::after {
            opacity: 1;
        }

        /* ── Quick Actions ── */
        .quick-actions {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            animation: slideUp 0.8s ease forwards;
            opacity: 0;
            animation-delay: 0.9s;
        }

        .quick-actions h2 {
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        .quick-actions h2 i {
            margin-right: 8px;
            color: #800000;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 18px;
            background: #f8f8f8;
            border: 1px solid #eee;
            border-radius: 10px;
            text-decoration: none;
            color: #333;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .action-btn:hover {
            background: #800000;
            color: white;
            border-color: #800000;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(128,0,0,0.2);
        }

        .action-btn i {
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        /* ── Summary Bar ── */
        .summary-bar {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            animation: slideUp 0.8s ease forwards;
            opacity: 0;
            animation-delay: 0.6s;
        }

        .summary-bar h2 {
            font-size: 16px;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        .summary-bar h2 i {
            margin-right: 8px;
            color: #800000;
        }

        .progress-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }

        .progress-label {
            font-size: 13px;
            color: #666;
            min-width: 120px;
            font-weight: 500;
        }

        .progress-bar-track {
            flex: 1;
            height: 24px;
            background: #f0f0f0;
            border-radius: 12px;
            overflow: hidden;
            position: relative;
        }

        .progress-bar-fill {
            height: 100%;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-right: 10px;
            font-size: 11px;
            font-weight: 700;
            color: white;
            transition: width 1.5s ease;
            min-width: 0;
        }

        .progress-bar-fill.complete { background: linear-gradient(90deg, #2e7d32, #66bb6a); }
        .progress-bar-fill.pending  { background: linear-gradient(90deg, #f57c00, #ffa726); }

        /* ── Empty State ── */
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }

        .empty-state i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 15px;
        }

        /* ── Alerts ── */
        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 16px;
            font-size: 13px;
            font-weight: 600;
            animation: slideUp 0.4s ease;
        }

        .alert-success {
            background: #e8f5e9;
            border: 1px solid #2e7d32;
            color: #2e7d32;
        }

        .alert-error {
            background: #ffebee;
            border: 1px solid #c62828;
            color: #c62828;
        }

        /* ── Responsive ── */
        @media (max-width: 1024px) {
            .kpi-grid { grid-template-columns: repeat(2, 1fr); }
            .charts-row { grid-template-columns: 1fr; }
        }

        @media (max-width: 600px) {
            .kpi-grid { grid-template-columns: 1fr; }
            .dash-header { flex-direction: column; gap: 15px; text-align: center; }
            .main { padding: 15px; }
        }
    </style>
</head>

<body class="theme-<%= _theme %>">

<!-- SIDEBAR -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- MAIN CONTENT -->
<div class="main">

    <%-- PUP Banner --%>
    <jsp:include page="/includes/pup-banner.jsp" />

    <%-- Alerts --%>
    <% if (successMsg != null) { %>
        <div class="alert alert-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-error">❌ <%= errorMsg %></div>
    <% } %>

    <!-- ══════ HEADER ══════ -->
    <div class="dash-header">
        <div>
            <h1><i class="fas fa-chart-line"></i> Dashboard</h1>
            <div class="greeting">
                Welcome back, <strong><%= currentUser.getUsername() %></strong>!
                &nbsp;|&nbsp; <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy — hh:mm a").format(new java.util.Date()) %>
            </div>
        </div>
        <div class="dash-header-actions">
            <a href="<%= request.getContextPath() %>/dashboard-report" class="btn-header">
                <i class="fas fa-print"></i> Print Reports
            </a>
            <% if (isSuperAdmin || isAdmin) { %>
                <a href="<%= request.getContextPath() %>/name-migration" class="btn-header">
                    <i class="fas fa-pen"></i> Name Migration
                </a>
            <% } %>
        </div>
    </div>

    <% if (totalStudents == 0 && categoryBreakdown.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-inbox"></i>
            <p>No data yet. Add students to see dashboard analytics.</p>
        </div>
    <% } else { %>

    <!-- ══════ KPI CARDS ══════ -->
    <div class="kpi-grid">

        <!-- Total Students -->
        <div class="kpi-card total">
            <div class="kpi-icon"><i class="fas fa-users"></i></div>
            <div class="kpi-label">Total Students</div>
            <div class="kpi-value">
                <span class="counter" data-target="<%= totalStudents %>">0</span>
            </div>
            <div class="kpi-sub">Active students in system</div>
        </div>

        <!-- Complete -->
        <div class="kpi-card complete">
            <div class="kpi-icon"><i class="fas fa-check-circle"></i></div>
            <div class="kpi-label">Complete</div>
            <div class="kpi-value">
                <span class="counter" data-target="<%= completeRequirements %>">0</span>
            </div>
            <div class="kpi-sub">All requirements submitted</div>
        </div>

        <!-- Pending -->
        <div class="kpi-card pending">
            <div class="kpi-icon"><i class="fas fa-exclamation-triangle"></i></div>
            <div class="kpi-label">Pending</div>
            <div class="kpi-value">
                <span class="counter" data-target="<%= incompleteRequirements %>">0</span>
            </div>
            <div class="kpi-sub">Needing attention</div>
        </div>

        <!-- Completion Rate — with animated ring -->
        <div class="kpi-card rate">
            <div class="kpi-label">Completion Rate</div>
            <div class="kpi-ring-container">
                <div class="kpi-ring">
                    <svg viewBox="0 0 64 64">
                        <circle class="ring-bg" cx="32" cy="32" r="28"/>
                        <circle class="ring-fill" cx="32" cy="32" r="28"
                                stroke="#7b1fa2"
                                stroke-dasharray="175.93"
                                stroke-dashoffset="175.93"
                                data-pct="<%= completionRate %>"/>
                    </svg>
                    <span class="ring-text">
                        <span class="counter" data-target="<%= completionRate %>"
                              data-suffix="%">0</span>
                    </span>
                </div>
                <div>
                    <div style="font-size:24px; font-weight:800; color:#222;">
                        <%= completionRate %>%
                    </div>
                    <div class="kpi-sub"><%= categoryBreakdown.size() %> categories</div>
                </div>
            </div>
        </div>

    </div>

    <!-- ══════ OVERALL PROGRESS BAR ══════ -->
    <div class="summary-bar">
        <h2><i class="fas fa-tasks"></i> Overall Progress</h2>
        <div class="progress-row">
            <span class="progress-label">✅ Complete</span>
            <div class="progress-bar-track">
                <div class="progress-bar-fill complete"
                     data-width="<%= totalStudents > 0 ? Math.round(completeRequirements * 100.0 / totalStudents) : 0 %>"
                     style="width: 0%">
                </div>
            </div>
            <span style="min-width:60px; text-align:right; font-weight:700; color:#2e7d32;">
                <%= completeRequirements %>
            </span>
        </div>
        <div class="progress-row">
            <span class="progress-label">⏳ Pending</span>
            <div class="progress-bar-track">
                <div class="progress-bar-fill pending"
                     data-width="<%= totalStudents > 0 ? Math.round(incompleteRequirements * 100.0 / totalStudents) : 0 %>"
                     style="width: 0%">
                </div>
            </div>
            <span style="min-width:60px; text-align:right; font-weight:700; color:#f57c00;">
                <%= incompleteRequirements %>
            </span>
        </div>
    </div>

    <!-- ══════ CHARTS ROW ══════ -->
    <div class="charts-row">

        <!-- Donut Chart -->
        <div class="chart-card">
            <h2><i class="fas fa-chart-pie"></i> Students by Category</h2>
            <div style="position:relative; max-width:320px; margin:0 auto;">
                <canvas id="categoryDonut"></canvas>
            </div>
        </div>

        <!-- Bar Chart -->
        <div class="chart-card">
            <h2><i class="fas fa-chart-bar"></i> Category Distribution</h2>
            <canvas id="categoryBar"></canvas>
        </div>

    </div>

    <!-- ══════ CATEGORY BREAKDOWN CARDS ══════ -->
    <div class="breakdown-section">
        <h2><i class="fas fa-graduation-cap"></i> Browse by Category</h2>

        <% if (categoryBreakdown.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <p>No categories yet</p>
            </div>
        <% } else { %>
            <div class="breakdown-grid">
                <% for (Map.Entry<String, int[]> entry : categoryBreakdown.entrySet()) {
                    int catId = entry.getValue()[0];
                    int catCount = entry.getValue()[1];
                %>
                    <a href="students?categoryId=<%= catId %>"
                       class="cat-card"
                       title="View <%= entry.getKey() %> students">
                        <div class="cat-info">
                            <div class="cat-icon">
                                <i class="fas fa-graduation-cap"></i>
                            </div>
                            <span class="cat-name"><%= entry.getKey() %></span>
                        </div>
                        <span class="cat-badge"><%= catCount %></span>
                    </a>
                <% } %>
            </div>
        <% } %>
    </div>

    <!-- ══════ QUICK ACTIONS ══════ -->
    <div class="quick-actions">
        <h2><i class="fas fa-bolt"></i> Quick Actions</h2>
        <div class="actions-grid">
            <a href="<%= request.getContextPath() %>/students" class="action-btn">
                <i class="fas fa-user-plus"></i> Students
            </a>
            <a href="<%= request.getContextPath() %>/dashboard-report" class="action-btn">
                <i class="fas fa-file-pdf"></i> Full Report
            </a>
            <a href="<%= request.getContextPath() %>/archives" class="action-btn">
                <i class="fas fa-box-archive"></i> Archives
            </a>
            <a href="<%= request.getContextPath() %>/verify" class="action-btn">
                <i class="fas fa-search"></i> Verify Document
            </a>
            <% if (isSuperAdmin || isAdmin) { %>
                <a href="<%= request.getContextPath() %>/categories" class="action-btn">
                    <i class="fas fa-list"></i> Categories
                </a>
                <a href="<%= request.getContextPath() %>/requirements" class="action-btn">
                    <i class="fas fa-clipboard-list"></i> Requirements
                </a>
                <a href="<%= request.getContextPath() %>/activity-log" class="action-btn">
                    <i class="fas fa-history"></i> Activity Log
                </a>
                <a href="<%= request.getContextPath() %>/users" class="action-btn">
                    <i class="fas fa-users-cog"></i> Users
                </a>
            <% } %>
        </div>
    </div>

    <% } %> <%-- end if totalStudents > 0 --%>

</div>

<jsp:include page="/includes/footer.jsp" />

<!-- ══════════════════════════════
     SCRIPTS — Animations & Charts
     ══════════════════════════════ -->
<script>
// ── Counter Animation ──
function animateCounters() {
    document.querySelectorAll('.counter').forEach(counter => {
        const target = +counter.getAttribute('data-target');
        const suffix = counter.getAttribute('data-suffix') || '';
        const duration = 1500;
        const start = performance.now();

        function update(now) {
            const elapsed = now - start;
            const progress = Math.min(elapsed / duration, 1);
            // Ease out cubic
            const ease = 1 - Math.pow(1 - progress, 3);
            const current = Math.round(target * ease);
            counter.textContent = current.toLocaleString() + suffix;
            if (progress < 1) requestAnimationFrame(update);
        }
        requestAnimationFrame(update);
    });
}

// ── Progress Bar Animation ──
function animateProgressBars() {
    document.querySelectorAll('.progress-bar-fill').forEach(bar => {
        const width = bar.getAttribute('data-width');
        setTimeout(() => {
            bar.style.width = width + '%';
            if (parseFloat(width) > 15) {
                bar.textContent = width + '%';
            }
        }, 500);
    });
}

// ── Ring Animation ──
function animateRing() {
    document.querySelectorAll('.ring-fill').forEach(ring => {
        const pct = +ring.getAttribute('data-pct');
        const circumference = 2 * Math.PI * 28; // r=28
        const offset = circumference - (pct / 100) * circumference;
        setTimeout(() => {
            ring.style.strokeDashoffset = offset;
        }, 600);
    });
}

// ── Chart.js — Donut ──
function initDonutChart() {
    const ctx = document.getElementById('categoryDonut');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: <%= catLabels.toString() %>,
            datasets: [{
                data: <%= catData.toString() %>,
                backgroundColor: <%= catColors.toString() %>,
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            cutout: '65%',
            animation: {
                animateRotate: true,
                duration: 1500,
                easing: 'easeOutQuart'
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        usePointStyle: true,
                        pointStyleWidth: 12,
                        font: { size: 12, family: "'Segoe UI', sans-serif" }
                    }
                }
            }
        }
    });
}

// ── Chart.js — Bar ──
function initBarChart() {
    const ctx = document.getElementById('categoryBar');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: <%= catLabels.toString() %>,
            datasets: [{
                label: 'Students',
                data: <%= catData.toString() %>,
                backgroundColor: <%= catColors.toString() %>,
                borderRadius: 6,
                borderSkipped: false,
                barThickness: 40
            }]
        },
        options: {
            responsive: true,
            animation: {
                duration: 1500,
                easing: 'easeOutQuart'
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        font: { size: 12 },
                        stepSize: 1
                    },
                    grid: { color: 'rgba(0,0,0,0.05)' }
                },
                x: {
                    ticks: { font: { size: 11 } },
                    grid: { display: false }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
}

// ── Initialize Everything ──
document.addEventListener('DOMContentLoaded', function() {
    animateCounters();
    animateProgressBars();
    animateRing();
    initDonutChart();
    initBarChart();
});
</script>

</body>
</html>
