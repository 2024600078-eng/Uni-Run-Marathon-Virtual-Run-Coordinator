package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    
    private static final String URL = "jdbc:mysql://localhost:3306/unirun_db";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    public static Connection getConnection() {
        Connection conn = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
        
        return conn;
    }
}