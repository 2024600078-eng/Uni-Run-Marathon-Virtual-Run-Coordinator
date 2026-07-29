package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.ParticipantStatistics;
import model.SystemStatistics;
import util.DBConnection;

/**
 * MODEL COMPONENT - Data Access Object
 *
 * Supplies the summary figures shown on the two dashboards.
 *
 * These counts span several tables, so they belong here rather than inside
 * any single entity's DAO. Each dashboard is served by one query rather than
 * one query per figure.
 */
public class StatisticsDAO {

    /** The five totals across the top of the administrator dashboard. */
    public SystemStatistics findSystemStatistics() throws SQLException {
        String sql =
              "SELECT (SELECT COUNT(*) FROM events) AS total_events, "
            + "(SELECT COUNT(*) FROM users WHERE role = 'participant') AS total_participants, "
            + "(SELECT COUNT(*) FROM registrations) AS total_registrations, "
            + "(SELECT COUNT(*) FROM results WHERE approval_status = 'Pending') AS pending_results, "
            + "(SELECT COUNT(*) FROM results WHERE approval_status = 'Approved') AS approved_results";

        SystemStatistics statistics = new SystemStatistics();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                statistics.setTotalEvents(rs.getInt("total_events"));
                statistics.setTotalParticipants(rs.getInt("total_participants"));
                statistics.setTotalRegistrations(rs.getInt("total_registrations"));
                statistics.setPendingResults(rs.getInt("pending_results"));
                statistics.setApprovedResults(rs.getInt("approved_results"));
            }
        }

        return statistics;
    }

    /** The four totals on one participant's own dashboard. */
    public ParticipantStatistics findParticipantStatistics(int userId) throws SQLException {
        String sql =
              "SELECT "
            + "(SELECT COUNT(*) FROM registrations WHERE user_id = ?) AS events_joined, "
            + "(SELECT COUNT(*) FROM results res JOIN registrations r "
            + "   ON res.registration_id = r.registration_id WHERE r.user_id = ?) AS submitted, "
            + "(SELECT COUNT(*) FROM results res JOIN registrations r "
            + "   ON res.registration_id = r.registration_id "
            + "   WHERE r.user_id = ? AND res.approval_status = 'Approved') AS approved, "
            + "(SELECT COUNT(*) FROM results res JOIN registrations r "
            + "   ON res.registration_id = r.registration_id "
            + "   WHERE r.user_id = ? AND res.approval_status = 'Pending') AS pending";

        ParticipantStatistics statistics = new ParticipantStatistics();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 1; i <= 4; i++) {
                ps.setInt(i, userId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    statistics.setEventsJoined(rs.getInt("events_joined"));
                    statistics.setResultsSubmitted(rs.getInt("submitted"));
                    statistics.setResultsApproved(rs.getInt("approved"));
                    statistics.setResultsPending(rs.getInt("pending"));
                }
            }
        }

        return statistics;
    }
}
