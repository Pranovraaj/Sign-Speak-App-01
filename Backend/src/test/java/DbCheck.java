import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import java.security.MessageDigest;

public class DbCheck {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:postgresql://sign-language-2026-signspeak.h.aivencloud.com:24521/defaultdb?sslmode=require";
        String user = "avnadmin";
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        
        if (password == null) {
            System.out.println("No password found in env");
            return;
        }

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            String sql = "SELECT password_hash FROM users WHERE email = 'pranovraaj@gmail.com'";
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String hash = rs.getString("password_hash");
                    System.out.println("Full Hash in DB: " + hash);
                    
                    BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
                    boolean matchesPlain = encoder.matches("Pranov@30", hash);
                    System.out.println("Matches plaintext 'Pranov@30': " + matchesPlain);
                    
                    MessageDigest digest = MessageDigest.getInstance("SHA-256");
                    byte[] encodedhash = digest.digest("Pranov@30".getBytes(java.nio.charset.StandardCharsets.UTF_8));
                    StringBuilder hexString = new StringBuilder(2 * encodedhash.length);
                    for (int i = 0; i < encodedhash.length; i++) {
                        String hex = Integer.toHexString(0xff & encodedhash[i]);
                        if(hex.length() == 1) {
                            hexString.append('0');
                        }
                        hexString.append(hex);
                    }
                    String sha256 = hexString.toString();
                    System.out.println("SHA-256 string: " + sha256);
                    boolean matchesSha = encoder.matches(sha256, hash);
                    System.out.println("Matches SHA-256 'Pranov@30': " + matchesSha);
                } else {
                    System.out.println("User not found!");
                }
            }
        }
    }
}
