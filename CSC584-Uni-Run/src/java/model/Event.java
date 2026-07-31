package model;

/**
 * MODEL COMPONENT
 *
 * Represents one row of the events table: a marathon or virtual run that
 * participants may join.
 */
public class Event {

    private int eventId;
    private String eventName;
    private String description;
    private String eventDate;
    private double distance;
    private double fee;

    public Event() {
    }

    public Event(String eventName, String description, String eventDate,
                 double distance, double fee) {
        this.eventName = eventName;
        this.description = description;
        this.eventDate = eventDate;
        this.distance = distance;
        this.fee = fee;
    }

    /** True when there is no entry fee, so the page can show "Free". */
    public boolean isFree() {
        return fee <= 0;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    /** Held as text because it is only ever displayed or placed in a date field. */
    public String getEventDate() {
        return eventDate;
    }

    public void setEventDate(String eventDate) {
        this.eventDate = eventDate;
    }

    public double getDistance() {
        return distance;
    }

    public void setDistance(double distance) {
        this.distance = distance;
    }

    public double getFee() {
        return fee;
    }

    public void setFee(double fee) {
        this.fee = fee;
    }
}
