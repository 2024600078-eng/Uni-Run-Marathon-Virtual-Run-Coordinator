package model;

/**
 * MODEL COMPONENT
 *
 * The four figures shown at the top of a participant's own dashboard,
 * covering only that participant's activity.
 */
public class ParticipantStatistics {

    private int eventsJoined;
    private int resultsSubmitted;
    private int resultsApproved;
    private int resultsPending;

    public ParticipantStatistics() {
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

    public int getResultsPending() {
        return resultsPending;
    }

    public void setResultsPending(int resultsPending) {
        this.resultsPending = resultsPending;
    }
}
