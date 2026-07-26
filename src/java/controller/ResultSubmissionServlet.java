/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import util.DBConnection;

/**
 *
 * @author mnaimzahidi
 */
@WebServlet(name = "ResultSubmissionServlet", urlPatterns = {"/ResultSubmissionServlet"})
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class ResultSubmissionServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Ambil data dari form
        int registrationId = Integer.parseInt(request.getParameter("registrationId"));
        double distanceAchieved = Double.parseDouble(request.getParameter("distanceAchieved"));
        String duration = request.getParameter("duration");

        // Handle upload gambar
        Part filePart = request.getPart("proofImage");
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            String originalFileName = getFileName(filePart);
            String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
            fileName = UUID.randomUUID().toString() + extension;

            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            filePart.write(uploadPath + File.separator + fileName);
        }

        // Simpan ke database
        String sql = "INSERT INTO results (registration_id, distance_achieved, duration, proof_image, approval_status) "
                    + "VALUES (?, ?, ?, ?, 'Pending')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, registrationId);
            ps.setDouble(2, distanceAchieved);
            ps.setString(3, duration);
            ps.setString(4, fileName);

            ps.executeUpdate();

            response.sendRedirect("viewResultStatus.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Gagal submit result: " + e.getMessage());
            request.getRequestDispatcher("submitResult.jsp").forward(request, response);
        }
    }

    /**
     * Helper method untuk cari nama fail yang diupload oleh user.
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "file";
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
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Handles submission of race results by participants";
    }
    // </editor-fold>

}