package controller;

import dao.EventDAO;
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
 * Deletes a marathon event. Administrators only.
 *
 * The foreign keys on registrations and results are declared ON DELETE
 * CASCADE, so removing an event also removes the registrations and submitted
 * results that belong to it.
 */
@WebServlet(name = "DeleteEventServlet", urlPatterns = {"/DeleteEventServlet"})
public class DeleteEventServlet extends HttpServlet {

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
            eventId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("manageEvents.jsp?error=invalid");
            return;
        }

        try {
            if (eventDAO.delete(eventId)) {
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
