/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import util.DBConnection;

/**
 *
 * @author User
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet RegisterServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet RegisterServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
    response.setContentType("text/html;charset=UTF-8");

    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;

    try {

        conn = DBConnection.getConnection();
        
        String sql = "INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)";

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, fullName);
        ps.setString(2, email);
        ps.setString(3, password);
        int result = ps.executeUpdate();
        
        if (result > 0) {

    response.setContentType("text/html;charset=UTF-8");

    response.getWriter().println("<!DOCTYPE html>");
    response.getWriter().println("<html>");
    response.getWriter().println("<head>");

    response.getWriter().println("<title>Registration Successful</title>");

    // Redirect to login page after 3 seconds
    response.getWriter().println("<meta http-equiv='refresh' content='3;url=login.jsp'>");

    response.getWriter().println("<style>");
    response.getWriter().println("body{font-family:Arial;background:#f4f7fb;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}");
    response.getWriter().println(".card{background:white;padding:40px;border-radius:10px;box-shadow:0 5px 15px rgba(0,0,0,.15);text-align:center;width:420px;}");
    response.getWriter().println("h2{color:#28a745;}");
    response.getWriter().println("p{color:#555;font-size:16px;}");
    response.getWriter().println("a{display:inline-block;margin-top:20px;padding:12px 24px;background:#0d47a1;color:white;text-decoration:none;border-radius:6px;}");
    response.getWriter().println("</style>");

    response.getWriter().println("</head>");
    response.getWriter().println("<body>");

    response.getWriter().println("<div class='card'>");
    response.getWriter().println("<h2>✅ Registration Successful!</h2>");
    response.getWriter().println("<p>Your account has been created successfully.</p>");
    response.getWriter().println("<p>Redirecting to the login page in <b>3 seconds...</b></p>");
    response.getWriter().println("<a href='login.jsp'>Login Now</a>");
    response.getWriter().println("</div>");

    response.getWriter().println("</body>");
    response.getWriter().println("</html>");

    } else {
        response.getWriter().println("<h2>Registration Failed!</h2>");
        }

    } catch (Exception e) {
        
        response.getWriter().println("Error: " + e.getMessage());
        e.printStackTrace();

    }
}

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
