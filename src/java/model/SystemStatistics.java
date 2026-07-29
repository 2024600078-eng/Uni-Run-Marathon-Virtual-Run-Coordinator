package model;

/**
 * MODEL COMPONENT
 *
 * The five figures shown across the top of the administrator dashboard.
 * They are gathered by one query in a DAO rather than five separate ones.
 */
public class SystemStatistics {

    private int totalEvents;
    private int totalParticipants;
    private int totalRegistrations;
    private int pendingResults;
    private int approvedResults;

    public SystemStatistics() {
    }

    /** True when there is work waiting on the approval screen. */
    public boolean hasPendingWork() {
        return pendingResults > 0;
    }

    public int getTotalEvents() {
        return totalEvents;
    }

    public void setTotalEvents(int totalEvents) {
        this.totalEvents = totalEvents;
    }

    public int getTotalParticipants() {
        return totalParticipants;
    }

    public void setTotalParticipants(int totalParticipants) {
        this.totalParticipants = totalParticipants;
    }

    public int getTotalRegistrations() {
        return totalRegistrations;
    }

    public void setTotalRegistrations(int totalRegistrations) {
        this.totalRegistrations = totalRegistrations;
    }

    public int getPendingResults() {
        return pendingResults;
    }

    public void setPendingResults(int pendingResults) {
        this.pendingResults = pendingResults;
    }

    public int getApprovedResults() {
        return approvedResults;
    }

    public void setApprovedResults(int approvedResults) {
        this.approvedResults = approvedResults;
    }
}
