package controller;

import dao.ResultDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.ParticipantSummary;
import model.Result;

/**
 * CONTROLLER COMPONENT
 *
 * Downloads administrator reports as CSV files that open directly in Excel.
 *
 * The controller asks the Model for a list of objects and turns them into
 * rows. It contains no SQL, and the report chosen is decided here rather than
 * taken from the request, so no caller can ask for arbitrary data.
 */
@WebServlet(name = "ExportServlet", urlPatterns = {"/export"})
public class ExportServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ResultDAO resultDAO = new ResultDAO();

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

        if (!"participants".equals(type) && !"results".equals(type)) {
            response.sendRedirect("adminDashboard.jsp?error=export");
            return;
        }

        String fileName = "unirun-" + type + "-"
                + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + ".csv";

        response.setContentType("text/csv;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (PrintWriter out = response.getWriter()) {

            // A byte order mark, so that Excel opens the file as UTF-8 and
            // shows accented names correctly.
            out.write('﻿');

            if ("participants".equals(type)) {
                writeParticipants(out);
            } else {
                writeResults(out);
            }

        } catch (Exception e) {
            log("Could not export " + type, e);
            if (!response.isCommitted()) {
                response.sendRedirect("adminDashboard.jsp?error=export");
            }
        }
    }

    private void writeParticipants(PrintWriter out) throws Exception {
        writeRow(out, "ID", "Full Name", "Email", "Events Joined",
                 "Results Submitted", "Approved", "Joined On");

        List<ParticipantSummary> participants = userDAO.findAllParticipants();

        for (ParticipantSummary p : participants) {
            writeRow(out,
                    String.valueOf(p.getUserId()),
                    p.getFullName(),
                    p.getEmail(),
                    String.valueOf(p.getEventsJoined()),
                    String.valueOf(p.getResultsSubmitted()),
                    String.valueOf(p.getResultsApproved()),
                    String.valueOf(p.getCreatedAt()));
        }
    }

    private void writeResults(PrintWriter out) throws Exception {
        writeRow(out, "Result ID", "Participant", "Email", "Event", "Event Date",
                 "Distance (km)", "Duration", "Status", "Submitted On");

        List<Result> results = resultDAO.findAllForExport();

        for (Result r : results) {
            writeRow(out,
                    String.valueOf(r.getResultId()),
                    r.getParticipantName(),
                    r.getParticipantEmail(),
                    r.getEventName(),
                    r.getEventDate(),
                    String.valueOf(r.getDistanceAchieved()),
                    r.getDuration(),
                    r.getApprovalStatus(),
                    String.valueOf(r.getSubmissionDate()));
        }
    }

    /** Writes one CSV line, quoting every field. */
    private void writeRow(PrintWriter out, String... values) {
        for (int i = 0; i < values.length; i++) {
            if (i > 0) {
                out.print(',');
            }
            out.print(quote(values[i]));
        }
        out.print("\r\n");
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
        String safe = value == null ? "" : value;

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
