/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/RegisterEventServlet")
public class RegisterEventServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        // Ambil user_id dari session login kawan kau (contoh nama session: "userId")
        Integer userId = (Integer) session.getAttribute("userId"); 
        
        // Hardcode dulu ID sementara kalau sistem login kawan kau belum siap sepenuhnya
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int eventId = Integer.parseInt(request.getParameter("eventId"));

        try {
            Connection conn = DBConnection.getConnection();
            String query = "INSERT INTO registrations (user_id, event_id, status) VALUES (?, ?, 'Registered')";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            
            int result = ps.executeUpdate();
            if(result > 0) {
                // Berjaya daftar, hantar ke dashboard
                response.sendRedirect("dashboard.jsp?status=success");
            } else {
                response.sendRedirect("events.jsp?status=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("events.jsp?error=" + e.getMessage());
        }
    }
}