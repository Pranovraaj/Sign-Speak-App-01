package com.signspeak.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    private String preferredVoice;

    private String username;

    private Integer score = 0;

    private Integer streak = 0;

    @Column(columnDefinition = "TEXT")
    private String profilePictureBase64;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
