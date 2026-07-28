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
import util.PasswordUtil;

/**
 * Authenticates a user and starts their session.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

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

        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");

        if (email.isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        // The password column holds a SHA-256 hash, so look the account up by
        // email only and compare the hashes in Java.
        String sql = "SELECT user_id, full_name, password, role FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next() || !PasswordUtil.matches(password, rs.getString("password"))) {
                    // Deliberately the same message for an unknown email and a
                    // wrong password, so the page cannot be used to discover
                    // which addresses have accounts.
                    response.sendRedirect("login.jsp?error=invalid");
                    return;
                }

                int userId = rs.getInt("user_id");
                String fullName = rs.getString("full_name");
                String role = rs.getString("role");

                // Drop any session the visitor arrived with before storing the
                // login details, so a pre-set session id cannot be reused.
                HttpSession existing = request.getSession(false);
                if (existing != null) {
                    existing.invalidate();
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("email", email);
                session.setAttribute("fullName", fullName);
                session.setAttribute("role", role);
                session.setMaxInactiveInterval(30 * 60);

                // Send each role to the dashboard that belongs to it.
                if ("admin".equals(role)) {
                    response.sendRedirect("adminDashboard.jsp");
                } else {
                    response.sendRedirect("dashboard.jsp");
                }
            }

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
