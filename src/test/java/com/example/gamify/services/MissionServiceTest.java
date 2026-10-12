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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MissionServiceTest {
    @Mock
    private MissionRespository missionRespository;
    @Mock
    private ProfileRepository profileRepository;
    @Mock
    private TasksRepository tasksRepository;
    @InjectMocks
    private MissionService missionService;

    @Test
    void createsMissionWithoutTask() {
        UUID profileId = UUID.randomUUID();
        Profile profile = profile(profileId);
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile));
        when(missionRespository.save(any(Mission.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MissionOutPutDTO result = missionService.createNewMission(
                new MissionInputDTO(profileId, "Tutorial", 20, 15, null)
        );

        assertEquals("Tutorial", result.title());
        assertEquals(20, result.reward());
        assertEquals(profileId, result.profile().id());
    }

    @Test
    void rejectsMissingProfile() {
        UUID profileId = UUID.randomUUID();
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.empty());

        assertThrows(ProfileNotFoundException.class, () -> missionService.createNewMission(
                new MissionInputDTO(profileId, "Tutorial", 1, 1, Optional.empty())
        ));
    }

    @Test
    void rejectsTaskFromAnotherProfile() {
        UUID profileId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();
        Profile owner = profile(profileId);
        Profile other = profile(UUID.randomUUID());
        Tasks task = new Tasks();
        task.setProfile(other);
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(owner));
        when(tasksRepository.findById(taskId)).thenReturn(Optional.of(task));

        assertThrows(InvalidRequestException.class, () -> missionService.createNewMission(
                new MissionInputDTO(profileId, "Tutorial", 1, 1, Optional.of(taskId))
        ));
        verify(missionRespository, never()).save(any());
    }

    @Test
    void rejectsUnknownTask() {
        UUID profileId = UUID.randomUUID();
        UUID taskId = UUID.randomUUID();
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile(profileId)));
        when(tasksRepository.findById(taskId)).thenReturn(Optional.empty());

        assertThrows(TaskNotFound.class, () -> missionService.createNewMission(
                new MissionInputDTO(profileId, "Tutorial", 1, 1, Optional.of(taskId))
        ));
    }

    @Test
    void completesMissionAndPersistsFinishedAt() {
        UUID missionId = UUID.randomUUID();
        Profile profile = profile(UUID.randomUUID());
        Mission mission = Mission.fromMissionInputDTO(
                new MissionInputDTO(profile.getUserId(), "Boss", 30, 12, Optional.empty()),
                profile,
                Optional.empty()
        );
        when(missionRespository.findById(missionId)).thenReturn(Optional.of(mission));

        missionService.completeMission(missionId);

        assertTrue(mission.isFinished());
        assertNotNull(mission.getFinishedAt());
        assertEquals(12, profile.getExperience());
        assertEquals(30, profile.getGold());
        verify(profileRepository).save(profile);
        verify(missionRespository).save(mission);
    }

    @Test
    void doesNotCompleteFinishedMission() {
        UUID missionId = UUID.randomUUID();
        Mission mission = Mission.fromMissionInputDTO(
                new MissionInputDTO(UUID.randomUUID(), "Boss", 1, 1, Optional.empty()),
                profile(UUID.randomUUID()),
                Optional.empty()
        );
        mission.setFinished(true);
        when(missionRespository.findById(missionId)).thenReturn(Optional.of(mission));

        assertThrows(MissionAlreadyFinishedException.class, () -> missionService.completeMission(missionId));
        verify(missionRespository, never()).save(any());
    }

    @Test
    void doesNotDeleteFinishedMission() {
        UUID missionId = UUID.randomUUID();
        Mission mission = Mission.fromMissionInputDTO(
                new MissionInputDTO(UUID.randomUUID(), "Boss", 1, 1, Optional.empty()),
                profile(UUID.randomUUID()),
                Optional.empty()
        );
        mission.setFinished(true);
        when(missionRespository.findById(missionId)).thenReturn(Optional.of(mission));

        assertThrows(MissionAlreadyFinishedException.class, () -> missionService.deleteMission(missionId));
        verify(missionRespository, never()).delete(any());
    }

    @Test
    void missingMissionReturnsNotFound() {
        UUID missionId = UUID.randomUUID();
        when(missionRespository.findById(missionId)).thenReturn(Optional.empty());

        assertThrows(MissionNotFoundException.class, () -> missionService.deleteMission(missionId));
    }

    private Profile profile(UUID id) {
        Profile profile = new Profile();
        profile.setUserId(id);
        profile.setEmail(id + "@gamify.test");
        return profile;
    }
}
