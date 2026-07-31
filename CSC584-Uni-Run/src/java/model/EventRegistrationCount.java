package model;

/**
 * MODEL COMPONENT
 *
 * One bar of the "registrations per event" chart on the admin dashboard:
 * an event name and how many participants have joined it.
 */
public class EventRegistrationCount {

    private String eventName;
    private int total;

    public EventRegistrationCount() {
    }

    public EventRegistrationCount(String eventName, int total) {
        this.eventName = eventName;
        this.total = total;
    }

    /**
     * Width of this bar as a percentage of the busiest event, so the page can
     * draw the chart without doing the arithmetic itself.
     */
    public int percentageOf(int highest) {
        if (highest <= 0) {
            return 0;
        }
        return (int) Math.round(total * 100.0 / highest);
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }
}
