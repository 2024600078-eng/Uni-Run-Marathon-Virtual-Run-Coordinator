package controller;

import java.io.IOException;
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

/**
 * Registers the signed in participant for an event.
 */
@WebServlet(name = "RegisterEventServlet", urlPatterns = {"/RegisterEventServlet"})
public class RegisterEventServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("events.jsp?error=invalid");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (!eventExists(conn, eventId)) {
                response.sendRedirect("events.jsp?error=notfound");
                return;
            }

            // Without this check a participant could join the same event again
            // every time they pressed the button.
            if (alreadyRegistered(conn, userId, eventId)) {
                response.sendRedirect("events.jsp?error=duplicate");
                return;
            }

            String sql = "INSERT INTO registrations (user_id, event_id, status) VALUES (?, ?, 'Registered')";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, eventId);
                ps.executeUpdate();
            }

            response.sendRedirect("dashboard.jsp?status=success");

        } catch (Exception e) {
            log("Could not register user " + userId + " for event " + eventId, e);
            response.sendRedirect("events.jsp?error=db");
        }
    }

    private boolean eventExists(Connection conn, int eventId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM events WHERE event_id = ?")) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean alreadyRegistered(Connection conn, int userId, int eventId) throws Exception {
        String sql = "SELECT 1 FROM registrations WHERE user_id = ? AND event_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Registers a participant for an event";
    }
}
