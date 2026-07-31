package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Result;
import util.DBConnection;

/**
 * MODEL COMPONENT - Data Access Object
 *
 * All database access for submitted race results, including the approval
 * queue, a participant's own results, the leaderboard and the certificate.
 */
public class ResultDAO {

    /** The result already stored for a registration, or null when there is none. */
    public Result findByRegistration(int registrationId) throws SQLException {
        String sql = "SELECT result_id, registration_id, distance_achieved, duration, "
                   + "proof_image, submission_date, approval_status "
                   + "FROM results WHERE registration_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Result result = new Result();
                result.setResultId(rs.getInt("result_id"));
                result.setRegistrationId(rs.getInt("registration_id"));
                result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                result.setDuration(rs.getString("duration"));
                result.setProofImage(rs.getString("proof_image"));
                result.setSubmissionDate(rs.getTimestamp("submission_date"));
                result.setApprovalStatus(rs.getString("approval_status"));
                return result;
            }
        }
    }

    /** Stores a newly submitted result, awaiting approval. */
    public void insert(int registrationId, double distance, String duration, String proofImage)
            throws SQLException {

        String sql = "INSERT INTO results (registration_id, distance_achieved, duration, "
                   + "proof_image, approval_status) VALUES (?, ?, ?, ?, 'Pending')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, registrationId);
            ps.setDouble(2, distance);
            ps.setString(3, duration);
            ps.setString(4, proofImage);
            ps.executeUpdate();
        }
    }

    /**
     * Replaces a rejected result with a corrected one and returns it to the
     * review queue, rather than creating a second row for the same
     * registration.
     */
    public void replaceRejected(int resultId, double distance, String duration, String proofImage)
            throws SQLException {

        String sql = "UPDATE results SET distance_achieved = ?, duration = ?, proof_image = ?, "
                   + "approval_status = 'Pending', submission_date = CURRENT_TIMESTAMP "
                   + "WHERE result_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDouble(1, distance);
            ps.setString(2, duration);
            ps.setString(3, proofImage);
            ps.setInt(4, resultId);
            ps.executeUpdate();
        }
    }

    /** Every result this participant has submitted, newest first. */
    public List<Result> findByUser(int userId) throws SQLException {
        String sql = "SELECT r.result_id, r.registration_id, r.distance_achieved, r.duration, "
                   + "r.proof_image, r.approval_status, e.event_name "
                   + "FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "WHERE reg.user_id = ? "
                   + "ORDER BY r.result_id DESC";

        List<Result> results = new ArrayList<Result>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Result result = new Result();
                    result.setResultId(rs.getInt("result_id"));
                    result.setRegistrationId(rs.getInt("registration_id"));
                    result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                    result.setDuration(rs.getString("duration"));
                    result.setProofImage(rs.getString("proof_image"));
                    result.setApprovalStatus(rs.getString("approval_status"));
                    result.setEventName(rs.getString("event_name"));
                    results.add(result);
                }
            }
        }

        return results;
    }

    /**
     * Every submission for the administrator's approval screen, with those
     * still Pending sorted to the top so the outstanding work is first.
     */
    public List<Result> findAllForApproval() throws SQLException {
        String sql = "SELECT r.result_id, r.distance_achieved, r.duration, r.proof_image, "
                   + "r.approval_status, u.full_name, e.event_name "
                   + "FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "JOIN users u ON reg.user_id = u.user_id "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "ORDER BY FIELD(r.approval_status, 'Pending', 'Approved', 'Rejected'), "
                   + "r.result_id";

        List<Result> results = new ArrayList<Result>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Result result = new Result();
                result.setResultId(rs.getInt("result_id"));
                result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                result.setDuration(rs.getString("duration"));
                result.setProofImage(rs.getString("proof_image"));
                result.setApprovalStatus(rs.getString("approval_status"));
                result.setParticipantName(rs.getString("full_name"));
                result.setEventName(rs.getString("event_name"));
                results.add(result);
            }
        }

        return results;
    }

    /**
     * Every submission with the extra detail the CSV report includes.
     */
    public List<Result> findAllForExport() throws SQLException {
        String sql = "SELECT r.result_id, r.distance_achieved, r.duration, r.approval_status, "
                   + "r.submission_date, u.full_name, u.email, e.event_name, e.event_date "
                   + "FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "JOIN users u ON reg.user_id = u.user_id "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "ORDER BY e.event_name, r.result_id";

        List<Result> results = new ArrayList<Result>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Result result = new Result();
                result.setResultId(rs.getInt("result_id"));
                result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                result.setDuration(rs.getString("duration"));
                result.setApprovalStatus(rs.getString("approval_status"));
                result.setSubmissionDate(rs.getTimestamp("submission_date"));
                result.setParticipantName(rs.getString("full_name"));
                result.setParticipantEmail(rs.getString("email"));
                result.setEventName(rs.getString("event_name"));
                result.setEventDate(rs.getString("event_date"));
                results.add(result);
            }
        }

        return results;
    }

    /**
     * Records an administrator's decision on a submission.
     *
     * @param status must be Approved or Rejected; the controller checks this
     *               before calling
     */
    public boolean updateStatus(int resultId, String status) throws SQLException {
        String sql = "UPDATE results SET approval_status = ? WHERE result_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, resultId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Approved results for the public leaderboard, grouped by event and
     * ordered fastest first within each one.
     *
     * TIME_TO_SEC turns the stored hh:mm:ss text into a number, so that
     * 9:30:00 sorts before 10:00:00 rather than after it.
     */
    public List<Result> findApprovedForLeaderboard() throws SQLException {
        String sql = "SELECT e.event_name, u.full_name, r.distance_achieved, r.duration, "
                   + "TIME_TO_SEC(r.duration) AS seconds "
                   + "FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "JOIN users u ON reg.user_id = u.user_id "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "WHERE r.approval_status = 'Approved' "
                   + "ORDER BY e.event_date, e.event_name, seconds";

        List<Result> results = new ArrayList<Result>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Result result = new Result();
                result.setEventName(rs.getString("event_name"));
                result.setParticipantName(rs.getString("full_name"));
                result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                result.setDuration(rs.getString("duration"));
                result.setDurationSeconds(rs.getLong("seconds"));
                results.add(result);
            }
        }

        return results;
    }

    /**
     * Everything the certificate page needs for one result, including the
     * participant it belongs to so that ownership can be checked.
     */
    public Result findForCertificate(int resultId) throws SQLException {
        String sql = "SELECT r.result_id, r.distance_achieved, r.duration, r.approval_status, "
                   + "r.submission_date, TIME_TO_SEC(r.duration) AS seconds, "
                   + "u.full_name, u.user_id, e.event_id, e.event_name, e.event_date "
                   + "FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "JOIN users u ON reg.user_id = u.user_id "
                   + "JOIN events e ON reg.event_id = e.event_id "
                   + "WHERE r.result_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, resultId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Result result = new Result();
                result.setResultId(rs.getInt("result_id"));
                result.setDistanceAchieved(rs.getDouble("distance_achieved"));
                result.setDuration(rs.getString("duration"));
                result.setApprovalStatus(rs.getString("approval_status"));
                result.setSubmissionDate(rs.getTimestamp("submission_date"));
                result.setDurationSeconds(rs.getLong("seconds"));
                result.setParticipantName(rs.getString("full_name"));
                result.setOwnerUserId(rs.getInt("user_id"));
                result.setEventId(rs.getInt("event_id"));
                result.setEventName(rs.getString("event_name"));
                result.setEventDate(rs.getString("event_date"));
                return result;
            }
        }
    }

    /**
     * Finishing position within an event: how many approved runners were
     * faster, plus one.
     */
    public int findPositionInEvent(int eventId, long seconds) throws SQLException {
        String sql = "SELECT COUNT(*) + 1 AS position FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "WHERE reg.event_id = ? AND r.approval_status = 'Approved' "
                   + "AND TIME_TO_SEC(r.duration) < ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            ps.setLong(2, seconds);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("position") : 0;
            }
        }
    }

    /**
     * True when this proof image belongs to a result submitted by this
     * participant. Used before an image is served.
     */
    public boolean proofBelongsToUser(String fileName, int userId) throws SQLException {
        String sql = "SELECT 1 FROM results r "
                   + "JOIN registrations reg ON r.registration_id = reg.registration_id "
                   + "WHERE r.proof_image = ? AND reg.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fileName);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
