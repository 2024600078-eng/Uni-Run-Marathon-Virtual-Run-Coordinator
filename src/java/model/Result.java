package model;

import java.sql.Timestamp;

/**
 * MODEL COMPONENT
 *
 * Represents one row of the results table: a race result a participant has
 * submitted, together with its approval state.
 *
 * The participant and event names are filled in when the result is read
 * joined to its registration, which is what the approval screen, the result
 * list and the leaderboard all need.
 */
public class Result {

    /** The three values approval_status is allowed to hold. */
    public static final String PENDING  = "Pending";
    public static final String APPROVED = "Approved";
    public static final String REJECTED = "Rejected";

    private int resultId;
    private int registrationId;
    private double distanceAchieved;
    private String duration;
    private String proofImage;
    private Timestamp submissionDate;
    private String approvalStatus;

    // Filled in when the result is read joined to its registration.
    private String participantName;
    private String eventName;
    private String eventDate;
    private long durationSeconds;
    private int eventId;

    /** The participant this result belongs to, used for ownership checks. */
    private int ownerUserId;

    /** Filled in only for the CSV export, which lists contact details. */
    private String participantEmail;

    public String getParticipantEmail() {
        return participantEmail;
    }

    public void setParticipantEmail(String participantEmail) {
        this.participantEmail = participantEmail;
    }

    public Result() {
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public int getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(int ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public boolean isPending() {
        return PENDING.equalsIgnoreCase(approvalStatus);
    }

    public boolean isApproved() {
        return APPROVED.equalsIgnoreCase(approvalStatus);
    }

    public boolean isRejected() {
        return REJECTED.equalsIgnoreCase(approvalStatus);
    }

    /** True when the participant uploaded a proof image with this result. */
    public boolean hasProofImage() {
        return proofImage != null && !proofImage.isEmpty();
    }

    /**
     * Average time per kilometre as m:ss, or an empty string when it cannot
     * be worked out. Used by the leaderboard.
     */
    public String getPace() {
        if (distanceAchieved <= 0 || durationSeconds <= 0) {
            return "";
        }
        long perKm = Math.round(durationSeconds / distanceAchieved);
        return (perKm / 60) + ":" + String.format("%02d", perKm % 60) + " /km";
    }

    public int getResultId() {
        return resultId;
    }

    public void setResultId(int resultId) {
        this.resultId = resultId;
    }

    public int getRegistrationId() {
        return registrationId;
    }

    public void setRegistrationId(int registrationId) {
        this.registrationId = registrationId;
    }

    public double getDistanceAchieved() {
        return distanceAchieved;
    }

    public void setDistanceAchieved(double distanceAchieved) {
        this.distanceAchieved = distanceAchieved;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public String getProofImage() {
        return proofImage;
    }

    public void setProofImage(String proofImage) {
        this.proofImage = proofImage;
    }

    public Timestamp getSubmissionDate() {
        return submissionDate;
    }

    public void setSubmissionDate(Timestamp submissionDate) {
        this.submissionDate = submissionDate;
    }

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public String getParticipantName() {
        return participantName;
    }

    public void setParticipantName(String participantName) {
        this.participantName = participantName;
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

    public long getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(long durationSeconds) {
        this.durationSeconds = durationSeconds;
    }
}
