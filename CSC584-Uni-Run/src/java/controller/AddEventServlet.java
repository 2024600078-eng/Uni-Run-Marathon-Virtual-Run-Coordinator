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
 * Creates a new marathon event. Administrators only.
 *
 * The controller checks permission, validates the input, builds an Event
 * object and hands it to the Model to be stored.
 */
@WebServlet(name = "AddEventServlet", urlPatterns = {"/AddEventServlet"})
public class AddEventServlet extends HttpServlet {

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

        try {
            eventDAO.insert(new Event(eventName, description, eventDate, distance, fee));
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
