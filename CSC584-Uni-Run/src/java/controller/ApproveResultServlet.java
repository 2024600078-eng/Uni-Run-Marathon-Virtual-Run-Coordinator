package controller;

import dao.ResultDAO;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Result;

/**
 * CONTROLLER COMPONENT
 *
 * Lets an administrator approve or reject a result submitted by a participant.
 */
@WebServlet(name = "ApproveResultServlet", urlPatterns = {"/ApproveResultServlet"})
public class ApproveResultServlet extends HttpServlet {

    /** Only these two values may ever be written to results.approval_status. */
    private static final List<String> ALLOWED_STATUS =
            Arrays.asList(Result.APPROVED, Result.REJECTED);

    private final ResultDAO resultDAO = new ResultDAO();

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

        int resultId;
        try {
            resultId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect("approveResults.jsp?error=invalid");
            return;
        }

        String status = request.getParameter("status");
        if (!ALLOWED_STATUS.contains(status)) {
            response.sendRedirect("approveResults.jsp?error=invalid");
            return;
        }

        try {
            if (resultDAO.updateStatus(resultId, status)) {
                response.sendRedirect("approveResults.jsp?status=" + status.toLowerCase());
            } else {
                response.sendRedirect("approveResults.jsp?error=notfound");
            }

        } catch (Exception e) {
            log("Could not update approval status for result " + resultId, e);
            response.sendRedirect("approveResults.jsp?error=db");
        }
    }

    @Override
    public String getServletInfo() {
        return "Approves or rejects participant race result submissions";
    }
}
