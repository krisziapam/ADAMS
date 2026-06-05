<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    User currentUser =
        (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp");
        return;
    }

    String currentTheme =
        (String) session.getAttribute("theme");
    if (currentTheme == null) currentTheme = "normal";

    String successMsg =
        request.getParameter("success");
%>

<!DOCTYPE html>
<html>
<head>
<link rel="icon" type="image/x-icon"
          href="<%= request.getContextPath() %>/favicon.ico" />
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<meta charset="UTF-8">
<title>Settings | ADAMS</title>
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">
<link rel="stylesheet"
      href="<%= request.getContextPath()
      %>/css/themes.css">
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body {
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    min-height: 100vh;
}

/* ── SIDEBAR ── */
.sidebar {
    width: 250px;
    background: #6d0f0f;
    color: #fff;
    display: flex;
    flex-direction: column;
}
.sidebar h2 {
    padding: 20px;
    text-align: center;
    background: #5a0c0c;
    font-size: 20px;
}
.sidebar a {
    padding: 15px 20px;
    color: #fff;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: background 0.3s;
}
.sidebar a:hover  { background: #8b1a1a; }
.sidebar a.active {
    background: #8b1a1a;
    font-weight: 600;
}
.sidebar .logout {
    margin-top: auto;
    background: #4a0a0a;
}

/* ── MAIN ── */
.main {
    flex: 1;
    padding: 30px;
    background: #f4f4f4;
}

/* ── SETTINGS CARD ── */
.settings-card {
    background: #fff;
    border-radius: 8px;
    padding: 30px;
    max-width: 700px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.settings-card h2 {
    color: #6d0f0f;
    margin-bottom: 8px;
    font-size: 20px;
}
.settings-card p {
    color: #777;
    font-size: 13px;
    margin-bottom: 24px;
}

/* ── THEME GRID ── */
.theme-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 24px;
}

.theme-card {
    border: 3px solid #ddd;
    border-radius: 8px;
    cursor: pointer;
    transition: border 0.2s, transform 0.2s;
    overflow: hidden;
    position: relative;
    display: block;
}
.theme-card:hover {
    transform: translateY(-3px);
    border-color: #999;
}
.theme-card.selected {
    border-color: #6d0f0f;
    box-shadow: 0 0 12px rgba(109,15,15,0.4);
}
.theme-card input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0;
    height: 0;
}

/* ── PREVIEWS ── */
.preview {
    height: 120px;
    position: relative;
    overflow: hidden;
}

/* Normal */
.preview-normal { background: #f4f4f4; }
.preview-normal .prev-sidebar {
    position:absolute; left:0; top:0; bottom:0;
    width:35%; background:#6d0f0f;
}
.preview-normal .prev-main {
    position:absolute; left:35%; right:0;
    top:0; bottom:0; padding:8px;
}
.preview-normal .prev-card {
    background:#fff; border-radius:4px;
    height:28px; margin-bottom:5px;
    border-left:3px solid #6d0f0f;
}

/* Light */
.preview-light { background: #fce4ec; }
.preview-light .prev-sidebar {
    position:absolute; left:0; top:0; bottom:0;
    width:35%; background:#f48fb1;
}
.preview-light .prev-main {
    position:absolute; left:35%; right:0;
    top:0; bottom:0; padding:8px;
}
.preview-light .prev-card {
    background:#fff; border-radius:8px;
    height:28px; margin-bottom:5px;
    border-left:3px solid #e91e8c;
}

/* Dark */
.preview-dark { background: #0d0d0d; }
.preview-dark .prev-sidebar {
    position:absolute; left:0; top:0; bottom:0;
    width:35%; background:#0a0a0a;
    border-right:1px solid #00ff41;
}
.preview-dark .prev-main {
    position:absolute; left:35%; right:0;
    top:0; bottom:0; padding:8px;
}
.preview-dark .prev-text {
    color:#00ff41;
    font-family:'Courier New', monospace;
    font-size:8px; padding:2px 0 4px 0;
}
.preview-dark .prev-card {
    background:#0a0a0a; border-radius:0;
    height:22px; margin-bottom:5px;
    border-left:3px solid #00ff41;
    box-shadow:0 0 4px rgba(0,255,65,0.4);
}

/* ── CHECK MARK ── */
.check-mark {
    display: none;
    position: absolute;
    top: 8px; right: 8px;
    background: #6d0f0f;
    color: #fff;
    border-radius: 50%;
    width: 22px; height: 22px;
    text-align: center;
    line-height: 22px;
    font-size: 12px;
    font-weight: bold;
    z-index: 10;
}
.theme-card.selected .check-mark {
    display: block;
}

/* ── THEME LABEL ── */
.theme-label {
    padding: 10px;
    text-align: center;
    font-size: 13px;
    font-weight: bold;
    background: #f9f9f9;
    border-top: 1px solid #eee;
}
.theme-label .theme-desc {
    font-size: 10px;
    color: #999;
    font-weight: normal;
    display: block;
    margin-top: 2px;
}

/* ── SAVE BUTTON ── */
.btn-save {
    padding: 12px 32px;
    background: #6d0f0f;
    color: #fff;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    transition: background 0.2s;
}
.btn-save:hover { background: #5a0c0c; }

/* ── SUCCESS ── */
.success-msg {
    background: #e8f5e9;
    color: #2e7d32;
    padding: 10px 16px;
    border-radius: 4px;
    margin-bottom: 20px;
    font-size: 13px;
    font-weight: bold;
    border-left: 4px solid #2e7d32;
}
</style>
</head>

<body class="theme-<%= currentTheme %>">

<!-- ══ SIDEBAR ══ -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ══ MAIN ══ -->
<div class="main">
<%-- ✅ ONE LINE = PUP header everywhere --%>
    <jsp:include page="/includes/pup-banner.jsp" />
    <div class="settings-card">

        <h2>🎨 Appearance Settings</h2>
        <p>
            Choose a theme for your ADAMS experience.
            Your preference will be saved for this session.
        </p>

        <!-- SUCCESS MESSAGE -->
        <% if (successMsg != null
                && !successMsg.isEmpty()) { %>
        <div class="success-msg">
            ✅ <%= successMsg %>
        </div>
        <% } %>

        <!-- THEME FORM -->
        <form action="<%= request.getContextPath()
            %>/settings" method="post">

            <div class="theme-grid">

                <!-- NORMAL -->
                <label class="theme-card <%=
                    "normal".equals(currentTheme)
                    ? "selected" : "" %>"
                    id="card-normal"
                    onclick="selectTheme('normal')">

                    <input type="radio"
                           name="theme"
                           value="normal"
                           <%= "normal".equals(currentTheme)
                               ? "checked" : "" %>>

                    <div class="check-mark">✓</div>

                    <div class="preview preview-normal">
                        <div class="prev-sidebar"></div>
                        <div class="prev-main">
                            <div class="prev-card"></div>
                            <div class="prev-card"></div>
                            <div class="prev-card"></div>
                        </div>
                    </div>

                    <div class="theme-label">
                        🟤 PUP Maroons
                        <span class="theme-desc">
                            Classic maroon &amp; white
                        </span>
                    </div>
                </label>

                <!-- LIGHT -->
                <label class="theme-card <%=
                    "light".equals(currentTheme)
                    ? "selected" : "" %>"
                    id="card-light"
                    onclick="selectTheme('light')">

                    <input type="radio"
                           name="theme"
                           value="light"
                           <%= "light".equals(currentTheme)
                               ? "checked" : "" %>>

                    <div class="check-mark">✓</div>

                    <div class="preview preview-light">
                        <div class="prev-sidebar"></div>
                        <div class="prev-main">
                            <div class="prev-card"></div>
                            <div class="prev-card"></div>
                            <div class="prev-card"></div>
                        </div>
                    </div>

                    <div class="theme-label">
                        🌸 Light
                        <span class="theme-desc">
                            Pastel pink &amp; sky blue
                        </span>
                    </div>
                </label>

                <!-- DARK -->
                <label class="theme-card <%=
                    "dark".equals(currentTheme)
                    ? "selected" : "" %>"
                    id="card-dark"
                    onclick="selectTheme('dark')">

                    <input type="radio"
                           name="theme"
                           value="dark"
                           <%= "dark".equals(currentTheme)
                               ? "checked" : "" %>>

                    <div class="check-mark">✓</div>

                    <div class="preview preview-dark">
                        <div class="prev-sidebar"></div>
                        <div class="prev-main">
                            <div class="prev-text">
                                &gt; SYSTEM ONLINE_
                            </div>
                            <div class="prev-card"></div>
                            <div class="prev-card"></div>
                        </div>
                    </div>

                    <div class="theme-label">
                        💻 Dark
                        <span class="theme-desc">
                            Hacker — black &amp; green
                        </span>
                    </div>
                </label>

            </div>

            <button type="submit" class="btn-save">
                💾 Apply Theme
            </button>

        </form>

    </div>
</div>

<script>
function selectTheme(theme) {
    // Remove selected from all cards
    document.querySelectorAll('.theme-card')
        .forEach(function(c) {
            c.classList.remove('selected');
        });

    // Add selected to clicked card
    document.getElementById('card-' + theme)
        .classList.add('selected');

    // Check the radio button
    document.querySelector(
        'input[value="' + theme + '"]')
        .checked = true;
}
</script>

<jsp:include page="/includes/footer.jsp" />
</body>
</html>
