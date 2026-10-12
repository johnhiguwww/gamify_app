package com.example.gamify.services;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.input.TasksInputDTO;
import com.example.gamify.models.dtos.output.TasksOutPutDTO;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Tasks;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.TasksRepository;
import com.example.gamify.utils.exceptions.InvalidRequestException;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import com.example.gamify.utils.exceptions.TaskAlreadyCompleted;
import com.example.gamify.utils.exceptions.TaskNotFound;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class TasksService {
    private final TasksRepository tasksRepository;
    private final ProfileRepository profileRepository;

    @Transactional
    public TasksOutPutDTO createTask(TasksInputDTO taskInputDTO) {
        log.info("Criando tarefa '{}' para o perfil {}", taskInputDTO.title(), taskInputDTO.profileUuid());
        Profile profile = profileRepository.findByUserId(taskInputDTO.profileUuid())
                .orElseThrow(() -> {
                    log.warn("Perfil {} não encontrado ao criar tarefa", taskInputDTO.profileUuid());
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + taskInputDTO.profileUuid());
                });
        Tasks tasks = Tasks.fromInputDTO(taskInputDTO, profile);
        Tasks saved = tasksRepository.save(tasks);
        log.info("Tarefa {} criada para o perfil {}", saved.getId(), profile.getUserId());
        return saved.toOutputDTO();
    }

    @Transactional
    public TasksOutPutDTO updateTask(TasksInputDTO taskInputDTO, UUID taskId) {
        log.info("Atualizando tarefa {}", taskId);
        if (taskInputDTO.expirationDate() != null && taskInputDTO.expirationDate().isBefore(LocalDateTime.now())) {
            log.warn("Data de expiração inválida ao atualizar tarefa {}", taskId);
            throw new InvalidRequestException("A data de expiração deve estar no futuro.");
        }
        Tasks tasks = tasksRepository.findById(taskId)
                .orElseThrow(() -> {
                    log.warn("Tarefa {} não encontrada para atualização", taskId);
                    return new TaskNotFound("Tarefa não encontrada com id: " + taskId);
                });
        tasks.updateFromInputDTO(taskInputDTO);
        Tasks saved = tasksRepository.save(tasks);
        log.info("Tarefa {} atualizada", taskId);
        return saved.toOutputDTO();
    }

    @Transactional
    public ProfileDTO completedTask(UUID taskId) {
        log.info("Concluindo tarefa {}", taskId);
        Tasks tasks = tasksRepository.findById(taskId)
                .orElseThrow(() -> {
                    log.warn("Tarefa {} não encontrada para conclusão", taskId);
                    return new TaskNotFound("Tarefa não encontrada com id: " + taskId);
                });

        if (tasks.isFinished()) {
            log.warn("Tarefa {} já estava concluída", taskId);
            throw new TaskAlreadyCompleted("A tarefa já foi concluída: " + taskId);
        }

        Profile profile = requireProfileWithAttributes(tasks);
        tasks.setFinished(true);
        tasks.setLastCompletedAt(LocalDateTime.now());
        profile.setGold(profile.getGold() + tasks.getReward());
        profile.getAttributes().updateAttribute(tasks.getAttribute(), tasks.getReward());
        tasksRepository.save(tasks);
        profileRepository.save(profile);

        log.info("Tarefa {} concluída pelo perfil {}. Recompensa: {} de ouro",
                taskId, profile.getUserId(), tasks.getReward());
        return profile.toDTO();
    }

    @Transactional
    public void deleteTask(UUID taskId) {
        log.info("Removendo tarefa {}", taskId);
        Tasks tasks = tasksRepository.findById(taskId)
                .orElseThrow(() -> {
                    log.warn("Tarefa {} não encontrada para remoção", taskId);
                    return new TaskNotFound("Tarefa não encontrada com id: " + taskId);
                });
        tasksRepository.delete(tasks);
        log.info("Tarefa {} removida", taskId);
    }

    @Transactional
    public TasksOutPutDTO completeCycleTask(UUID taskId) {
        log.info("Concluindo ciclo da tarefa {}", taskId);
        Tasks tasks = tasksRepository.findById(taskId)
                .orElseThrow(() -> {
                    log.warn("Tarefa {} não encontrada para conclusão de ciclo", taskId);
                    return new TaskNotFound("Tarefa não encontrada com id: " + taskId);
                });

        if (tasks.isFinished()) {
            log.warn("Ciclo recusado: tarefa {} já está concluída", taskId);
            throw new TaskAlreadyCompleted("A tarefa já foi concluída: " + taskId);
        }
        Profile profile = requireProfileWithAttributes(tasks);
        tasks.setRecurrenceCount(tasks.getRecurrenceCount() + 1);
        tasks.setCompletedInCurrentCycle(true);
        tasks.setLastCompletedAt(LocalDateTime.now());
        profile.setGold(profile.getGold() + tasks.getReward());
        profile.getAttributes().updateAttribute(tasks.getAttribute(), tasks.getReward());
        tasksRepository.save(tasks);
        profileRepository.save(profile);
        log.info("Ciclo da tarefa {} concluído. Recorrências: {}. Perfil: {}",
                taskId, tasks.getRecurrenceCount(), profile.getUserId());
        return tasks.toOutputDTO();
    }

    private Profile requireProfileWithAttributes(Tasks tasks) {
        Profile profile = tasks.getProfile();
        if (profile == null || profile.getAttributes() == null) {
            log.warn("Tarefa {} sem perfil ou atributos para receber recompensa", tasks.getId());
            throw new InvalidRequestException("O perfil da tarefa não possui atributos para receber a recompensa.");
        }
        return profile;
    }
}
