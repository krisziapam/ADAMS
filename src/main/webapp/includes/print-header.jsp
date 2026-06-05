
<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%
    String _ctx = request.getContextPath();
%>

<style>
    .pup-header {
        width: 100%;
        border-bottom: 2px solid #6d0f0f;
        margin: 0 0 10px 0;
        padding: 0 0 8px 0;
    }
    .pup-header-table {
        width: 100%;
        border-collapse: collapse;
    }
    .pup-header-table td {
        vertical-align: middle;
        padding: 0;
    }
    .pup-logo-cell {
        width: 60px;
        text-align: center;
    }
    .pup-logo-cell img {
        width: 55px;
        height: auto;
    }
    .pup-text-cell {
        text-align: center;
        padding: 0 8px;
    }
    .pup-text-cell .republic {
        font-size: 10px;
        color: #333;
        margin: 0;
    }
    .pup-text-cell .university {
        font-size: 13px;
        font-weight: bold;
        color: #6d0f0f;
        margin: 2px 0;
    }
    .pup-text-cell .office {
        font-size: 9px;
        color: #555;
        margin: 0;
    }
    .pup-text-cell .department {
        font-size: 9px;
        font-weight: bold;
        color: #333;
        margin: 0;
    }

    @media print {
        .pup-header {
            margin: 0 0 8px 0;
            padding: 0 0 6px 0;
        }
    }
</style>

<div class="pup-header">
    <table class="pup-header-table">
        <tr>
            
            <%-- RIGHT: PUP Seal --%>
            <td class="pup-logo-cell">
                <img src="<%= _ctx %>/assets/pup-logo.png"
                     alt="PUP Logo"
                     onerror="this.style.display='none'" />
            </td>

            <%-- CENTER: Text --%>
            <td class="pup-text-cell">
                <p class="republic">Republic of the Philippines</p>
                <p class="university">
                    POLYTECHNIC UNIVERSITY OF THE PHILIPPINES
                </p>
                <p class="office">
                    Office of the Vice President for Academic Affairs
                </p>
                <p class="department">
                    OPEN UNIVERSITY SYSTEM INSTITUTE OF OPEN AND DISTANCE EDUCATION
                </p>
            </td>

            <%-- LEFT: Bagong Pilipinas Logo --%>
            <td class="pup-logo-cell">
                <img src="<%= _ctx %>/assets/bagong-pilipinas.png"
                     alt="Bagong Pilipinas"
                     onerror="this.style.display='none'" />
            </td>
            
        </tr>
    </table>
</div>