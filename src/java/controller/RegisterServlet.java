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
import util.DBConnection;
import util.PasswordUtil;

/**
 * Creates a new participant account.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    private static final int MIN_PASSWORD_LENGTH = 6;

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

        try (Connection conn = DBConnection.getConnection()) {

            if (emailAlreadyUsed(conn, email)) {
                forwardBack(request, response,
                        "That email address is already registered. Please log in instead.",
                        fullName, email);
                return;
            }

            String sql = "INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, 'participant')";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, fullName);
                ps.setString(2, email);
                // Only the hash is stored, never the password itself.
                ps.setString(3, PasswordUtil.hash(password));

                ps.executeUpdate();
            }

            response.sendRedirect("login.jsp?status=registered");

        } catch (Exception e) {
            log("Registration failed for email " + email, e);
            forwardBack(request, response,
                    "Sorry, the account could not be created. Please try again.",
                    fullName, email);
        }
    }

    private boolean emailAlreadyUsed(Connection conn, String email) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE email = ?")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
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
