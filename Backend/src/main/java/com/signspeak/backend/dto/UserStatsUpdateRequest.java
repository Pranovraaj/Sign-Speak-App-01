package com.signspeak.backend.dto;

import lombok.Data;

@Data
public class UserStatsUpdateRequest {
    private String email;
    private Integer score;
    private Integer streak;
}
