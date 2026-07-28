package controller;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import util.DBConnection;
import util.UploadStore;

/**
 * Records a race result submitted by a participant, together with the proof
 * image they uploaded.
 *
 * A participant gets one result per registration. If an administrator rejects
 * that result they are allowed to send a corrected one, which replaces the
 * rejected entry and puts it back in the queue as Pending. While a result is
 * Pending or already Approved, no further submission is accepted.
 */
@WebServlet(name = "ResultSubmissionServlet", urlPatterns = {"/ResultSubmissionServlet"})
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class ResultSubmissionServlet extends HttpServlet {

    /**
     * Only these image types may be saved, checked by extension and by the
     * type the browser reports.
     */
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png");
    private static final List<String> ALLOWED_CONTENT_TYPES =
            Arrays.asList("image/jpeg", "image/png");

    /** Accepts h:mm:ss or hh:mm:ss. */
    private static final String DURATION_PATTERN = "^\\d{1,2}:[0-5]\\d:[0-5]\\d$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("submitResult.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        int registrationId;
        try {
            registrationId = Integer.parseInt(request.getParameter("registrationId"));
        } catch (NumberFormatException | NullPointerException e) {
            fail(request, response, "Please choose the event you are submitting a result for.");
            return;
        }

        double distanceAchieved;
        try {
            distanceAchieved = Double.parseDouble(request.getParameter("distanceAchieved"));
        } catch (NumberFormatException | NullPointerException e) {
            fail(request, response, "Please enter the distance you completed.");
            return;
        }

        if (distanceAchieved <= 0) {
            fail(request, response, "Distance must be greater than zero.");
            return;
        }

        String duration = request.getParameter("duration");
        if (duration == null || !duration.trim().matches(DURATION_PATTERN)) {
            fail(request, response, "Please enter the duration as hh:mm:ss, for example 01:23:45.");
            return;
        }
        duration = duration.trim();

        try (Connection conn = DBConnection.getConnection()) {

            // The registration id arrives from a form field, so confirm it
            // really belongs to the person who is signed in. Otherwise one
            // participant could file a result against somebody else's entry.
            if (!registrationBelongsToUser(conn, registrationId, userId)) {
                fail(request, response, "That event registration does not belong to your account.");
                return;
            }

            ExistingResult existing = findExistingResult(conn, registrationId);

            if (existing != null && !"Rejected".equalsIgnoreCase(existing.approvalStatus)) {
                if ("Approved".equalsIgnoreCase(existing.approvalStatus)) {
                    fail(request, response,
                            "Your result for this event has already been approved.");
                } else {
                    fail(request, response,
                            "You have already submitted a result for this event. "
                          + "Please wait for it to be reviewed.");
                }
                return;
            }

            Part filePart = request.getPart("proofImage");

            if (filePart == null || filePart.getSize() == 0) {
                fail(request, response, "Please attach a proof image.");
                return;
            }

            String extension = extensionOf(getSubmittedFileName(filePart));

            if (!ALLOWED_EXTENSIONS.contains(extension)
                    || !ALLOWED_CONTENT_TYPES.contains(lower(filePart.getContentType()))) {
                fail(request, response, "Proof image must be a JPG or PNG file.");
                return;
            }

            // A generated name is used so that nothing the user typed can
            // influence where the file lands on disk.
            String storedFileName = UUID.randomUUID().toString() + "." + extension;

            File target = new File(UploadStore.directory(), storedFileName);
            filePart.write(target.getAbsolutePath());

            if (existing == null) {
                insertResult(conn, registrationId, distanceAchieved, duration, storedFileName);
                response.sendRedirect("viewResultStatus.jsp?status=submitted");
            } else {
                // Replacing a rejected entry: update it in place and return it
                // to the review queue.
                updateRejectedResult(conn, existing.resultId, distanceAchieved,
                                     duration, storedFileName);
                UploadStore.deleteQuietly(existing.proofImage);
                response.sendRedirect("viewResultStatus.jsp?status=resubmitted");
            }

        } catch (Exception e) {
            log("Could not save result for registration " + registrationId, e);
            fail(request, response, "Sorry, the result could not be saved. Please try again.");
        }
    }

    /** The state of a result that already exists for a registration. */
    private static final class ExistingResult {
        private final int resultId;
        private final String approvalStatus;
        private final String proofImage;

        private ExistingResult(int resultId, String approvalStatus, String proofImage) {
            this.resultId = resultId;
            this.approvalStatus = approvalStatus;
            this.proofImage = proofImage;
        }
    }

    private ExistingResult findExistingResult(Connection conn, int registrationId)
            throws Exception {

        String sql = "SELECT result_id, approval_status, proof_image "
                   + "FROM results WHERE registration_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new ExistingResult(
                        rs.getInt("result_id"),
                        rs.getString("approval_status"),
                        rs.getString("proof_image"));
            }
        }
    }

    private void insertResult(Connection conn, int registrationId, double distance,
                              String duration, String proofImage) throws Exception {

        String sql = "INSERT INTO results (registration_id, distance_achieved, duration, "
                   + "proof_image, approval_status) VALUES (?, ?, ?, ?, 'Pending')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, registrationId);
            ps.setDouble(2, distance);
            ps.setString(3, duration);
            ps.setString(4, proofImage);
            ps.executeUpdate();
        }
    }

    private void updateRejectedResult(Connection conn, int resultId, double distance,
                                      String duration, String proofImage) throws Exception {

        String sql = "UPDATE results SET distance_achieved = ?, duration = ?, proof_image = ?, "
                   + "approval_status = 'Pending', submission_date = CURRENT_TIMESTAMP "
                   + "WHERE result_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, distance);
            ps.setString(2, duration);
            ps.setString(3, proofImage);
            ps.setInt(4, resultId);
            ps.executeUpdate();
        }
    }

    private boolean registrationBelongsToUser(Connection conn, int registrationId, int userId)
            throws Exception {
        String sql = "SELECT 1 FROM registrations WHERE registration_id = ? AND user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, registrationId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Returns the lowercase extension of a filename, without the dot, or an
     * empty string when there is none.
     */
    private String extensionOf(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot == fileName.length() - 1) {
            return "";
        }
        return lower(fileName.substring(dot + 1));
    }

    /**
     * Reads the original filename from the upload, keeping only the last path
     * segment so that a name such as "..\\..\\shell.jsp" cannot escape the
     * upload folder.
     */
    private String getSubmittedFileName(Part part) {
        String name = part.getSubmittedFileName();
        if (name == null) {
            return "";
        }
        name = name.replace('\\', '/');
        int slash = name.lastIndexOf('/');
        return slash < 0 ? name : name.substring(slash + 1);
    }

    private static String lower(String value) {
        return value == null ? "" : value.toLowerCase(Locale.ROOT);
    }

    /**
     * Shows the submission form again with an explanation of what went wrong.
     */
    private void fail(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("submitResult.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Handles submission and resubmission of race results";
    }
}
