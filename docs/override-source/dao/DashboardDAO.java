package dao;

import kyrie.DBConnection;
import model.StudentReportRow;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DashboardDAO {
    public Map<String, Integer> getDashboardStats(int totalRequirements) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total_students", 0);
        stats.put("complete_students", 0);
        stats.put("pending", 0);
        String sql = """
            SELECT COUNT(DISTINCT s.student_id) AS total_students,
                   COUNT(DISTINCT CASE WHEN COALESCE(sub.uploaded, 0) >= ? AND ? > 0 THEN s.student_id END) AS complete_students
            FROM students s
            LEFT JOIN (
                SELECT student_id, COUNT(DISTINCT requirement_id) AS uploaded
                FROM student_requirements
                WHERE file_name IS NOT NULL AND file_content IS NOT NULL
                GROUP BY student_id
            ) sub ON s.student_id = sub.student_id
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, totalRequirements);
            ps.setInt(2, totalRequirements);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_students");
                    int complete = rs.getInt("complete_students");
                    stats.put("total_students", total);
                    stats.put("complete_students", complete);
                    stats.put("pending", Math.max(0, total - complete));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public Map<String, int[]> getCategoryBreakdown() {
        Map<String, int[]> breakdown = new LinkedHashMap<>();
        String sql = """
            SELECT c.category_id, c.category_name, COUNT(s.student_id) AS total
            FROM student_categories c
            LEFT JOIN students s ON s.category_id = c.category_id
            GROUP BY c.category_id, c.category_name, c.sort_order
            ORDER BY c.sort_order, c.category_name
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                breakdown.put(rs.getString("category_name"), new int[] { rs.getInt("total") });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return breakdown;
    }

    public List<StudentReportRow> getReportRows(int totalRequirements) {
        List<StudentReportRow> rows = new ArrayList<>();
        String sql = """
            SELECT s.student_id,
                   s.last_name, s.first_name, s.middle_name,
                   s.email,
                   COALESCE(c.category_name, '—') AS category_name,
                   COALESCE(sub.uploaded, 0) AS submitted_count
            FROM students s
            LEFT JOIN student_categories c ON s.category_id = c.category_id
            LEFT JOIN (
                SELECT student_id, COUNT(DISTINCT requirement_id) AS uploaded
                FROM student_requirements
                WHERE file_name IS NOT NULL AND file_content IS NOT NULL
                GROUP BY student_id
            ) sub ON s.student_id = sub.student_id
            ORDER BY s.last_name, s.first_name
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                StudentReportRow row = new StudentReportRow();
                row.studentId = rs.getInt("student_id");
                String middle = rs.getString("middle_name");
                row.studentName = (rs.getString("last_name") + ", " + rs.getString("first_name") + (middle == null || middle.isBlank() ? "" : " " + middle)).trim();
                row.categoryName = rs.getString("category_name");
                row.email = rs.getString("email");
                row.submittedCount = rs.getInt("submitted_count");
                row.totalRequirements = totalRequirements;
                row.isComplete = totalRequirements > 0 && row.submittedCount >= totalRequirements;
                rows.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }

    public Map<Integer, Integer> getUploadCountMap() {
        Map<Integer, Integer> map = new HashMap<>();
        String sql = """
            SELECT student_id, COUNT(DISTINCT requirement_id) AS uploaded
            FROM student_requirements
            WHERE file_name IS NOT NULL AND file_content IS NOT NULL
            GROUP BY student_id
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("student_id"), rs.getInt("uploaded"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
