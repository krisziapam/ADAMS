<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%
    String _ctx = request.getContextPath();
%>

<div style="
    background: #fff;
    padding: 14px 24px;
    margin-bottom: 20px;
    border-bottom: 3px solid #6d0f0f;
    border-radius: 8px 8px 0 0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);">

    <div style="
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 16px;">

        <img src="<%= _ctx %>/assets/pup-logo.png"
             alt="PUP Logo"
             style="width: 60px; height: 60px; object-fit: contain;" />

        <div style="text-align: center; line-height: 1.4;">
            <p style="font-size: 9px; color: #888; margin: 0;
                      letter-spacing: 1px;">
                REPUBLIC OF THE PHILIPPINES
            </p>
            <p style="font-size: 13px; color: #6d0f0f; margin: 2px 0;
                      font-weight: bold; letter-spacing: 0.5px;">
                POLYTECHNIC UNIVERSITY OF THE PHILIPPINES
            </p>
            <p style="font-size: 10px; color: #444; margin: 0;
                      font-weight: bold;">
                OPEN UNIVERSITY SYSTEM
            </p>
            <p style="font-size: 9px; color: #555; margin: 0;">
                INSTITUTE OF OPEN AND DISTANCE EDUCATION
            </p>
        </div>

        <img src="<%= _ctx %>/assets/pup-ou-logo.png"
             alt="PUP OU Logo"
             style="width: 60px; height: 60px; object-fit: contain;" />

    </div>
</div>