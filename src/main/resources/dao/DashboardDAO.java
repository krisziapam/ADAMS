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

/**
 * Render/Supabase dashboard fixes:
 * 1) Uses the PostgreSQL schema's documents table instead of non-existing
 *    student_requirements.file_name / file_content columns.
 * 2) Returns both legacy underscore keys and servlet camelCase keys.
 * 3) Returns category arrays as [category_id, total], matching dashboard.jsp.
 * 4) Removes dependency on student_categories.sort_order, which is not in the
 *    converted PostgreSQL setup script.
 */
public class DashboardDAO {
    public Map<String, Integer> getDashboardStats(int totalRequirements) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total_students", 0);
        stats.put("complete_students", 0);
        stats.put("totalStudents", 0);
        stats.put("complete", 0);
        stats.put("pending", 0);

        String sql = """
            SELECT COUNT(DISTINCT s.student_id) AS total_students,
                   COUNT(DISTINCT CASE
                       WHEN COALESCE(sub.uploaded, 0) >= ? AND ? > 0 THEN s.student_id
                   END) AS complete_students
            FROM students s
            LEFT JOIN (
                SELECT sr.student_id, COUNT(DISTINCT sr.requirement_id) AS uploaded
                FROM student_requirements sr
                JOIN documents d ON d.student_requirement_id = sr.student_requirement_id
                GROUP BY sr.student_id
            ) sub ON s.student_id = sub.student_id
            WHERE COALESCE(s.is_archived, FALSE) = FALSE
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, totalRequirements);
            ps.setInt(2, totalRequirements);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_students");
                    int complete = rs.getInt("complete_students");
                    int pending = Math.max(0, total - complete);

                    stats.put("total_students", total);
                    stats.put("complete_students", complete);
                    stats.put("totalStudents", total);
                    stats.put("complete", complete);
                    stats.put("pending", pending);
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
            LEFT JOIN students s
              ON s.category_id = c.category_id
             AND COALESCE(s.is_archived, FALSE) = FALSE
            WHERE COALESCE(c.is_active, TRUE) = TRUE
            GROUP BY c.category_id, c.category_name
            ORDER BY c.category_id, c.category_name
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                breakdown.put(
                    rs.getString("category_name"),
                    new int[] { rs.getInt("category_id"), rs.getInt("total") }
                );
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
                SELECT sr.student_id, COUNT(DISTINCT sr.requirement_id) AS uploaded
                FROM student_requirements sr
                JOIN documents d ON d.student_requirement_id = sr.student_requirement_id
                GROUP BY sr.student_id
            ) sub ON s.student_id = sub.student_id
            WHERE COALESCE(s.is_archived, FALSE) = FALSE
            ORDER BY s.last_name, s.first_name
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                StudentReportRow row = new StudentReportRow();
                row.studentId = rs.getInt("student_id");
                String middle = rs.getString("middle_name");
                row.studentName = (rs.getString("last_name") + ", " + rs.getString("first_name") +
                        (middle == null || middle.isBlank() ? "" : " " + middle)).trim();
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
            SELECT sr.student_id, COUNT(DISTINCT sr.requirement_id) AS uploaded
            FROM student_requirements sr
            JOIN documents d ON d.student_requirement_id = sr.student_requirement_id
            GROUP BY sr.student_id
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("student_id"), rs.getInt("uploaded"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
