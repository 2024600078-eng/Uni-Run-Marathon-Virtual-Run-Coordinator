package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Hashes and verifies user passwords.
 *
 * Passwords are never stored in plain text. On registration the password is
 * hashed with SHA-256 and only the hexadecimal digest is written to the
 * database. On login the supplied password is hashed the same way and the two
 * digests are compared.
 */
public final class PasswordUtil {

    private PasswordUtil() {
    }

    /**
     * Returns the SHA-256 digest of the given password as a 64 character
     * lowercase hexadecimal string.
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null) {
            throw new IllegalArgumentException("Password must not be null");
        }

        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));

            StringBuilder hex = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                hex.append(Character.forDigit((b >> 4) & 0xF, 16));
                hex.append(Character.forDigit(b & 0xF, 16));
            }
            return hex.toString();

        } catch (NoSuchAlgorithmException e) {
            // SHA-256 is required to be present in every Java platform.
            throw new IllegalStateException("SHA-256 algorithm is not available", e);
        }
    }

    /**
     * Checks a plain text password against the hash stored in the database.
     */
    public static boolean matches(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null) {
            return false;
        }
        return constantTimeEquals(hash(plainPassword), storedHash);
    }

    /**
     * Compares two strings without returning early, so that the time taken does
     * not reveal how many characters matched.
     */
    private static boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }

        int difference = 0;
        for (int i = 0; i < a.length(); i++) {
            difference |= a.charAt(i) ^ b.charAt(i);
        }
        return difference == 0;
    }
}
