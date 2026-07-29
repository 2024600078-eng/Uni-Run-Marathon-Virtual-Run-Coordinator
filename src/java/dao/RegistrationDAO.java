package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Registration;
import util.DBConnection;

/**
 * MODEL COMPONENT - Data Access Object
 *
 * All database access for registrations, the entity that links a participant
 * to an event.
 */
public class RegistrationDAO {

    /**
     * The events this participant has joined, together with the event details
     * needed to display them. Soonest event first.
     */
    public List<Registration> findByUser(int userId) throws SQLException {
        String sql = "SELECT r.registration_id, r.user_id, r.event_id, r.registration_date, "
                   + "r.status, e.event_name, e.event_date, e.distance "
                   + "FROM registrations r "
                   + "JOIN events e ON r.event_id = e.event_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY e.event_date";

        List<Registration> registrations = new ArrayList<Registration>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration registration = new Registration();
                    registration.setRegistrationId(rs.getInt("registration_id"));
                    registration.setUserId(rs.getInt("user_id"));
                    registration.setEventId(rs.getInt("event_id"));
                    registration.setRegistrationDate(rs.getTimestamp("registration_date"));
                    registration.setStatus(rs.getString("status"));
                    registration.setEventName(rs.getString("event_name"));
                    registration.setEventDate(rs.getString("event_date"));
                    registration.setEventDistance(rs.getDouble("distance"));
                    registrations.add(registration);
                }
            }
        }

        return registrations;
    }

    /**
     * The registrations this participant may still submit a result for:
     * those with no result yet, and those whose result was rejected and may
     * now be corrected.
     */
    public List<Registration> findSubmittableByUser(int userId) throws SQLException {
        String sql = "SELECT reg.registration_id, e.event_name, res.approval_status "
                   + "FROM registrations reg "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "LEFT JOIN results res ON res.registration_id = reg.registration_id "
                   + "WHERE reg.user_id = ? "
                   + "AND (res.result_id IS NULL OR res.approval_status = 'Rejected') "
                   + "ORDER BY e.event_date";

        List<Registration> registrations = new ArrayList<Registration>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration registration = new Registration();
                    registration.setRegistrationId(rs.getInt("registration_id"));
                    registration.setEventName(rs.getString("event_name"));
                    registration.setResultStatus(rs.getString("approval_status"));
                    registrations.add(registration);
                }
            }
        }

        return registrations;
    }

    /** True when this participant has already joined this event. */
    public boolean exists(int userId, int eventId) throws SQLException {
        String sql = "SELECT 1 FROM registrations WHERE user_id = ? AND event_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * True when this registration belongs to this participant.
     *
     * Called before a result is accepted, so that one participant cannot file
     * a result against somebody else's registration.
     */
    public boolean belongsToUser(int registrationId, int userId) throws SQLException {
        String sql = "SELECT 1 FROM registrations WHERE registration_id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, registrationId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Joins a participant to an event. */
    public void insert(int userId, int eventId) throws SQLException {
        String sql = "INSERT INTO registrations (user_id, event_id, status) "
                   + "VALUES (?, ?, 'Registered')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.executeUpdate();
        }
    }
}
