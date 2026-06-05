<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String userRole = (currentUser != null)
        ? currentUser.getRole().toLowerCase() : "";
%>

<%
    String _uri = request.getRequestURI();
    User _u = (User) session
        .getAttribute("currentUser");

    String ctx = request.getContextPath();

    // Active page classes
    String classDash   = _uri.contains("/dashboard")       ? "active" : "";
    String classVerify = _uri.contains("/verify")           ? "active" : "";
    String classStud   = _uri.contains("/students")         ? "active" : "";
    String classCat    = _uri.contains("/categories")       ? "active" : "";
    String classReq    = _uri.contains("/requirements")     ? "active" : "";
    String classLog    = _uri.contains("/activity-log")     ? "active" : "";
    String classUser   = _uri.contains("/user-management")  ? "active" : "";
    String classProf   = _uri.contains("/profile")          ? "active" : "";
    String classSet    = _uri.contains("/settings")         ? "active" : "";

    // ============================================
    // 👤 USER INFO
    // ============================================
    String sFullName   = "";
    String sFirstName  = "";
    String sRole       = "";
    String roleBadge   = "User";
    String badgeColor  = "#f57c00";
    String roleIcon    = "👤";
    String avatarLetter = "U";

    if (_u != null) {
        sFullName = _u.getFullName();
        if (sFullName == null || sFullName.trim().isEmpty()) {
            sFullName = _u.getUsername();
        }
        sFirstName   = sFullName.split(" ")[0];
        avatarLetter = sFirstName.substring(0, 1).toUpperCase();

        sRole = _u.getRole();
        if ("superadmin".equalsIgnoreCase(sRole)) {
            roleBadge = "Superadmin";
            badgeColor = "#ffd700";
            roleIcon = "👑";
        } else if ("admin".equalsIgnoreCase(sRole)) {
            roleBadge = "Admin";
            badgeColor = "#42a5f5";
            roleIcon = "⚙️";
        } else if ("staff".equalsIgnoreCase(sRole)) {
            roleBadge = "Staff";
            badgeColor = "#66bb6a";
            roleIcon = "📋";
        } else if ("student".equalsIgnoreCase(sRole)) {
            roleBadge = "Student";
            badgeColor = "#ab47bc";
            roleIcon = "🎓";
        }
    }
%>

<style>
    /* ========== SIDEBAR ========== */
    .sidebar {
        position: fixed;
        top: 0; left: 0;
        width: 220px;
        height: 100vh;
        background: linear-gradient(180deg, #8b1a1a 0%, #5a0c0c 100%);
        display: flex;
        flex-direction: column;
        z-index: 1000;
        overflow-y: auto;
        transition: transform 0.3s ease;
    }

    .sidebar.collapsed {
        transform: translateX(-220px);
    }

    /* ========== LOGO ========== */
    .sidebar h2 {
        text-align: center;
        color: #fff;
        font-size: 22px;
        font-weight: 900;
        letter-spacing: 3px;
        padding: 50px 16px 10px;
        margin: 0;
    }

    /* ========== USER SECTION ========== */
    .sidebar-user {
        padding: 10px 14px 16px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        text-align: center;
    }
    .user-avatar {
        width: 44px; height: 44px;
        border-radius: 50%;
        background: rgba(255,255,255,0.18);
        color: #fff;
        font-size: 18px; font-weight: bold;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 6px;
        border: 2px solid rgba(255,255,255,0.25);
    }
    .user-greeting {
        color: #ffcc80;
        font-size: 11px;
        font-style: italic;
        margin: 0 0 3px 0;
        min-height: 14px;
    }
    .user-fullname {
        color: #fff;
        font-size: 13px;
        font-weight: bold;
        margin: 0 0 5px 0;
    }
    .role-badge {
        display: inline-block;
        padding: 2px 10px;
        border-radius: 10px;
        font-size: 10px;
        font-weight: bold;
        color: #1a1a1a;
    }

    /* ========== NAV LINKS ========== */
    .sidebar-nav {
        flex: 1;
        padding: 8px 0;
    }
    .sidebar-nav a {
        display: flex;
        align-items: center;
        padding: 12px 20px;
        color: rgba(255,255,255,0.75);
        text-decoration: none;
        font-size: 14px;
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
    }
    .sidebar-nav a:hover {
        background: rgba(255,255,255,0.1);
        color: #fff;
        border-left-color: #ffcc80;
    }
    .sidebar-nav a.active {
        background: rgba(255,255,255,0.15);
        color: #fff;
        font-weight: bold;
        border-left-color: #ffd700;
    }
    .sidebar-nav a i {
        width: 22px;
        text-align: center;
        margin-right: 10px;
        font-size: 14px;
    }

    /* ========== LOGOUT ========== */
    .sidebar-nav a.logout {
        color: #ffcccc;
        margin-top: 4px;
        border-top: 1px solid rgba(255,255,255,0.08);
    }
    .sidebar-nav a.logout:hover {
        background: rgba(255,0,0,0.15);
        color: #fff;
        border-left-color: #ff6b6b;
    }

    /* ========== MAIN CONTENT ========== */
    .main {
        margin-left: 220px;
        transition: margin-left 0.3s ease;
    }

    .main.expanded {
        margin-left: 0;
    }

    /* ========== HAMBURGER TOGGLE ========== */
    .sidebar-toggle {
        position: fixed;
        top: 14px;
        left: 175px;
        width: 34px;
        height: 34px;
        background: rgba(255,255,255,0.15);
        color: #fff;
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 6px;
        font-size: 20px;
        cursor: pointer;
        z-index: 1100;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: left 0.3s ease, background 0.3s ease;
    }

    .sidebar-toggle:hover {
        background: rgba(255,255,255,0.3);
    }

    .sidebar-toggle.shifted {
        left: 12px;
        background: #6d0f0f;
        border: 1px solid #8b1a1a;
        color: #fff;
    }

    /* ========== PRINT ========== */
    @media print {
        .sidebar,
        .sidebar-toggle {
            display: none !important;
        }
        .main {
            margin-left: 0 !important;
        }
    }
</style>

<%-- ✅ HAMBURGER TOGGLE — OUTSIDE the sidebar --%>
<button class="sidebar-toggle" id="sidebarToggle"
        onclick="toggleSidebar()"
        title="Toggle Sidebar">
    ☰
</button>

<%-- ============================================
     📌 SIDEBAR HTML
     ✅ FIX: Added id="sidebar" !!
     ============================================ --%>
<div class="sidebar" id="sidebar">

    <%-- LOGO --%>
    <h2>ADAMS</h2>

    <%-- 👤 USER GREETING --%>
    <% if (_u != null) { %>
    <div class="sidebar-user">
        <div class="user-avatar">
            <%= avatarLetter %>
        </div>
        <p class="user-greeting" id="sidebarGreeting"></p>
        <p class="user-fullname"><%= sFullName %></p>
        <span class="role-badge"
              style="background:<%= badgeColor %>;">
            <%= roleIcon %> <%= roleBadge %>
        </span>
    </div>
    <% } %>

    <%-- NAVIGATION --%>
    <div class="sidebar-nav">

        <a href="<%= ctx %>/dashboard"
           class="<%= classDash %>">
            <i class="fas fa-tachometer-alt"></i>
            Dashboard
        </a>

        <a href="<%= ctx %>/verify"
           class="<%= classVerify %>">
            <i class="fas fa-search"></i>
            Verify Document
        </a>

        <a href="<%= ctx %>/students"
           class="<%= classStud %>">
            <i class="fas fa-users"></i>
            Students
        </a>

       <!-- Archives — Admin & Super Admin only -->
        <% if ("superadmin".equals(userRole) || "admin".equals(userRole)) { %>
        <a href="<%= request.getContextPath() %>/archives"
        class="<%= request.getRequestURI().contains("archives") ? "active" : "" %>">
            <i class="fas fa-box-archive"></i> Archives
        </a>
        <% } %>

        <a href="<%= ctx %>/categories"
           class="<%= classCat %>">
            <i class="fas fa-list"></i>
            Categories
        </a>

        <a href="<%= ctx %>/requirements"
           class="<%= classReq %>">
            <i class="fas fa-file-alt"></i>
            Requirements
        </a>

        <a href="<%= ctx %>/activity-log"
           class="<%= classLog %>">
            <i class="fas fa-history"></i>
            Activity Log
        </a>

        <% if (_u != null && _u.isSuperAdmin()) { %>
        <a href="<%= ctx %>/user-management"
           class="<%= classUser %>">
            <i class="fas fa-user-cog"></i>
            Users
        </a>
        <% } %>

        <%-- Name Migration — Only visible to superadmin --%>
        <% if ("superadmin".equals(userRole)){ %>
            <a href="name-migration" class="btn-back"
            style="background:#800000; color:white; margin-left:10px;"
            title="Migrate old records to Last/First/Middle format">
                📝 Name Migration
            </a>
        <% } %>

        <a href="<%= ctx %>/profile"
           class="<%= classProf %>">
            <i class="fas fa-user-circle"></i>
            My Profile
        </a>

        <a href="<%= ctx %>/settings"
           class="<%= classSet %>">
            <i class="fas fa-paint-brush"></i>
            Settings
        </a>

        <a href="<%= ctx %>/logout"
           class="logout">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>

    </div>

</div>

<%-- ============================================
     🎲 SCRIPTS
     ============================================ --%>
<script>
// GREETING
(function() {
    var el = document.getElementById('sidebarGreeting');
    if (!el) return;

    var name = "<%= sFirstName %>";
    var hour = new Date().getHours();

    var timeGreet;
    if      (hour >= 5  && hour < 12) timeGreet = "Good morning";
    else if (hour >= 12 && hour < 18) timeGreet = "Good afternoon";
    else                               timeGreet = "Good evening";

    var greetings = [
        timeGreet + ", " + name + "!",
        "Hey " + name + "! Ready to roll? \uD83D\uDE80",
        "Welcome back, " + name + "! \uD83D\uDC4B",
        "Hi " + name + "! How's it going? \uD83D\uDE0A",
        "What's up, " + name + "? \uD83D\uDCAA",
        name + "! Great to see you! \uD83C\uDF89",
        "Hello " + name + "! Let's get it done! \u2705",
        timeGreet + "! Let's do this, " + name + "! \uD83D\uDD25",
        "Yo " + name + "! Looking good today! \uD83D\uDE0E",
        "Hey there, " + name + "! \uD83E\uDD1D",
        name + ", you're doing great! \uD83C\uDF1F",
        "Kamusta, " + name + "? \uD83C\uDDF5\uD83C\uDDED"
    ];

    var i = Math.floor(Math.random() * greetings.length);
    el.textContent = greetings[i];
})();

// ☰ TOGGLE
function toggleSidebar() {
    var sidebarEl = document.getElementById('sidebar');
    var mainEl    = document.querySelector('.main');
    var toggleBtn = document.getElementById('sidebarToggle');

    if (!sidebarEl || !toggleBtn) return;

    sidebarEl.classList.toggle('collapsed');
    toggleBtn.classList.toggle('shifted');

    if (mainEl) {
        mainEl.classList.toggle('expanded');
    }
}
</script>
