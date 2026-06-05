# Technical Notes

The original application was not a native Spring MVC application. It was a Jakarta JSP/Servlet application packaged as a WAR. To make it work with Spring Boot and PostgreSQL, this package keeps the existing JSP/Servlet architecture and runs it through Spring Boot embedded Tomcat.

Key conversions made:

- MySQL JDBC connection replaced with PostgreSQL JDBC.
- MySQL cleanup listener dependency removed.
- MySQL `ON DUPLICATE KEY UPDATE` converted to PostgreSQL `ON CONFLICT`.
- MySQL `CAST(... AS UNSIGNED)` removed from dashboard queries.
- User login and active-user checks changed from MySQL-style `is_active = 1` to PostgreSQL boolean logic.
- Student requirement queries adjusted to avoid PostgreSQL integer/text comparison issues.
- Database schema expanded to include both the updated SQL tables and compatibility columns required by the existing application code.

The SQL file is intentionally a clean-reset development/demo setup. Do not run it against production data without removing the `DROP TABLE` section.
