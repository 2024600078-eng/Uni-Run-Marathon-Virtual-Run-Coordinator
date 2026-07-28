package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

/**
 * Lets an administrator remove a participant account.
 *
 * The foreign keys on registrations and results are declared ON DELETE CASCADE,
 * so the participant's registrations and submitted results go with them.
 */
@WebServlet(name = "DeleteParticipantServlet", urlPatterns = {"/DeleteParticipantServlet"})
public class DeleteParticipantServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (!"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("manageParticipants.jsp?error=invalid");
            return;
        }

        // An administrator must not be able to delete their own account, or any
        // other administrator, from this screen.
        Integer currentUserId = (Integer) session.getAttribute("userId");
        if (currentUserId != null && currentUserId.intValue() == userId) {
            response.sendRedirect("manageParticipants.jsp?error=protected");
            return;
        }

        // The role condition in the statement means an administrator row can
        // never be removed here, even if its id is supplied by hand.
        String sql = "DELETE FROM users WHERE user_id = ? AND role = 'participant'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            int deleted = ps.executeUpdate();

            if (deleted > 0) {
                response.sendRedirect("manageParticipants.jsp?status=deleted");
            } else {
                response.sendRedirect("manageParticipants.jsp?error=protected");
            }

        } catch (Exception e) {
            log("Could not delete participant " + userId, e);
            response.sendRedirect("manageParticipants.jsp?error=db");
        }
    }

    @Override
    public String getServletInfo() {
        return "Removes a participant account";
    }
}
