package util;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * Tests for the password hashing used by registration and login.
 */
public class PasswordUtilTest {

    /**
     * The published SHA-256 digest of "admin123". Checking against a value
     * produced outside this project proves the hashing follows the standard
     * rather than merely being self consistent.
     */
    private static final String ADMIN123_SHA256 =
            "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9";

    @Test
    public void hashMatchesTheKnownSha256Value() {
        assertEquals(ADMIN123_SHA256, PasswordUtil.hash("admin123"));
    }

    @Test
    public void hashIsSixtyFourLowercaseHexCharacters() {
        String hash = PasswordUtil.hash("any password");

        assertEquals(64, hash.length());
        assertTrue("Hash should be lowercase hexadecimal: " + hash,
                hash.matches("[0-9a-f]{64}"));
    }

    @Test
    public void sameInputAlwaysGivesTheSameHash() {
        assertEquals(PasswordUtil.hash("Runner2026"), PasswordUtil.hash("Runner2026"));
    }

    @Test
    public void differentInputsGiveDifferentHashes() {
        assertNotEquals(PasswordUtil.hash("Runner2026"), PasswordUtil.hash("Runner2027"));
    }

    @Test
    public void hashingIsCaseSensitive() {
        assertNotEquals(PasswordUtil.hash("secret"), PasswordUtil.hash("Secret"));
    }

    @Test
    public void theHashIsNotTheOriginalPassword() {
        String password = "plaintext123";
        assertNotEquals(password, PasswordUtil.hash(password));
    }

    @Test
    public void matchesAcceptsTheCorrectPassword() {
        String stored = PasswordUtil.hash("correct horse");
        assertTrue(PasswordUtil.matches("correct horse", stored));
    }

    @Test
    public void matchesRejectsTheWrongPassword() {
        String stored = PasswordUtil.hash("correct horse");
        assertFalse(PasswordUtil.matches("wrong horse", stored));
    }

    @Test
    public void matchesRejectsAnAlmostCorrectPassword() {
        String stored = PasswordUtil.hash("Password1");
        assertFalse(PasswordUtil.matches("Password2", stored));
    }

    @Test
    public void matchesRejectsPlainTextStoredByMistake() {
        // Guards against a stored value that was never hashed.
        assertFalse(PasswordUtil.matches("admin123", "admin123"));
    }

    @Test
    public void matchesHandlesNullsWithoutFailing() {
        assertFalse(PasswordUtil.matches(null, ADMIN123_SHA256));
        assertFalse(PasswordUtil.matches("admin123", null));
        assertFalse(PasswordUtil.matches(null, null));
    }

    @Test
    public void hashingNullIsRejected() {
        try {
            PasswordUtil.hash(null);
            fail("Expected IllegalArgumentException when hashing null");
        } catch (IllegalArgumentException expected) {
            // This is the required behaviour.
        }
    }

    @Test
    public void emptyPasswordStillProducesAHash() {
        assertEquals(64, PasswordUtil.hash("").length());
    }
}
