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
 * Lets an administrator delete a marathon event.
 *
 * The foreign keys on registrations and results are declared ON DELETE CASCADE,
 * so removing an event also removes the registrations and submitted results
 * that belong to it.
 */
@WebServlet(name = "DeleteEventServlet", urlPatterns = {"/DeleteEventServlet"})
public class DeleteEventServlet extends HttpServlet {

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

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("manageEvents.jsp?error=invalid");
            return;
        }

        String sql = "DELETE FROM events WHERE event_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eventId);

            int deleted = ps.executeUpdate();

            if (deleted > 0) {
                response.sendRedirect("manageEvents.jsp?status=deleted");
            } else {
                response.sendRedirect("manageEvents.jsp?error=notfound");
            }

        } catch (Exception e) {
            log("Could not delete event " + eventId, e);
            response.sendRedirect("manageEvents.jsp?error=db");
        }
    }

    @Override
    public String getServletInfo() {
        return "Deletes a marathon event";
    }
}
