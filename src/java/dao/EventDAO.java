package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Event;
import model.EventRegistrationCount;
import util.DBConnection;

/**
 * MODEL COMPONENT - Data Access Object
 *
 * All database access for events. This class provides the four record
 * operations the assignment asks about: retrieve, insert, update and delete.
 */
public class EventDAO {

    private static final String COLUMNS =
            "event_id, event_name, description, event_date, distance, fee";

    /** Every event, soonest first. Used by the events page and the admin list. */
    public List<Event> findAll() throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM events ORDER BY event_date";

        List<Event> events = new ArrayList<Event>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                events.add(mapEvent(rs));
            }
        }

        return events;
    }

    /** One event, or null when the id does not exist. */
    public Event findById(int eventId) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM events WHERE event_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapEvent(rs) : null;
            }
        }
    }

    /** True when an event with this id exists. */
    public boolean exists(int eventId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps =
                     conn.prepareStatement("SELECT 1 FROM events WHERE event_id = ?")) {

            ps.setInt(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Stores a new event. */
    public void insert(Event event) throws SQLException {
        String sql = "INSERT INTO events (event_name, description, event_date, distance, fee) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, event.getEventName());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getEventDate());
            ps.setDouble(4, event.getDistance());
            ps.setDouble(5, event.getFee());
            ps.executeUpdate();
        }
    }

    /**
     * Updates an existing event.
     *
     * @return true when a row was changed, false when the id no longer exists
     */
    public boolean update(Event event) throws SQLException {
        String sql = "UPDATE events SET event_name = ?, description = ?, event_date = ?, "
                   + "distance = ?, fee = ? WHERE event_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, event.getEventName());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getEventDate());
            ps.setDouble(4, event.getDistance());
            ps.setDouble(5, event.getFee());
            ps.setInt(6, event.getEventId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Removes an event and, through the cascading foreign keys, its
     * registrations and their results.
     */
    public boolean delete(int eventId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps =
                     conn.prepareStatement("DELETE FROM events WHERE event_id = ?")) {

            ps.setInt(1, eventId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * How many participants joined each event, busiest first. Drives the
     * chart on the administrator dashboard.
     *
     * A LEFT JOIN is used so that an event with no registrations still
     * appears, with a count of zero.
     */
    public List<EventRegistrationCount> findRegistrationCounts() throws SQLException {
        String sql = "SELECT e.event_name, COUNT(r.registration_id) AS total "
                   + "FROM events e "
                   + "LEFT JOIN registrations r ON e.event_id = r.event_id "
                   + "GROUP BY e.event_id, e.event_name "
                   + "ORDER BY total DESC, e.event_name";

        List<EventRegistrationCount> counts = new ArrayList<EventRegistrationCount>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                counts.add(new EventRegistrationCount(
                        rs.getString("event_name"), rs.getInt("total")));
            }
        }

        return counts;
    }

    private Event mapEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setEventId(rs.getInt("event_id"));
        event.setEventName(rs.getString("event_name"));
        event.setDescription(rs.getString("description"));
        event.setEventDate(rs.getString("event_date"));
        event.setDistance(rs.getDouble("distance"));
        event.setFee(rs.getDouble("fee"));
        return event;
    }
}
