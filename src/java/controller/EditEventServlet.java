package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;

@WebServlet(name = "EditEventServlet", urlPatterns = {"/EditEventServlet"})
public class EditEventServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int eventId = Integer.parseInt(request.getParameter("eventId"));
        String eventName = request.getParameter("eventName");
        String description = request.getParameter("description");
        String eventDate = request.getParameter("eventDate");
        double distance = Double.parseDouble(request.getParameter("distance"));
        double fee = Double.parseDouble(request.getParameter("fee"));

        try {

            Connection conn = DBConnection.getConnection();

            String sql = "UPDATE events SET event_name=?, description=?, event_date=?, distance=?, fee=? WHERE event_id=?";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, eventName);
            ps.setString(2, description);
            ps.setString(3, eventDate);
            ps.setDouble(4, distance);
            ps.setDouble(5, fee);
            ps.setInt(6, eventId);

            ps.executeUpdate();

            ps.close();
            conn.close();

            response.sendRedirect("manageEvents.jsp");

        } catch (Exception e) {

            response.getWriter().println("<h2>Error Updating Event</h2>");
            response.getWriter().println(e.getMessage());

        }
    }
}