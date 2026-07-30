package com.signspeak.backend.controller;

import com.signspeak.backend.dto.UserProfileUpdateRequest;
import com.signspeak.backend.dto.UserStatsUpdateRequest;
import com.signspeak.backend.model.User;
import com.signspeak.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/update-profile")
    public ResponseEntity<?> updateProfile(@RequestBody UserProfileUpdateRequest request) {
        Optional<User> optionalUser = userRepository.findByEmail(request.getEmail());
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            if (request.getUsername() != null && !request.getUsername().isEmpty()) {
                user.setUsername(request.getUsername());
            }
            if (request.getProfilePictureBase64() != null) {
                user.setProfilePictureBase64(request.getProfilePictureBase64());
            }
            if (request.getNewEmail() != null && !request.getNewEmail().isEmpty()) {
                user.setEmail(request.getNewEmail());
            }
            if (request.getNewPassword() != null && !request.getNewPassword().isEmpty()) {
                BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
                user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
            }
            User savedUser = userRepository.save(user);
            return ResponseEntity.ok(savedUser);
        }
        return ResponseEntity.status(404).body(java.util.Collections.singletonMap("error", "User not found"));
    }

    @PostMapping("/update-stats")
    public ResponseEntity<?> updateStats(@RequestBody UserStatsUpdateRequest request) {
        Optional<User> optionalUser = userRepository.findByEmail(request.getEmail());
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            if (request.getScore() != null) {
                user.setScore(request.getScore());
            }
            if (request.getStreak() != null) {
                user.setStreak(request.getStreak());
            }
            User savedUser = userRepository.save(user);
            return ResponseEntity.ok(savedUser);
        }
        return ResponseEntity.status(404).body(java.util.Collections.singletonMap("error", "User not found"));
    }
}
