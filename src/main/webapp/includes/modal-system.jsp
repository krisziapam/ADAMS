<%--
  ADAMS Modal System (modal-system.jsp)
  ============================================================
  Replaces browser alert() and confirm() with styled modals.

  INCLUDE at the bottom of any JSP (before </body>):
    <%@ include file="includes/modal-system.jsp" %>

  API:
    showAlert('Message', 'success');        // success|error|warning|info
    showAlert('Message', 'error', fn);      // optional callback on OK
    showConfirm('Sure?', function() {...}); // onConfirm callback
    showConfirm('Delete?', fn, 'danger');   // red delete button
  ============================================================
--%>

<!-- ADAMS ALERT MODAL -->
<div id="adamsAlertModal" class="adams-modal-overlay" style="display:none;">
    <div class="adams-modal-card">
        <div class="adams-modal-icon" id="adamsAlertIcon"></div>
        <div class="adams-modal-msg" id="adamsAlertMsg"></div>
        <div class="adams-modal-btns">
            <button class="adams-btn adams-btn-ok" id="adamsAlertOk"
                    type="button" onclick="adamsCloseAlert()">OK</button>
        </div>
    </div>
</div>

<!-- ADAMS CONFIRM MODAL -->
<div id="adamsConfirmModal" class="adams-modal-overlay" style="display:none;">
    <div class="adams-modal-card">
        <div class="adams-modal-icon" id="adamsConfirmIcon"></div>
        <div class="adams-modal-msg" id="adamsConfirmMsg"></div>
        <div class="adams-modal-btns adams-modal-btns-pair">
            <button class="adams-btn adams-btn-cancel" type="button"
                    onclick="adamsCloseConfirm(false)">Cancel</button>
            <button class="adams-btn adams-btn-proceed" id="adamsConfirmProceed"
                    type="button" onclick="adamsCloseConfirm(true)">Proceed</button>
        </div>
    </div>
</div>

<style>
/* -- Overlay -- */
.adams-modal-overlay {
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.45);
    z-index: 99999;
    display: none;
    align-items: center;
    justify-content: center;
}
.adams-modal-overlay.adams-show {
    display: flex !important;
}

/* -- Card -- */
.adams-modal-card {
    background: #fff;
    border-radius: 14px;
    padding: 32px 28px 24px;
    min-width: 340px;
    max-width: 460px;
    width: 90%;
    text-align: center;
    box-shadow: 0 12px 40px rgba(0,0,0,0.25);
    transform: scale(0.85);
    opacity: 0;
    transition: transform 0.2s ease, opacity 0.2s ease;
}
.adams-modal-overlay.adams-show .adams-modal-card {
    transform: scale(1);
    opacity: 1;
}

/* -- Icon circle -- */
.adams-modal-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    margin: 0 auto 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: bold;
    color: #fff;
}
.adams-icon-success { background: #2e7d32; }
.adams-icon-error   { background: #d32f2f; }
.adams-icon-warning { background: #ef6c00; }
.adams-icon-info    { background: #1565c0; }
.adams-icon-danger  { background: #c62828; }

/* -- Message -- */
.adams-modal-msg {
    font-size: 15px;
    line-height: 1.55;
    color: #333;
    margin-bottom: 24px;
    white-space: pre-line;
    word-wrap: break-word;
}

/* -- Buttons -- */
.adams-modal-btns {
    display: flex;
    justify-content: center;
    gap: 12px;
}
.adams-btn {
    padding: 10px 28px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s ease;
    letter-spacing: 0.3px;
}
.adams-btn:hover { filter: brightness(1.1); transform: translateY(-1px); }
.adams-btn:active { transform: translateY(0); }

.adams-btn-ok     { background: #1a3c5e; color: #fff; }
.adams-btn-cancel { background: #e0e0e0; color: #333; }
.adams-btn-proceed              { background: #1a3c5e; color: #fff; }
.adams-btn-proceed.adams-danger { background: #d32f2f; color: #fff; }

/* -- THEME: LIGHT -- */
body.theme-light .adams-modal-card {
    background: #fff0f5;
    border: 1px solid #f8bbd0;
}
body.theme-light .adams-modal-msg { color: #880e4f; }
body.theme-light .adams-btn-ok    { background: #e91e8c; }
body.theme-light .adams-btn-cancel { background: #fce4ec; color: #880e4f; }
body.theme-light .adams-btn-proceed { background: #e91e8c; }
body.theme-light .adams-btn-proceed.adams-danger { background: #d32f2f; }

/* -- THEME: DARK -- */
body.theme-dark .adams-modal-card {
    background: #1a1a2e;
    border: 1px solid #003300;
    box-shadow: 0 12px 40px rgba(0,255,65,0.1);
}
body.theme-dark .adams-modal-msg { color: #00ff41; }
body.theme-dark .adams-btn-ok    { background: #003300; color: #00ff41; border: 1px solid #00ff41; }
body.theme-dark .adams-btn-cancel { background: #1a1a1a; color: #00ff41; border: 1px solid #333; }
body.theme-dark .adams-btn-proceed { background: #003300; color: #00ff41; border: 1px solid #00ff41; }
body.theme-dark .adams-btn-proceed.adams-danger { background: #4a0000; color: #ff4444; border: 1px solid #ff4444; }
body.theme-dark .adams-icon-success { background: #003300; border: 2px solid #00ff41; }
body.theme-dark .adams-icon-error   { background: #3a0000; border: 2px solid #ff4444; }
body.theme-dark .adams-icon-warning { background: #3a2d00; border: 2px solid #ffcc00; }
body.theme-dark .adams-icon-info    { background: #002a3a; border: 2px solid #00ccff; }
body.theme-dark .adams-icon-danger  { background: #3a0000; border: 2px solid #ff4444; }
</style>

<script>
/* -- Icon definitions -- */
var _adamsIcons = {
    success: { symbol: "\u2713", css: "adams-icon-success" },
    error:   { symbol: "\u2717", css: "adams-icon-error"   },
    warning: { symbol: "!",      css: "adams-icon-warning" },
    info:    { symbol: "i",      css: "adams-icon-info"    },
    danger:  { symbol: "\u2717", css: "adams-icon-danger"  }
};

var _adamsAlertCb = null;
var _adamsConfirmCb = null;

/* -- showAlert(message, type, callback) -- */
window.showAlert = function(message, type, callback) {
    type = type || "info";
    _adamsAlertCb = callback || null;
    var icon = _adamsIcons[type] || _adamsIcons.info;
    var iconEl = document.getElementById("adamsAlertIcon");
    if (iconEl) {
        iconEl.className = "adams-modal-icon " + icon.css;
        iconEl.textContent = icon.symbol;
    }
    var msgEl = document.getElementById("adamsAlertMsg");
    if (msgEl) msgEl.textContent = message;
    var okBtn = document.getElementById("adamsAlertOk");
    if (okBtn) {
        okBtn.style.background = (type === "error" || type === "danger") ? "#d32f2f" : "";
    }
    var modal = document.getElementById("adamsAlertModal");
    if (modal) modal.classList.add("adams-show");
};

/* -- adamsCloseAlert() -- */
window.adamsCloseAlert = function() {
    var modal = document.getElementById("adamsAlertModal");
    if (modal) modal.classList.remove("adams-show");
    if (typeof _adamsAlertCb === "function") {
        _adamsAlertCb();
        _adamsAlertCb = null;
    }
};

/* -- showConfirm(message, onConfirm, type) -- */
window.showConfirm = function(message, onConfirm, type) {
    type = type || "warning";
    _adamsConfirmCb = onConfirm || null;
    var icon = _adamsIcons[type] || _adamsIcons.warning;
    var iconEl = document.getElementById("adamsConfirmIcon");
    if (iconEl) {
        iconEl.className = "adams-modal-icon " + icon.css;
        iconEl.textContent = icon.symbol;
    }
    var msgEl = document.getElementById("adamsConfirmMsg");
    if (msgEl) msgEl.textContent = message;
    var proceedBtn = document.getElementById("adamsConfirmProceed");
    if (proceedBtn) {
        proceedBtn.className = "adams-btn adams-btn-proceed"
            + (type === "danger" ? " adams-danger" : "");
        proceedBtn.textContent = (type === "danger") ? "Delete" : "Proceed";
    }
    var modal = document.getElementById("adamsConfirmModal");
    if (modal) modal.classList.add("adams-show");
};

/* -- adamsCloseConfirm(confirmed) -- */
window.adamsCloseConfirm = function(confirmed) {
    var modal = document.getElementById("adamsConfirmModal");
    if (modal) modal.classList.remove("adams-show");
    if (confirmed && typeof _adamsConfirmCb === "function") {
        _adamsConfirmCb();
    }
    _adamsConfirmCb = null;
};

/* -- Escape key -- */
document.addEventListener("keydown", function(e) {
    if (e.key === "Escape") {
        var a = document.getElementById("adamsAlertModal");
        var c = document.getElementById("adamsConfirmModal");
        if (a && a.classList.contains("adams-show")) adamsCloseAlert();
        if (c && c.classList.contains("adams-show")) adamsCloseConfirm(false);
    }
});

/* -- Backdrop click (with null checks) -- */
var _aAlert = document.getElementById("adamsAlertModal");
if (_aAlert) {
    _aAlert.addEventListener("click", function(e) {
        if (e.target === this) adamsCloseAlert();
    });
}
var _aConfirm = document.getElementById("adamsConfirmModal");
if (_aConfirm) {
    _aConfirm.addEventListener("click", function(e) {
        if (e.target === this) adamsCloseConfirm(false);
    });
}

/* -- confirmSubmit(el, msg, type) -- for onclick/onsubmit confirm replacements -- */
window.confirmSubmit = function(el, msg, type) {
    showConfirm(msg, function() {
        if (el && el.tagName === 'A' && el.href) {
            window.location.href = el.href;
        } else {
            var form;
            if (el && el.tagName === 'FORM') {
                form = el;
            } else if (el) {
                form = el.closest('form');
            }
            if (form) {
                form.onsubmit = null;
                var btn = form.querySelector('[type=submit]');
                if (btn) { btn.removeAttribute('onclick'); }
                form.submit();
            }
        }
    }, type || (msg.toLowerCase().indexOf('delete') >= 0 ? 'danger' : 'warning'));
    return false;
};

/* -- Auto-convert server message banners to modals -- */
var _sMsg = document.querySelector('.msg-success') || document.querySelector('.alert-success');
var _eMsg = document.querySelector('.msg-error') || document.querySelector('.error-msg') || document.querySelector('.alert-error');
if (_sMsg) {
    var _sTxt = _sMsg.textContent.trim();
    _sMsg.style.display = 'none';
    if (_sTxt.length > 0) {
        showAlert(_sTxt.replace(/^[^a-zA-Z0-9(]+/, ''), 'success');
    }
}
if (_eMsg) {
    var _eTxt = _eMsg.textContent.trim();
    _eMsg.style.display = 'none';
    if (_eTxt.length > 0) {
        showAlert(_eTxt.replace(/^[^a-zA-Z0-9(]+/, ''), 'error');
    }
}

/* -- Auto-detect URL parameter messages (?error=...&success=...) -- */
var _urlParams = new URLSearchParams(window.location.search);
var _urlError = _urlParams.get('error');
var _urlSuccess = _urlParams.get('success');
if (_urlError && !_eMsg) {
    showAlert(decodeURIComponent(_urlError.replace(/\+/g, ' ')), 'error');
}
if (_urlSuccess && !_sMsg) {
    showAlert(decodeURIComponent(_urlSuccess.replace(/\+/g, ' ')), 'success');
}
</script>
