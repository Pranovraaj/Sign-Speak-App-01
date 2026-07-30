package com.signspeak.backend.dto;

import lombok.Data;

@Data
public class HistoryItemDto {
    private String id;
    private String userId;
    private String text;
    private Long timestamp;
    private String image;
}
