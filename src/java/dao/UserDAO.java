package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ParticipantSummary;
import model.User;
import util.DBConnection;

/**
 * MODEL COMPONENT - Data Access Object
 *
 * All database access for user accounts lives here. Nothing outside this
 * class writes SQL against the users table, so a change to how accounts are
 * stored affects this file only.
 *
 * Every statement is a PreparedStatement with bound parameters, which is what
 * prevents SQL injection.
 */
public class UserDAO {

    /**
     * Finds the account with this email address, or null when there is none.
     * Used by the login controller, which then compares password hashes.
     */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT user_id, full_name, email, password, role, created_at "
                   + "FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapUser(rs) : null;
            }
        }
    }

    /** True when an account already uses this email address. */
    public boolean emailExists(String email) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE email = ?")) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Creates a participant account.
     *
     * @param passwordHash the SHA-256 hash. This class never receives or
     *                     stores a plain text password.
     */
    public void insertParticipant(String fullName, String email, String passwordHash)
            throws SQLException {

        String sql = "INSERT INTO users (full_name, email, password, role) "
                   + "VALUES (?, ?, ?, 'participant')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            ps.executeUpdate();
        }
    }

    /**
     * Every participant with counts of the events they joined, the results
     * they sent and how many were approved. Shown on the administrator's
     * participant management screen.
     */
    public List<ParticipantSummary> findAllParticipants() throws SQLException {
        String sql =
              "SELECT u.user_id, u.full_name, u.email, u.created_at, "
            + "(SELECT COUNT(*) FROM registrations r WHERE r.user_id = u.user_id) AS events_joined, "
            + "(SELECT COUNT(*) FROM results res "
            + " JOIN registrations r2 ON res.registration_id = r2.registration_id "
            + " WHERE r2.user_id = u.user_id) AS results_submitted, "
            + "(SELECT COUNT(*) FROM results res "
            + " JOIN registrations r2 ON res.registration_id = r2.registration_id "
            + " WHERE r2.user_id = u.user_id AND res.approval_status = 'Approved') AS results_approved "
            + "FROM users u WHERE u.role = 'participant' ORDER BY u.full_name";

        List<ParticipantSummary> participants = new ArrayList<ParticipantSummary>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ParticipantSummary summary = new ParticipantSummary();
                summary.setUserId(rs.getInt("user_id"));
                summary.setFullName(rs.getString("full_name"));
                summary.setEmail(rs.getString("email"));
                summary.setCreatedAt(rs.getTimestamp("created_at"));
                summary.setEventsJoined(rs.getInt("events_joined"));
                summary.setResultsSubmitted(rs.getInt("results_submitted"));
                summary.setResultsApproved(rs.getInt("results_approved"));
                participants.add(summary);
            }
        }

        return participants;
    }

    /**
     * Removes a participant account and, through the cascading foreign keys,
     * their registrations and results.
     *
     * The role condition means an administrator row can never be deleted by
     * this method, even if an administrator id is supplied.
     *
     * @return true when a row was actually removed
     */
    public boolean deleteParticipant(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ? AND role = 'participant'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Turns the current row of a result set into a User object. */
    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
