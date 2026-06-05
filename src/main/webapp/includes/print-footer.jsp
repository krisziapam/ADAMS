<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<style>
    /* ========== ON-SCREEN FOOTER ========== */
    .pup-footer-screen {
        margin-top: 20px;
        padding-top: 8px;
        border-top: 2px solid #6d0f0f;
        text-align: center;
        font-size: 9px;
        color: #555;
    }
    .pup-footer-screen .address { margin: 0; font-size: 9px; color: #333; }
    .pup-footer-screen .contact { margin: 2px 0; font-size: 9px; }
    .pup-footer-screen .vandam-tag {
        margin-top: 4px; font-size: 8px;
        font-weight: bold; color: #6d0f0f;
    }

    /* ========== FIXED PRINT FOOTER ========== */
    .pup-footer-print {
        display: none;
    }

    @media print {
        /* ✅ HIDE the on-screen footer when printing */
        .pup-footer-screen {
            display: none !important;
        }

        /* ✅ SHOW only the fixed footer when printing */
        .pup-footer-print {
            display: block;
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 1.5cm;
            background: #fff;
            text-align: center;
            padding-top: 4px;
            font-size: 9px;
            color: #555;
            border-top: 1.5px solid #6d0f0f;
        }
        .pup-footer-print .pf-address {
            font-size: 8.5px; color: #333; margin: 2px 0;
        }
        .pup-footer-print .pf-contact {
            font-size: 8px; color: #555; margin: 1px 0;
        }
        .pup-footer-print .pf-vandam {
            font-size: 8px; font-weight: bold;
            color: #6d0f0f; margin-top: 2px;
        }
    }
</style>

<%-- ══ ON-SCREEN ONLY (hidden when printing) ══ --%>
<div class="pup-footer-screen">
    <p class="address">
        PUP A. Mabini Campus, Anonas Street,
        Sta. Mesa, Manila 1016
    </p>
    <p class="contact">
        Trunk Line: 335-1787 or 335-1777
        &nbsp;|&nbsp; Website: www.pup.edu.ph
    </p>
    <p class="vandam-tag">
        ✔ VERIFIED BY SYSTEM — ADAMS - Automated Document Admission Management System
    </p>
</div>

<%-- ══ PRINT ONLY (fixed to bottom of every page) ══ --%>
<div class="pup-footer-print">
    <p class="pf-address">
        PUP A. Mabini Campus, Anonas Street,
        Sta. Mesa, Manila 1016
    </p>
    <p class="pf-contact">
        Trunk Line: 335-1787 or 335-1777
        &nbsp;|&nbsp; www.pup.edu.ph
    </p>
    <p class="pf-vandam">
        ✔ VERIFIED BY SYSTEM — ADAMS - Automated Document Admission Management System
    </p>
</div>
