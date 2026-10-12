package com.example.gamify.services;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.input.TasksInputDTO;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Tasks;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.TasksRepository;
import com.example.gamify.utils.entities.atributes.AttributesLebels;
import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyEnum;
import com.example.gamify.utils.exceptions.InvalidRequestException;
import com.example.gamify.utils.exceptions.TaskAlreadyCompleted;
import com.example.gamify.utils.exceptions.TaskNotFound;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TasksServiceTest {
    @Mock
    private TasksRepository tasksRepository;
    @Mock
    private ProfileRepository profileRepository;
    @InjectMocks
    private TasksService tasksService;

    @Test
    void persistsCompletionTimestampBeforeSaving() {
        UUID taskId = UUID.randomUUID();
        Profile profile = new Profile();
        profile.setUserId(UUID.randomUUID());
        profile.setEmail("hero@gamify.test");
        Tasks task = openTask(profile, 25);
        when(tasksRepository.findById(taskId)).thenReturn(Optional.of(task));
        when(tasksRepository.save(any(Tasks.class))).thenAnswer(invocation -> {
            Tasks saved = invocation.getArgument(0);
            assertNotNull(saved.getLastCompletedAt());
            assertTrue(saved.isFinished());
            return saved;
        });

        ProfileDTO result = tasksService.completedTask(taskId);

        assertEquals(25, profile.getGold());
        assertEquals(25, profile.getAttributes().getCharisma());
        assertEquals(25, result.gold());
        verify(profileRepository).save(profile);
    }

    @Test
    void rejectsAlreadyCompletedTask() {
        UUID taskId = UUID.randomUUID();
        Tasks task = openTask(new Profile(), 5);
        task.setFinished(true);
        when(tasksRepository.findById(taskId)).thenReturn(Optional.of(task));

        assertThrows(TaskAlreadyCompleted.class, () -> tasksService.completedTask(taskId));
    }

    @Test
    void missingTaskReturnsNotFound() {
        UUID taskId = UUID.randomUUID();
        when(tasksRepository.findById(taskId)).thenReturn(Optional.empty());

        assertThrows(TaskNotFound.class, () -> tasksService.deleteTask(taskId));
    }

    @Test
    void rejectsExpirationDateInThePast() {
        UUID taskId = UUID.randomUUID();
        TasksInputDTO input = new TasksInputDTO(
                UUID.randomUUID(),
                "Estudar",
                "Ler um capítulo",
                5,
                5,
                AttributesLebels.intelligence,
                TaskFrequencyEnum.DAILY,
                null,
                null,
                LocalDateTime.now().minusDays(1),
                false
        );

        assertThrows(InvalidRequestException.class, () -> tasksService.updateTask(input, taskId));
    }

    @Test
    void completingCycleIncrementsRecurrenceAndMarksCurrentCycle() {
        UUID taskId = UUID.randomUUID();
        Profile profile = new Profile();
        profile.setUserId(UUID.randomUUID());
        profile.setEmail("hero@gamify.test");
        Tasks task = openTask(profile, 8);
        when(tasksRepository.findById(taskId)).thenReturn(Optional.of(task));
        when(tasksRepository.save(any(Tasks.class))).thenAnswer(invocation -> invocation.getArgument(0));

        tasksService.completeCycleTask(taskId);

        assertEquals(1, task.getRecurrenceCount());
        assertTrue(task.isCompletedInCurrentCycle());
        assertNotNull(task.getLastCompletedAt());
        assertEquals(8, profile.getGold());
    }

    private Tasks openTask(Profile profile, int reward) {
        Tasks task = new Tasks();
        task.setProfile(profile);
        task.setReward(reward);
        task.setExperience(reward);
        task.setAttribute(AttributesLebels.charisma);
        task.setTitle("Treinar");
        task.setDescription("Treino diário");
        task.setFrequency(TaskFrequencyEnum.DAILY);
        task.setFinished(false);
        return task;
    }
}
