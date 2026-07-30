package com.signspeak.backend.controller;

import com.signspeak.backend.model.Translation;
import com.signspeak.backend.model.User;
import com.signspeak.backend.repository.TranslationRepository;
import com.signspeak.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.signspeak.backend.dto.HistoryItemDto;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.stream.Collectors;

import java.util.List;

@RestController
@RequestMapping("/api/history")
@CrossOrigin(origins = "*")
public class TranslationController {

    @Autowired
    private TranslationRepository translationRepository;

    @Autowired
    private UserRepository userRepository;



    @GetMapping
    public ResponseEntity<List<HistoryItemDto>> getHistory(@RequestParam("userId") String email) {
        return userRepository.findByEmail(email)
                .map(user -> {
                    List<HistoryItemDto> list = translationRepository.findByUserOrderByTranslatedAtDesc(user).stream()
                        .map(this::mapToDto)
                        .collect(Collectors.toList());
                    return ResponseEntity.ok(list);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> saveTranslation(@RequestBody HistoryItemDto request) {
        return userRepository.findByEmail(request.getUserId())
                .map(user -> {
                    Translation translation = new Translation();
                    translation.setUser(user);
                    translation.setTextContent(request.getText());
                    translation.setImageBase64(request.getImage());
                    if (request.getTimestamp() != null) {
                        translation.setTranslatedAt(LocalDateTime.ofEpochSecond(request.getTimestamp() / 1000, 0, ZoneOffset.UTC));
                    }
                    translation = translationRepository.save(translation);
                    return ResponseEntity.ok(mapToDto(translation));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTranslation(@PathVariable Long id) {
        translationRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/purge")
    public ResponseEntity<?> purgeHistory(@RequestParam("userId") String email) {
        return userRepository.findByEmail(email)
                .map(user -> {
                    List<Translation> translations = translationRepository.findByUserOrderByTranslatedAtDesc(user);
                    translationRepository.deleteAll(translations);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private HistoryItemDto mapToDto(Translation translation) {
        HistoryItemDto dto = new HistoryItemDto();
        dto.setId(translation.getId() != null ? translation.getId().toString() : "");
        dto.setUserId(translation.getUser().getEmail());
        dto.setText(translation.getTextContent());
        dto.setImage(translation.getImageBase64());
        if (translation.getTranslatedAt() != null) {
            dto.setTimestamp(translation.getTranslatedAt().toEpochSecond(ZoneOffset.UTC) * 1000);
        }
        return dto;
    }
}
