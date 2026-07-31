package controller;

import dao.EventDAO;
import dao.RegistrationDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * CONTROLLER COMPONENT
 *
 * Registers the signed in participant for an event.
 *
 * A clear example of the controller holding the system logic: it asks the
 * Model whether the event exists and whether the participant already joined
 * it, and only then asks the Model to store the registration.
 */
@WebServlet(name = "RegisterEventServlet", urlPatterns = {"/RegisterEventServlet"})
public class RegisterEventServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

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

        try {
            if (!eventDAO.exists(eventId)) {
                response.sendRedirect("events.jsp?error=notfound");
                return;
            }

            // Without this check a participant could join the same event again
            // every time they pressed the button.
            if (registrationDAO.exists(userId, eventId)) {
                response.sendRedirect("events.jsp?error=duplicate");
                return;
            }

            registrationDAO.insert(userId, eventId);
            response.sendRedirect("dashboard.jsp?status=success");

        } catch (Exception e) {
            log("Could not register user " + userId + " for event " + eventId, e);
            response.sendRedirect("events.jsp?error=db");
        }
    }

    @Override
    public String getServletInfo() {
        return "Registers a participant for an event";
    }
}
