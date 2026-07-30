package com.signspeak.backend.dto;

import lombok.Data;

@Data
public class UserProfileUpdateRequest {
    private String email;
    private String username;
    private String profilePictureBase64;
    private String newEmail;
    private String newPassword;
}
