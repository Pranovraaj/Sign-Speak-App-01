package com.signspeak.backend.repository;

import com.signspeak.backend.model.Translation;
import com.signspeak.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TranslationRepository extends JpaRepository<Translation, Long> {
    List<Translation> findByUserOrderByTranslatedAtDesc(User user);
}
