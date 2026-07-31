package controller;

import dao.UserDAO;
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
 * Lets an administrator remove a participant account. The cascading foreign
 * keys mean their registrations and results go with them.
 */
@WebServlet(name = "DeleteParticipantServlet", urlPatterns = {"/DeleteParticipantServlet"})
public class DeleteParticipantServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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

        // An administrator must not be able to delete their own account from
        // this screen. The DAO additionally refuses to delete any admin row.
        Integer currentUserId = (Integer) session.getAttribute("userId");
        if (currentUserId != null && currentUserId.intValue() == userId) {
            response.sendRedirect("manageParticipants.jsp?error=protected");
            return;
        }

        try {
            if (userDAO.deleteParticipant(userId)) {
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
