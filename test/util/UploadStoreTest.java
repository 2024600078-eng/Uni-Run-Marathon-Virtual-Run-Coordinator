package util;

import java.util.UUID;
import org.junit.Test;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * Tests for the check that decides which upload file names are acceptable.
 *
 * This is the guard that stops a crafted name from reaching a file outside the
 * upload folder, so the rejection cases matter as much as the accepted ones.
 */
public class UploadStoreTest {

    private static String generatedName(String extension) {
        return UUID.randomUUID().toString() + "." + extension;
    }

    @Test
    public void namesThisSystemGeneratesAreAccepted() {
        assertTrue(UploadStore.isValidStoredName(generatedName("jpg")));
        assertTrue(UploadStore.isValidStoredName(generatedName("jpeg")));
        assertTrue(UploadStore.isValidStoredName(generatedName("png")));
    }

    @Test
    public void nullAndEmptyAreRejected() {
        assertFalse(UploadStore.isValidStoredName(null));
        assertFalse(UploadStore.isValidStoredName(""));
    }

    @Test
    public void anExecutablePageExtensionIsRejected() {
        assertFalse(UploadStore.isValidStoredName(generatedName("jsp")));
        assertFalse(UploadStore.isValidStoredName(generatedName("exe")));
        assertFalse(UploadStore.isValidStoredName(generatedName("php")));
    }

    @Test
    public void pathTraversalIsRejected() {
        assertFalse(UploadStore.isValidStoredName("../../secret.jpg"));
        assertFalse(UploadStore.isValidStoredName("..\\..\\secret.jpg"));
        assertFalse(UploadStore.isValidStoredName("/etc/passwd"));
        assertFalse(UploadStore.isValidStoredName("C:\\Windows\\win.ini"));
    }

    @Test
    public void aSeparatorInsideAnOtherwiseValidNameIsRejected() {
        String name = UUID.randomUUID().toString();
        assertFalse(UploadStore.isValidStoredName("sub/" + name + ".jpg"));
        assertFalse(UploadStore.isValidStoredName(name + "/x.jpg"));
    }

    @Test
    public void anArbitraryNameIsRejectedEvenWithAnAllowedExtension() {
        assertFalse(UploadStore.isValidStoredName("photo.jpg"));
        assertFalse(UploadStore.isValidStoredName("my run.png"));
    }

    @Test
    public void aNameWithNoExtensionIsRejected() {
        assertFalse(UploadStore.isValidStoredName(UUID.randomUUID().toString()));
    }

    @Test
    public void aDoubleExtensionIsRejected() {
        assertFalse(UploadStore.isValidStoredName(generatedName("jpg") + ".jsp"));
    }

    @Test
    public void resolvingAnInvalidNameThrows() {
        try {
            UploadStore.fileFor("../../escape.jpg");
            fail("Expected IllegalArgumentException for a name outside the folder");
        } catch (IllegalArgumentException expected) {
            // This is the required behaviour.
        }
    }

    @Test
    public void deletingAnInvalidNameIsIgnoredRatherThanThrowing() {
        // Called during resubmission, so it must never break the request.
        UploadStore.deleteQuietly(null);
        UploadStore.deleteQuietly("../../etc/passwd");
    }
}
