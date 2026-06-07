package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.List;
import java.util.Properties;
import java.util.regex.Matcher;

public class EmailUtil {

    private static final String SMTP_HOST =
            System.getenv().getOrDefault("ADAMS_MAIL_HOST", "smtp.gmail.com");

    private static final String SMTP_PORT =
            System.getenv().getOrDefault("ADAMS_MAIL_PORT", "465");

    private static final String FROM_EMAIL =
            System.getenv("ADAMS_MAIL_USER");

    private static final String APP_PASSWORD =
            System.getenv("ADAMS_MAIL_PASSWORD");

    private static final String FROM_NAME =
            System.getenv().getOrDefault(
                    "ADAMS_MAIL_FROM_NAME",
                    "ADAMS - Automated Document Admission Management System"
            );

    private static String appBase() {
        String base = System.getenv().getOrDefault(
                "ADAMS_APP_URL",
                "https://adams-5nk2.onrender.com"
        );

        if (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }

        return base;
    }

    private static String fixUrls(String text) {
        if (text == null) {
            return "";
        }

        String base = appBase();

        String fixed = text;

        fixed = fixed.replace("http://192.168.254.103:8081", base);
        fixed = fixed.replace("http://localhost:8081", base);
        fixed = fixed.replace("http://localhost:8080", base);
        fixed = fixed.replace("http://127.0.0.1:8081", base);
        fixed = fixed.replace("http://127.0.0.1:8080", base);

        fixed = fixed.replaceAll(
                "http://192\\.168\\.\\d+\\.\\d+:\\d+",
                Matcher.quoteReplacement(base)
        );

        return fixed;
    }

    private static String esc(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public static void sendEmail(String toEmail, String subject, String htmlBody) {
        try {
            if (FROM_EMAIL == null || FROM_EMAIL.isBlank()) {
                throw new IllegalStateException("Missing ADAMS_MAIL_USER in Render environment variables.");
            }

            if (APP_PASSWORD == null || APP_PASSWORD.isBlank()) {
                throw new IllegalStateException("Missing ADAMS_MAIL_PASSWORD in Render environment variables.");
            }

            if (toEmail == null || toEmail.isBlank()) {
                throw new IllegalArgumentException("Recipient email is empty.");
            }

            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.ssl.enable", "465".equals(SMTP_PORT));
            props.put("mail.smtp.starttls.enable", "587".equals(SMTP_PORT));
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.smtp.connectiontimeout", "10000");
            props.put("mail.smtp.timeout", "10000");
            props.put("mail.smtp.writetimeout", "10000");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject, "UTF-8");
            message.setContent(fixUrls(htmlBody), "text/html; charset=UTF-8");

            Transport.send(message);

            System.out.println("[EMAIL] Sent to: " + toEmail);

        } catch (Exception e) {
            System.err.println("[EMAIL] Failed to send to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendStudentWelcome(
            String toEmail,
            String studentName,
            String category,
            List<String> requirements,
            String uploadLink
    ) {
        StringBuilder reqList = new StringBuilder();

        if (requirements != null && !requirements.isEmpty()) {
            for (String req : requirements) {
                reqList.append("<li>").append(esc(req)).append("</li>");
            }
        } else {
            reqList.append("<li>No listed requirements yet.</li>");
        }

        String body =
                "<h2>Welcome to ADAMS</h2>" +
                "<p>Dear <b>" + esc(studentName) + "</b>,</p>" +
                "<p>Your student record has been created successfully.</p>" +
                "<p><b>Category:</b> " + esc(category) + "</p>" +
                "<p><b>Required Documents:</b></p>" +
                "<ul>" + reqList + "</ul>" +
                "<p>You may access your upload page here:</p>" +
                "<p><a href='" + fixUrls(uploadLink) + "'>Open ADAMS Upload Page</a></p>" +
                "<br><p>Thank you.</p>" +
                "<p>ADAMS - Automated Document Admission Management System</p>";

        sendEmail(toEmail, "Welcome to ADAMS - Document Submission Guide", body);
    }

    public static void sendFileUploaded(
            String toEmail,
            String studentName,
            String requirementName,
            String uploadedBy,
            String uploadedAt
    ) {
        String body =
                "<h2>Document Uploaded</h2>" +
                "<p>Dear <b>" + esc(studentName) + "</b>,</p>" +
                "<p>A document has been uploaded to your ADAMS record.</p>" +
                "<p><b>Requirement:</b> " + esc(requirementName) + "</p>" +
                "<p><b>Uploaded by:</b> " + esc(uploadedBy) + "</p>" +
                "<p><b>Date/Time:</b> " + esc(uploadedAt) + "</p>";

        sendEmail(toEmail, "Document Uploaded - ADAMS", body);
    }

    public static void sendSubmissionComplete(
            String toEmail,
            String studentName,
            String referenceNumber,
            int submittedCount,
            int totalRequirements,
            String verifyLink
    ) {
        String body =
                "<h2>Submission Complete</h2>" +
                "<p>Dear <b>" + esc(studentName) + "</b>,</p>" +
                "<p>Your document submission is now complete.</p>" +
                "<p><b>Reference Number:</b> " + esc(referenceNumber) + "</p>" +
                "<p><b>Submitted:</b> " + submittedCount + " of " + totalRequirements + "</p>" +
                "<p><a href='" + fixUrls(verifyLink) + "'>Verify Submission</a></p>";

        sendEmail(toEmail, "Submission Complete - ADAMS", body);
    }

    public static void sendAccountCreated(
            String toEmail,
            String username,
            String role,
            String loginLink
    ) {
        String body =
                "<h2>ADAMS Account Created</h2>" +
                "<p>Your ADAMS account has been created.</p>" +
                "<p><b>Username:</b> " + esc(username) + "</p>" +
                "<p><b>Role:</b> " + esc(role) + "</p>" +
                "<p><a href='" + fixUrls(loginLink) + "'>Login to ADAMS</a></p>";

        sendEmail(toEmail, "ADAMS Account Created", body);
    }

    public static void sendPasswordChanged(
            String toEmail,
            String username,
            String changedAt,
            String ipAddress
    ) {
        String body =
                "<h2>Password Changed</h2>" +
                "<p>Your ADAMS password was changed successfully.</p>" +
                "<p><b>Username:</b> " + esc(username) + "</p>" +
                "<p><b>Changed At:</b> " + esc(changedAt) + "</p>" +
                "<p><b>IP Address:</b> " + esc(ipAddress) + "</p>";

        sendEmail(toEmail, "Password Changed - ADAMS", body);
    }

    public static void sendCategoryUpdated(
            String toEmail,
            String studentName,
            String oldCategory,
            String newCategory
    ) {
        String body =
                "<h2>Student Category Updated</h2>" +
                "<p>Dear <b>" + esc(studentName) + "</b>,</p>" +
                "<p>Your student category has been updated.</p>" +
                "<p><b>Previous Category:</b> " + esc(oldCategory) + "</p>" +
                "<p><b>New Category:</b> " + esc(newCategory) + "</p>";

        sendEmail(toEmail, "Category Updated - ADAMS", body);
    }

    public static void sendEmailChanged(
            String toOldEmail,
            String studentName,
            String newEmail
    ) {
        String body =
                "<h2>Email Address Updated</h2>" +
                "<p>Dear <b>" + esc(studentName) + "</b>,</p>" +
                "<p>Your registered email address has been updated.</p>" +
                "<p><b>New Email:</b> " + esc(newEmail) + "</p>";

        sendEmail(toOldEmail, "Email Address Updated - ADAMS", body);
    }

    public static void sendPasswordReset(
            String toEmail,
            String username,
            String resetLink
    ) {
        String fixedResetLink = fixUrls(resetLink);

        String body =
                "<h2>Password Reset Request</h2>" +
                "<p>Dear <b>" + esc(username) + "</b>,</p>" +
                "<p>We received a request to reset your ADAMS password.</p>" +
                "<p>This link expires in 30 minutes.</p>" +
                "<p><a href='" + fixedResetLink + "'>Reset My Password</a></p>" +
                "<p>Or copy this link:</p>" +
                "<p>" + esc(fixedResetLink) + "</p>";

        sendEmail(toEmail, "Password Reset - ADAMS", body);
    }
}
