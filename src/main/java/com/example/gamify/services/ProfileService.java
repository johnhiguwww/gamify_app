package com.example.gamify.services;

import com.example.gamify.models.dtos.input.ProfileInputDTO;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileService {
    private final ProfileRepository profileRepository;

    public boolean validateProfile(UUID profileId) {
        boolean exists = profileRepository.findByUserId(profileId).isPresent();
        log.info("Validação do perfil {}: {}", profileId, exists ? "encontrado" : "ausente");
        return exists;
    }

    @Transactional
    public void updateProfileInfo(@NonNull ProfileInputDTO profileDTO, UUID userId) throws ProfileNotFoundException {
        log.info("Atualizando perfil {}", userId);
        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> {
                    log.warn("Perfil {} não encontrado para atualização", userId);
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + userId);
                });
        profile.setName(profileDTO.name());
        profile.setAvatarUrl(profileDTO.avatarUrl());
        profileRepository.save(profile);
        log.info("Perfil {} atualizado", userId);
    }
}

