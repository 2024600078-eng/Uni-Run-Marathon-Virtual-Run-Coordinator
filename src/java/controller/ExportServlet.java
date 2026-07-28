package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

/**
 * Downloads administrator reports as CSV files that open directly in Excel.
 *
 * Two reports are offered: the participant list and the submitted results.
 * The query for each is chosen here rather than taken from the request, so no
 * caller can ask for arbitrary data.
 */
@WebServlet(name = "ExportServlet", urlPatterns = {"/export"})
public class ExportServlet extends HttpServlet {

    private static final String PARTICIPANTS_SQL =
              "SELECT u.user_id AS 'ID', u.full_name AS 'Full Name', u.email AS 'Email', "
            + "(SELECT COUNT(*) FROM registrations r WHERE r.user_id = u.user_id) AS 'Events Joined', "
            + "(SELECT COUNT(*) FROM results res "
            + " JOIN registrations r2 ON res.registration_id = r2.registration_id "
            + " WHERE r2.user_id = u.user_id) AS 'Results Submitted', "
            + "(SELECT COUNT(*) FROM results res "
            + " JOIN registrations r2 ON res.registration_id = r2.registration_id "
            + " WHERE r2.user_id = u.user_id AND res.approval_status = 'Approved') AS 'Approved', "
            + "u.created_at AS 'Joined On' "
            + "FROM users u WHERE u.role = 'participant' ORDER BY u.full_name";

    private static final String RESULTS_SQL =
              "SELECT r.result_id AS 'Result ID', u.full_name AS 'Participant', "
            + "u.email AS 'Email', e.event_name AS 'Event', e.event_date AS 'Event Date', "
            + "r.distance_achieved AS 'Distance (km)', r.duration AS 'Duration', "
            + "r.approval_status AS 'Status', r.submission_date AS 'Submitted On' "
            + "FROM results r "
            + "JOIN registrations reg ON r.registration_id = reg.registration_id "
            + "JOIN users u ON reg.user_id = u.user_id "
            + "JOIN events e ON reg.event_id = e.event_id "
            + "ORDER BY e.event_name, r.result_id";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        String type = request.getParameter("type");

        String sql;
        String baseName;

        if ("results".equals(type)) {
            sql = RESULTS_SQL;
            baseName = "unirun-results";
        } else if ("participants".equals(type)) {
            sql = PARTICIPANTS_SQL;
            baseName = "unirun-participants";
        } else {
            response.sendRedirect("adminDashboard.jsp?error=export");
            return;
        }

        String fileName = baseName + "-"
                + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + ".csv";

        response.setContentType("text/csv;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery();
             PrintWriter out = response.getWriter()) {

            // A byte order mark, so that Excel opens the file as UTF-8 and
            // shows accented names correctly.
            out.write('﻿');

            ResultSetMetaData meta = rs.getMetaData();
            int columns = meta.getColumnCount();

            for (int i = 1; i <= columns; i++) {
                if (i > 1) {
                    out.print(',');
                }
                out.print(quote(meta.getColumnLabel(i)));
            }
            out.print("\r\n");

            while (rs.next()) {
                for (int i = 1; i <= columns; i++) {
                    if (i > 1) {
                        out.print(',');
                    }
                    Object value = rs.getObject(i);
                    out.print(quote(value == null ? "" : String.valueOf(value)));
                }
                out.print("\r\n");
            }

        } catch (Exception e) {
            log("Could not export " + type, e);
            // The response may already be part written, so there is nothing
            // useful left to show the administrator beyond a server error.
            if (!response.isCommitted()) {
                response.sendRedirect("adminDashboard.jsp?error=export");
            }
        }
    }

    /**
     * Wraps a value for CSV: doubles any quote marks and surrounds the whole
     * field, so that commas and line breaks inside the text stay inside it.
     *
     * A leading =, +, - or @ is also neutralised. Spreadsheet programs treat
     * those as the start of a formula, which would let text stored by a user
     * run as a calculation when an administrator opens the file.
     */
    private String quote(String value) {
        String safe = value;

        if (!safe.isEmpty()) {
            char first = safe.charAt(0);
            if (first == '=' || first == '+' || first == '-' || first == '@') {
                safe = "'" + safe;
            }
        }

        return '"' + safe.replace("\"", "\"\"") + '"';
    }

    @Override
    public String getServletInfo() {
        return "Exports administrator reports as CSV";
    }
}
