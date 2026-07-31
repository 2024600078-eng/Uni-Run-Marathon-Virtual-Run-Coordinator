package model;

import java.sql.Timestamp;

/**
 * MODEL COMPONENT
 *
 * Represents one row of the registrations table: the link between a
 * participant and an event they have joined.
 *
 * A participant may join many events and an event may be joined by many
 * participants, so this entity resolves that many to many relationship and
 * also carries the facts belonging to the pairing itself.
 *
 * The event name and date are filled in when the registration is read
 * together with its event, so a page can display a registration without
 * having to look the event up separately.
 */
public class Registration {

    private int registrationId;
    private int userId;
    private int eventId;
    private Timestamp registrationDate;
    private String status;

    // Filled in when the registration is read joined to its event.
    private String eventName;
    private String eventDate;
    private double eventDistance;

    /**
     * Approval status of the result already submitted for this registration,
     * or null when none has been submitted. Used by the submission page to
     * decide which events may still be chosen.
     */
    private String resultStatus;

    public Registration() {
    }

    /**
     * True when a result was already submitted and rejected, so the
     * participant is correcting it rather than submitting for the first time.
     */
    public boolean isResubmission() {
        return Result.REJECTED.equalsIgnoreCase(resultStatus);
    }

    public String getResultStatus() {
        return resultStatus;
    }

    public void setResultStatus(String resultStatus) {
        this.resultStatus = resultStatus;
    }

    public int getRegistrationId() {
        return registrationId;
    }

    public void setRegistrationId(int registrationId) {
        this.registrationId = registrationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public Timestamp getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(Timestamp registrationDate) {
        this.registrationDate = registrationDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getEventDate() {
        return eventDate;
    }

    public void setEventDate(String eventDate) {
        this.eventDate = eventDate;
    }

    public double getEventDistance() {
        return eventDistance;
    }

    public void setEventDistance(double eventDistance) {
        this.eventDistance = eventDistance;
    }
}
