package model;

import java.sql.Timestamp;

/**
 * MODEL COMPONENT
 *
 * A participant together with counts of their activity, as shown on the
 * administrator's participant management screen.
 *
 * This is a reporting view rather than a table of its own: the counts are
 * worked out by the query in UserDAO, so the page receives finished numbers
 * and does not have to count anything itself.
 */
public class ParticipantSummary {

    private int userId;
    private String fullName;
    private String email;
    private Timestamp createdAt;
    private int eventsJoined;
    private int resultsSubmitted;
    private int resultsApproved;

    public ParticipantSummary() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getEventsJoined() {
        return eventsJoined;
    }

    public void setEventsJoined(int eventsJoined) {
        this.eventsJoined = eventsJoined;
    }

    public int getResultsSubmitted() {
        return resultsSubmitted;
    }

    public void setResultsSubmitted(int resultsSubmitted) {
        this.resultsSubmitted = resultsSubmitted;
    }

    public int getResultsApproved() {
        return resultsApproved;
    }

    public void setResultsApproved(int resultsApproved) {
        this.resultsApproved = resultsApproved;
    }
}
