package kyrie;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * PostgreSQL connection helper for the ADAMS Spring Boot package.
 * Defaults are Windows-localhost friendly and may be overridden with environment variables:
 * ADAMS_DB_URL, ADAMS_DB_USER, ADAMS_DB_PASSWORD.
 */
public class DBConnection {
    private static final String DEFAULT_URL = "jdbc:postgresql://localhost:5432/doc_admission_db";
    private static final String DEFAULT_USER = "postgres";
    private static final String DEFAULT_PASSWORD = "postgres";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("PostgreSQL JDBC Driver not found. Build/run with Maven so the postgresql dependency is included.");
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = firstNonBlank(System.getProperty("ADAMS_DB_URL"), System.getenv("ADAMS_DB_URL"), DEFAULT_URL);
        String user = firstNonBlank(System.getProperty("ADAMS_DB_USER"), System.getenv("ADAMS_DB_USER"), DEFAULT_USER);
        String password = firstNonBlank(System.getProperty("ADAMS_DB_PASSWORD"), System.getenv("ADAMS_DB_PASSWORD"), DEFAULT_PASSWORD);
        return DriverManager.getConnection(url, user, password);
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return "";
    }
}
