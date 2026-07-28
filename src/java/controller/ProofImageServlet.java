package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;
import util.UploadStore;

/**
 * Serves a proof image from the upload folder.
 *
 * The folder sits outside the application so that rebuilding the project does
 * not delete the images, which also means nothing there is reachable by URL on
 * its own. Every request therefore passes through this servlet, which only
 * returns an image to the participant who submitted it or to an administrator.
 */
@WebServlet(name = "ProofImageServlet", urlPatterns = {"/proof"})
public class ProofImageServlet extends HttpServlet {

    private static final int BUFFER_SIZE = 8192;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String fileName = request.getParameter("file");

        // Reject anything that is not a name this system generated, before it
        // is ever turned into a path.
        if (!UploadStore.isValidStoredName(fileName)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        boolean isAdmin = "admin".equals(session.getAttribute("role"));

        try {
            if (!isAdmin && !belongsToUser(fileName, userId)) {
                // A participant asking for somebody else's proof is told the
                // same thing as if the image did not exist.
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } catch (Exception e) {
            log("Could not check ownership of proof image " + fileName, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        File file = UploadStore.fileFor(fileName);

        if (!file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(contentTypeOf(fileName));
        response.setContentLength((int) file.length());
        // Personal content, so it may be held by the browser but not by any
        // shared cache in between.
        response.setHeader("Cache-Control", "private, max-age=600");

        try (InputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {

            byte[] buffer = new byte[BUFFER_SIZE];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }
    }

    /**
     * True when the image belongs to a result submitted by this participant.
     */
    private boolean belongsToUser(String fileName, int userId) throws Exception {
        String sql = "SELECT 1 FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "WHERE r.proof_image = ? AND reg.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fileName);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String contentTypeOf(String fileName) {
        return fileName.toLowerCase().endsWith(".png") ? "image/png" : "image/jpeg";
    }

    @Override
    public String getServletInfo() {
        return "Serves proof images to their owner or to an administrator";
    }
}
