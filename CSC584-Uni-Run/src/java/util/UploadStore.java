package util;

import java.io.File;

/**
 * Decides where uploaded proof images are kept.
 *
 * They are deliberately stored outside the deployed application. The server
 * deletes and recreates the application folder on every redeployment, so files
 * written inside it are lost whenever the project is rebuilt. Keeping them
 * beside the server instead means a submitted proof image survives a rebuild.
 *
 * Because the folder is outside the application it is not reachable by URL, so
 * images are served through ProofImageServlet, which checks who is asking.
 */
public final class UploadStore {

    private static final String FOLDER_NAME = "unirun-uploads";

    /** A stored name is always a random UUID plus an approved extension. */
    private static final String STORED_NAME_PATTERN =
            "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\.(jpg|jpeg|png)";

    private UploadStore() {
    }

    /**
     * Returns the upload folder, creating it the first time it is needed.
     *
     * It sits next to the running server instance. If that location cannot be
     * determined the user's home folder is used instead, so the system still
     * works when it is started in an unusual way.
     */
    public static File directory() {
        String base = System.getProperty("catalina.base");

        if (base == null || base.trim().isEmpty()) {
            base = System.getProperty("catalina.home");
        }
        if (base == null || base.trim().isEmpty()) {
            base = System.getProperty("user.home");
        }

        File directory = new File(base, FOLDER_NAME);

        if (!directory.exists()) {
            directory.mkdirs();
        }

        return directory;
    }

    /**
     * Resolves a stored file name to a file inside the upload folder.
     *
     * @throws IllegalArgumentException if the name is not one this class
     *         generated, which stops a crafted name reaching another folder.
     */
    public static File fileFor(String storedName) {
        if (!isValidStoredName(storedName)) {
            throw new IllegalArgumentException("Rejected upload file name");
        }
        return new File(directory(), storedName);
    }

    /**
     * True when the name matches the pattern this application creates. Any name
     * containing a path separator or a different extension fails.
     */
    public static boolean isValidStoredName(String storedName) {
        return storedName != null && storedName.matches(STORED_NAME_PATTERN);
    }

    /**
     * Removes a stored image, ignoring the case where it is already gone.
     * Used when a rejected result is replaced by a new submission.
     */
    public static void deleteQuietly(String storedName) {
        if (!isValidStoredName(storedName)) {
            return;
        }

        try {
            File file = new File(directory(), storedName);
            if (file.exists()) {
                file.delete();
            }
        } catch (RuntimeException e) {
            // Losing an old file is not worth failing the request for.
        }
    }
}
