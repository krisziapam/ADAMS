package dao;

import kyrie.DBConnection;
import model.User;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private User map(ResultSet rs) throws java.sql.SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setEmail(rs.getString("email"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setActive(rs.getBoolean("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setLastLogin(rs.getTimestamp("last_login"));
        return u;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = """
            SELECT * FROM users
            ORDER BY CASE role WHEN 'superadmin' THEN 1 WHEN 'admin' THEN 2 WHEN 'staff' THEN 3 ELSE 4 END, username
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public User getUserById(int userId) {
        return findOne("SELECT * FROM users WHERE user_id = ?", userId, null);
    }

    public User getUserByUsername(String username) {
        return findOne("SELECT * FROM users WHERE username = ?", -1, username);
    }

    public User getUserByEmail(String email) {
        return findOne("SELECT * FROM users WHERE email = ? AND is_active = TRUE LIMIT 1", -1, email);
    }

    private User findOne(String sql, int intValue, String stringValue) {
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            if (stringValue != null) ps.setString(1, stringValue); else ps.setInt(1, intValue);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    public boolean createUser(User user) {
        String sql = """
            INSERT INTO users (username, password, email, full_name, phone, role, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, TRUE, CURRENT_TIMESTAMP)
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateProfile(int userId, String fullName, String email, String phone) {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName); ps.setString(2, email); ps.setString(3, phone); ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updatePassword(int userId, String password) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, password); ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean adminUpdateUser(int userId, String fullName, String email, String phone, String role, boolean active) {
        String sql = """
            UPDATE users
            SET full_name = ?, email = ?, phone = ?, role = ?, is_active = ?
            WHERE user_id = ?
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName); ps.setString(2, email); ps.setString(3, phone); ps.setString(4, role); ps.setBoolean(5, active); ps.setInt(6, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteUser(int userId) {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement("UPDATE students SET user_id = NULL WHERE user_id = ?");
                 PreparedStatement ps2 = con.prepareStatement("UPDATE activity_log SET user_id = NULL WHERE user_id = ?");
                 PreparedStatement ps3 = con.prepareStatement("DELETE FROM users WHERE user_id = ?")) {
                ps1.setInt(1, userId); ps1.executeUpdate();
                ps2.setInt(1, userId); ps2.executeUpdate();
                ps3.setInt(1, userId);
                boolean ok = ps3.executeUpdate() > 0;
                con.commit();
                return ok;
            } catch (Exception e) { con.rollback(); throw e; }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateLastLogin(int userId) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() && rs.getInt(1) > 0; }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public String getPasswordById(int userId) {
        String sql = "SELECT password FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString("password") : null; }
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    public User authenticateUser(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND is_active = TRUE";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword(password));
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    public static String hashPassword(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new RuntimeException("Unable to hash password", e);
        }
    }
}
