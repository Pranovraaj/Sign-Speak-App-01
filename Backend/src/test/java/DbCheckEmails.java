import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DbCheckEmails {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:postgresql://sign-language-2026-signspeak.h.aivencloud.com:24521/defaultdb?sslmode=require";
        String user = "avnadmin";
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            String sql = "SELECT id, email, password_hash FROM users";
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                System.out.println("Users in DB:");
                while (rs.next()) {
                    System.out.println("ID: " + rs.getLong("id") + ", Email: '" + rs.getString("email") + "', Hash: " + rs.getString("password_hash"));
                }
            }
        }
    }
}
