let idleTime = 0;
const IDLE_LIMIT = 15 * 60;   // 15 minutes (seconds)
const WARNING_TIME = 14 * 60; // 14 minutes

function resetIdleTimer() {
    idleTime = 0;
}

// User activity resets timer
window.onload = resetIdleTimer;
document.onmousemove = resetIdleTimer;
document.onkeypress = resetIdleTimer;
document.onclick = resetIdleTimer;
document.onscroll = resetIdleTimer;

setInterval(() => {
    idleTime++;

    // ⚠️ Warning at 14 minutes
    if (idleTime === WARNING_TIME) {
        showAlert("You will be logged out in 1 minute due to inactivity.", "warning");
    }

    // 🔒 Auto logout at 15 minutes
    if (idleTime >= IDLE_LIMIT) {
        showAlert("Session expired due to inactivity.", "warning");
        window.location.href = window.contextPath + "/logout";
    }
}, 1000);