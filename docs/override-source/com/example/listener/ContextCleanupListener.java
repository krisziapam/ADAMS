package com.example.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

/** PostgreSQL-safe cleanup listener. Removed MySQL-specific cleanup thread dependency. */
@WebListener
public class ContextCleanupListener implements ServletContextListener {
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
            } catch (SQLException e) {
                System.err.println("Error deregistering JDBC driver " + driver + ": " + e.getMessage());
            }
        }
    }

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // No startup cleanup required.
    }
}
