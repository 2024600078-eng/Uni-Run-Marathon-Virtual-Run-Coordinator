/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

public class Event {
    private int eventId;
    private String eventName;
    private String description;
    private String eventDate;
    private double distance;
    private double fee;

    // Constructor
    public Event() {}

    // Getters and Setters
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getEventDate() { return eventDate; }
    public void setEventDate(String eventDate) { this.eventDate = eventDate; }
    public double getDistance() { return distance; }
    public void setDistance(double distance) { this.distance = distance; }
    public double getFee() { return fee; }
    public void setFee(double fee) { this.fee = fee; }
}