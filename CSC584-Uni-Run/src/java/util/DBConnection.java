package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Supplies JDBC connections to the unirun_db database.
 *
 * The caller is responsible for closing the connection it receives. Every
 * caller in this project does so with a try-with-resources block.
 */
public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/unirun_db";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    static {
        // The driver only needs to be registered once, when the class is first
        // used, rather than on every single request.
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "MySQL JDBC driver was not found on the classpath: " + e.getMessage());
        }
    }

    private DBConnection() {
    }

    /**
     * Opens a new connection to the database.
     *
     * @throws SQLException if the database cannot be reached, so that callers
     *                      are forced to deal with the failure instead of
     *                      receiving a null connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
