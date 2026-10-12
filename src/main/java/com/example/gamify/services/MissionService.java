package com.example.gamify.services;

import com.example.gamify.models.dtos.input.MissionInputDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import com.example.gamify.models.entities.Mission;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Tasks;
import com.example.gamify.repository.MissionRespository;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.TasksRepository;
import com.example.gamify.utils.exceptions.InvalidRequestException;
import com.example.gamify.utils.exceptions.MissionAlreadyFinishedException;
import com.example.gamify.utils.exceptions.MissionNotFoundException;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import com.example.gamify.utils.exceptions.TaskNotFound;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class MissionService {

    private final MissionRespository missionRespository;
    private final ProfileRepository profileRepository;
    private final TasksRepository tasksRepository;

    @Transactional
    public MissionOutPutDTO createNewMission(MissionInputDTO missionInputDTO) {
        log.info("Criando missão para o perfil {} com título '{}'", missionInputDTO.userId(), missionInputDTO.title());
        Profile profile = profileRepository.findByUserId(missionInputDTO.userId())
                .orElseThrow(() -> {
                    log.warn("Perfil {} não encontrado ao criar missão", missionInputDTO.userId());
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + missionInputDTO.userId());
                });
        Optional<Tasks> task = resolveTask(taskIdOf(missionInputDTO), profile.getUserId());
        Mission newMission = Mission.fromMissionInputDTO(missionInputDTO, profile, task);
        missionRespository.save(newMission);
        log.info("Missão {} criada para o perfil {}", newMission.getId(), profile.getUserId());
        return newMission.toMissionOutPutDTO();
    }

    @Transactional
    public void deleteMission(UUID missionId) {
        log.info("Removendo missão {}", missionId);
        Mission mission = getMissionById(missionId);
        if (mission.isFinished()) {
            log.warn("Tentativa de remover missão já concluída: {}", missionId);
            throw new MissionAlreadyFinishedException("A missão já foi concluída e não pode ser removida.");
        }
        missionRespository.delete(mission);
        log.info("Missão {} removida", missionId);
    }

    @Transactional
    public void completeMission(UUID missionId) {
        log.info("Concluindo missão {}", missionId);
        Mission mission = getMissionById(missionId);
        if (mission.isFinished()) {
            log.warn("Tentativa de concluir missão já finalizada: {}", missionId);
            throw new MissionAlreadyFinishedException("A missão já foi concluída e não pode ser concluída novamente.");
        }
        Profile profile = mission.getProfile();
        profile.setExperience(profile.getExperience() + mission.getExperience());
        profile.setGold(profile.getGold() + mission.getReward());
        mission.setFinished(true);
        mission.setFinishedAt(LocalDateTime.now());
        profileRepository.save(profile);
        missionRespository.save(mission);
        log.info("Missão {} concluída. Perfil {} recebeu {} de experiência e {} de ouro",
                missionId, profile.getUserId(), mission.getExperience(), mission.getReward());
    }

    @Transactional
    public MissionOutPutDTO updateMission(UUID missionId, MissionInputDTO missionInputDTO) {
        log.info("Atualizando missão {}", missionId);
        Mission mission = getMissionById(missionId);
        if (mission.isFinished()) {
            log.warn("Tentativa de atualizar missão já concluída: {}", missionId);
            throw new MissionAlreadyFinishedException("A missão já foi concluída e não pode ser atualizada.");
        }
        if (missionInputDTO.userId() != null
                && mission.getProfile() != null
                && !missionInputDTO.userId().equals(mission.getProfile().getUserId())) {
            log.warn("Perfil {} não corresponde à missão {}", missionInputDTO.userId(), missionId);
            throw new InvalidRequestException("A missão não pertence ao perfil informado.");
        }
        Optional<Tasks> task = resolveTask(taskIdOf(missionInputDTO), mission.getProfile().getUserId());
        mission.updateFromMissionInputDTO(missionInputDTO, task);
        missionRespository.save(mission);
        log.info("Missão {} atualizada", missionId);
        return mission.toMissionOutPutDTO();
    }

    private Mission getMissionById(UUID missionId) {
        return missionRespository.findById(missionId)
                .orElseThrow(() -> {
                    log.warn("Missão {} não encontrada", missionId);
                    return new MissionNotFoundException("Missão não encontrada com id: " + missionId);
                });
    }

    private Optional<UUID> taskIdOf(MissionInputDTO dto) {
        return dto.taskId() == null ? Optional.empty() : dto.taskId();
    }

    private Optional<Tasks> resolveTask(Optional<UUID> taskId, UUID profileId) {
        if (taskId == null || taskId.isEmpty()) {
            return Optional.empty();
        }
        UUID id = taskId.get();
        Tasks task = tasksRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Tarefa {} não encontrada ao vincular missão", id);
                    return new TaskNotFound("A tarefa com id " + id + " não existe.");
                });
        if (task.getProfile() == null || !profileId.equals(task.getProfile().getUserId())) {
            log.warn("Tarefa {} não pertence ao perfil {}", id, profileId);
            throw new InvalidRequestException("A tarefa informada não pertence ao perfil da missão.");
        }
        return Optional.of(task);
    }
}
