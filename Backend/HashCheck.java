import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class HashCheck {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hashFromDb = "$2a$10$xC2TmMuOa0XOZ3aUwiQxhOQNXjgHwddLFj1gJ/sSgVqM/cR/0eIhq"; // guessing the end from the screenshot? No, the screenshot is cut off: $2a$10$xC2TmMuOa0XOZ3aUwiQxhOQNXjgHwddLF... I can't guess.

        String password = "Pranov@30";
        System.out.println("Checking...");
    }
}
