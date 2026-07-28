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
 * Creates a new marathon event. Administrators only.
 */
@WebServlet(name = "AddEventServlet", urlPatterns = {"/AddEventServlet"})
public class AddEventServlet extends HttpServlet {

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

        String eventName = trim(request.getParameter("eventName"));
        String description = trim(request.getParameter("description"));
        String eventDate = trim(request.getParameter("eventDate"));

        if (eventName.isEmpty() || eventDate.isEmpty()) {
            response.sendRedirect("addEvent.jsp?error=empty");
            return;
        }

        double distance;
        double fee;
        try {
            distance = Double.parseDouble(request.getParameter("distance"));
            fee = Double.parseDouble(request.getParameter("fee"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("addEvent.jsp?error=number");
            return;
        }

        if (distance <= 0 || fee < 0) {
            response.sendRedirect("addEvent.jsp?error=range");
            return;
        }

        String sql = "INSERT INTO events (event_name, description, event_date, distance, fee) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eventName);
            ps.setString(2, description);
            ps.setString(3, eventDate);
            ps.setDouble(4, distance);
            ps.setDouble(5, fee);

            ps.executeUpdate();

            response.sendRedirect("manageEvents.jsp?status=added");

        } catch (Exception e) {
            log("Could not add event " + eventName, e);
            response.sendRedirect("addEvent.jsp?error=db");
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    @Override
    public String getServletInfo() {
        return "Creates a new marathon event";
    }
}
