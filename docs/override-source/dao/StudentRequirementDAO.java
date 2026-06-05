package dao;

import kyrie.DBConnection;
import model.StudentRequirement;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class StudentRequirementDAO {
    private StudentRequirement map(ResultSet rs) throws java.sql.SQLException {
        StudentRequirement sr = new StudentRequirement();
        sr.setStudentRequirementId(rs.getInt("student_requirement_id"));
        sr.setStudentId(String.valueOf(rs.getInt("student_id")));
        sr.setRequirementId(rs.getInt("requirement_id"));
        sr.setFileName(rs.getString("file_name"));
        sr.setFilePath(rs.getString("file_path"));
        sr.setMimeType(rs.getString("mime_type"));
        sr.setFileSize(rs.getLong("file_size"));
        sr.setStatus(rs.getString("status"));
        sr.setUploadDate(rs.getDate("upload_date"));
        sr.setUploadedAt(rs.getTimestamp("uploaded_at"));
        try { sr.setRequirementName(rs.getString("requirement_name")); } catch (Exception ignored) {}
        return sr;
    }

    public List<StudentRequirement> getRequirementsByStudent(String studentId) {
        List<StudentRequirement> list = new ArrayList<>();
        String sql = """
            SELECT sr.*, r.requirement_name
            FROM student_requirements sr
            LEFT JOIN requirement_types r ON sr.requirement_id = r.requirement_id
            WHERE sr.student_id = ?
            ORDER BY sr.student_requirement_id
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(studentId));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<StudentRequirement> getRequirementsByUser(int userId) {
        List<StudentRequirement> list = new ArrayList<>();
        String sql = """
            SELECT sr.*, r.requirement_name
            FROM student_requirements sr
            JOIN students s ON sr.student_id = s.student_id
            LEFT JOIN requirement_types r ON sr.requirement_id = r.requirement_id
            WHERE s.user_id = ?
            ORDER BY sr.student_requirement_id
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalCompleteStudents() {
        String sql = """
            SELECT COUNT(*) FROM students s
            WHERE (
                SELECT COUNT(*) FROM student_requirements sr
                WHERE sr.student_id = s.student_id AND sr.file_name IS NOT NULL AND sr.file_content IS NOT NULL
            ) >= (SELECT COUNT(*) FROM requirement_types)
            """;
        return scalarInt(sql, -1);
    }

    public int getTotalIncompleteStudents() {
        String sql = """
            SELECT COUNT(*) FROM students s
            WHERE (
                SELECT COUNT(*) FROM student_requirements sr
                WHERE sr.student_id = s.student_id AND sr.file_name IS NOT NULL AND sr.file_content IS NOT NULL
            ) < (SELECT COUNT(*) FROM requirement_types)
            """;
        return scalarInt(sql, -1);
    }

    public boolean updateStatus(int studentRequirementId, String status) {
        String sql = "UPDATE student_requirements SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE student_requirement_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, studentRequirementId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(int studentRequirementId) {
        String sql = "DELETE FROM student_requirements WHERE student_requirement_id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentRequirementId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean insert(StudentRequirement sr) {
        String sql = """
            INSERT INTO student_requirements
            (student_id, requirement_id, file_name, file_path, mime_type, file_size, status, upload_date, uploaded_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(sr.getStudentId()));
            ps.setInt(2, sr.getRequirementId());
            ps.setString(3, sr.getFileName());
            ps.setString(4, sr.getFilePath());
            ps.setString(5, sr.getMimeType());
            ps.setLong(6, sr.getFileSize());
            ps.setString(7, sr.getStatus());
            ps.setDate(8, sr.getUploadDate());
            ps.setTimestamp(9, sr.getUploadedAt());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getSubmittedCount(int studentId) {
        String sql = """
            SELECT LEAST(
                (SELECT COUNT(*) FROM student_requirements sr WHERE sr.student_id = ? AND sr.file_name IS NOT NULL),
                (SELECT COUNT(*) FROM requirement_types)
            ) AS safe_count
            """;
        return scalarInt(sql, studentId);
    }

    public int getCompletionPercent(int studentId) {
        String sql = """
            SELECT LEAST(100, ROUND(
                LEAST(
                    (SELECT COUNT(*) FROM student_requirements sr WHERE sr.student_id = ? AND sr.file_name IS NOT NULL),
                    (SELECT COUNT(*) FROM requirement_types)
                ) * 100.0 / NULLIF((SELECT COUNT(*) FROM requirement_types), 0)
            )) AS safe_percent
            """;
        return scalarInt(sql, studentId);
    }

    private int scalarInt(String sql, int parameter) {
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            if (parameter >= 0) ps.setInt(1, parameter);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
}
