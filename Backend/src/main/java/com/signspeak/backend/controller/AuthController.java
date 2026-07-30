package com.signspeak.backend.controller;

import com.signspeak.backend.dto.AuthRequest;
import com.signspeak.backend.dto.AuthResponse;
import com.signspeak.backend.model.User;
import com.signspeak.backend.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody AuthRequest request) {
        try {
            User user = authService.register(request);
            return ResponseEntity.ok(new AuthResponse("dummy-jwt-token", "dummy-refresh-token", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(java.util.Collections.singletonMap("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        return authService.login(request)
                .<ResponseEntity<?>>map(user -> ResponseEntity.ok(new AuthResponse("dummy-jwt-token", "dummy-refresh-token", user)))
                .orElse(ResponseEntity.status(401).body(java.util.Collections.singletonMap("error", "Invalid credentials")));
    }
}
