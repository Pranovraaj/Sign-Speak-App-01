package com.signspeak.backend.controller;

import com.signspeak.backend.model.Translation;
import com.signspeak.backend.model.User;
import com.signspeak.backend.repository.TranslationRepository;
import com.signspeak.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/history")
@CrossOrigin(origins = "*")
public class TranslationController {

    @Autowired
    private TranslationRepository translationRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/{email}")
    public ResponseEntity<List<Translation>> getHistory(@PathVariable String email) {
        return userRepository.findByEmail(email)
                .map(user -> ResponseEntity.ok(translationRepository.findByUserOrderByTranslatedAtDesc(user)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{email}")
    public ResponseEntity<?> saveTranslation(@PathVariable String email, @RequestBody String text) {
        return userRepository.findByEmail(email)
                .map(user -> {
                    Translation translation = new Translation();
                    translation.setUser(user);
                    translation.setTextContent(text);
                    translationRepository.save(translation);
                    return ResponseEntity.ok("Saved");
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
