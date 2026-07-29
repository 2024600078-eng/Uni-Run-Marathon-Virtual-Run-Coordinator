package controller;

import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import util.PasswordUtil;

/**
 * CONTROLLER COMPONENT
 *
 * Authenticates a user and starts their session.
 *
 * This class is a controller, so it does three things and no more: it reads
 * the request, asks the Model for the data it needs, and decides which View
 * the visitor should see next. It contains no SQL of its own; the query lives
 * in UserDAO.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * There is nothing to show for a direct GET, so send the visitor to the
     * login form instead of rendering a blank page.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Read the input the View collected.
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");

        if (email.isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        try {
            // 2. Ask the Model for the account.
            User user = userDAO.findByEmail(email);

            // 3. Apply the system logic: does the supplied password hash to
            //    the same value as the stored one?
            if (user == null || !PasswordUtil.matches(password, user.getPassword())) {
                // Deliberately the same message for an unknown email and a
                // wrong password, so the page cannot be used to discover
                // which addresses have accounts.
                response.sendRedirect("login.jsp?error=invalid");
                return;
            }

            // Drop any session the visitor arrived with before storing the
            // login details, so a pre-set session id cannot be reused.
            HttpSession existing = request.getSession(false);
            if (existing != null) {
                existing.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60);

            // 4. Choose the View that matches the user's role.
            response.sendRedirect(user.isAdmin() ? "adminDashboard.jsp" : "dashboard.jsp");

        } catch (Exception e) {
            log("Login failed for email " + email, e);
            response.sendRedirect("login.jsp?error=server");
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    @Override
    public String getServletInfo() {
        return "Authenticates a user and starts their session";
    }
}
