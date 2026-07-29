package controller;

import dao.EventDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Event;

/**
 * CONTROLLER COMPONENT
 *
 * Updates an existing marathon event. Administrators only.
 */
@WebServlet(name = "EditEventServlet", urlPatterns = {"/EditEventServlet"})
public class EditEventServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

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
            eventId = Integer.parseInt(request.getParameter("eventId"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("manageEvents.jsp?error=invalid");
            return;
        }

        String eventName = trim(request.getParameter("eventName"));
        String description = trim(request.getParameter("description"));
        String eventDate = trim(request.getParameter("eventDate"));

        if (eventName.isEmpty() || eventDate.isEmpty()) {
            response.sendRedirect("editEvent.jsp?id=" + eventId + "&error=empty");
            return;
        }

        double distance;
        double fee;
        try {
            distance = Double.parseDouble(request.getParameter("distance"));
            fee = Double.parseDouble(request.getParameter("fee"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("editEvent.jsp?id=" + eventId + "&error=number");
            return;
        }

        if (distance <= 0 || fee < 0) {
            response.sendRedirect("editEvent.jsp?id=" + eventId + "&error=range");
            return;
        }

        try {
            Event event = new Event(eventName, description, eventDate, distance, fee);
            event.setEventId(eventId);

            if (eventDAO.update(event)) {
                response.sendRedirect("manageEvents.jsp?status=updated");
            } else {
                response.sendRedirect("manageEvents.jsp?error=notfound");
            }

        } catch (Exception e) {
            log("Could not update event " + eventId, e);
            response.sendRedirect("editEvent.jsp?id=" + eventId + "&error=db");
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    @Override
    public String getServletInfo() {
        return "Updates an existing marathon event";
    }
}
