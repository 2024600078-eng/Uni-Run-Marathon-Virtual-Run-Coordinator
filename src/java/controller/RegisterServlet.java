package controller;

import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.PasswordUtil;

/**
 * CONTROLLER COMPONENT
 *
 * Creates a new participant account.
 *
 * The validation rules live here because they are system logic. The storing
 * of the account is delegated to UserDAO, which is the only class that talks
 * to the database.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    private static final int MIN_PASSWORD_LENGTH = 6;

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = trim(request.getParameter("full_name"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");

        // Validate on the server as well as in the browser, because the HTML
        // "required" attributes can be bypassed.
        if (fullName.isEmpty() || email.isEmpty() || password == null || password.isEmpty()) {
            forwardBack(request, response, "Please fill in every field.", fullName, email);
            return;
        }

        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            forwardBack(request, response, "Please enter a valid email address.", fullName, email);
            return;
        }

        if (password.length() < MIN_PASSWORD_LENGTH) {
            forwardBack(request, response,
                    "Password must be at least " + MIN_PASSWORD_LENGTH + " characters long.",
                    fullName, email);
            return;
        }

        try {
            if (userDAO.emailExists(email)) {
                forwardBack(request, response,
                        "That email address is already registered. Please log in instead.",
                        fullName, email);
                return;
            }

            // Only the hash reaches the Model, never the password itself.
            userDAO.insertParticipant(fullName, email, PasswordUtil.hash(password));

            response.sendRedirect("login.jsp?status=registered");

        } catch (Exception e) {
            log("Registration failed for email " + email, e);
            forwardBack(request, response,
                    "Sorry, the account could not be created. Please try again.",
                    fullName, email);
        }
    }

    /**
     * Sends the visitor back to the form with an explanation, keeping what they
     * already typed so they do not have to start again.
     */
    private void forwardBack(HttpServletRequest request, HttpServletResponse response,
                             String message, String fullName, String email)
            throws ServletException, IOException {

        request.setAttribute("error", message);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    @Override
    public String getServletInfo() {
        return "Creates a new participant account";
    }
}
