package model;

import java.sql.Timestamp;

/**
 * MODEL COMPONENT
 *
 * Represents one row of the users table: a participant or an administrator.
 *
 * A class in this package holds data only. It has no database code and no
 * page code, so the same object can be created by a DAO, passed through a
 * servlet and displayed by a JSP without any layer needing to know how the
 * others work.
 */
public class User {

    private int userId;
    private String fullName;
    private String email;
    private String password;
    private String role;
    private Timestamp createdAt;

    public User() {
    }

    public User(int userId, String fullName, String email, String role) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
    }

    /** True when this account may reach the administrator pages. */
    public boolean isAdmin() {
        return "admin".equals(role);
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

    /** The stored SHA-256 hash, never a plain text password. */
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
