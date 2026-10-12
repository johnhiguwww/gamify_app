package com.example.gamify.services;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.absolute.TasksDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import com.example.gamify.models.dtos.output.StoreOutputDTO;
import com.example.gamify.models.entities.Mission;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Store;
import com.example.gamify.models.entities.Tasks;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.StoreRepository;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import com.example.gamify.utils.exceptions.StoreNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileQueryService {
    private final ProfileRepository profileRepository;
    private final StoreRepository storeRepository;

    public ProfileDTO getProfileByEmail(String email) throws ProfileNotFoundException {
        log.info("Consultando perfil pelo e-mail {}", email);
        Profile profile = profileRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("Perfil não encontrado para o e-mail {}", email);
                    return new ProfileNotFoundException("Não há perfil para o usuário com email: " + email);
                });
        return profile.toDTO();
    }

    public ProfileDTO getProfileByUserId(UUID userId) throws ProfileNotFoundException {
        log.info("Consultando perfil {}", userId);
        return findProfile(userId).toDTO();
    }

    public List<TasksDTO> getProfileTasks(UUID userId) throws ProfileNotFoundException {
        log.info("Consultando tarefas do perfil {}", userId);
        List<Tasks> tasks = findProfile(userId).getTasks();
        if (tasks == null) {
            return List.of();
        }
        return tasks.stream().map(Tasks::toDTO).toList();
    }

    public List<MissionOutPutDTO> getProfileMissions(UUID userId) throws ProfileNotFoundException {
        log.info("Consultando missões do perfil {}", userId);
        List<Mission> missions = findProfile(userId).getMissions();
        if (missions == null) {
            return List.of();
        }
        return missions.stream().map(Mission::toMissionOutPutDTO).toList();
    }

    public StoreOutputDTO getStoreByProfileId(UUID profileId) throws ProfileNotFoundException, StoreNotFoundException {
        log.info("Consultando loja do perfil {}", profileId);
        findProfile(profileId);
        Store store = storeRepository.findByProfile_UserId(profileId)
                .orElseThrow(() -> {
                    log.warn("Loja não encontrada para o perfil {}", profileId);
                    return new StoreNotFoundException("Loja não encontrada para o perfil: " + profileId);
                });
        return store.toOutputDTO();
    }

    private Profile findProfile(UUID userId) {
        return profileRepository.findByUserId(userId)
                .orElseThrow(() -> {
                    log.warn("Perfil {} não encontrado", userId);
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + userId);
                });
    }
}
