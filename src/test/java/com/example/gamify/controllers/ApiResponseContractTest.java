package com.example.gamify.controllers;

import com.example.gamify.models.dtos.output.ItemOutputDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.ApiSuccessResponse;
import com.example.gamify.services.MissionService;
import com.example.gamify.services.ProfileQueryService;
import com.example.gamify.services.ProfileService;
import com.example.gamify.services.StoreItemService;
import com.example.gamify.services.TasksService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ApiResponseContractTest {
    @Mock
    private MissionService missionService;
    @Mock
    private TasksService tasksService;
    @Mock
    private ProfileService profileService;
    @Mock
    private ProfileQueryService profileQueryService;
    @Mock
    private StoreItemService storeItemService;

    @InjectMocks
    private MissionController missionController;
    @InjectMocks
    private TasksController tasksController;
    @InjectMocks
    private ProfileController profileController;
    @InjectMocks
    private StoreController storeController;

    @Test
    void missionCreationReturnsCreated() {
        UUID profileId = UUID.randomUUID();
        MissionOutPutDTO dto = new MissionOutPutDTO(UUID.randomUUID(), "Tutorial", 1, 2, false, null, null);
        when(missionService.createNewMission(org.mockito.ArgumentMatchers.any())).thenReturn(dto);

        ResponseEntity<MissionOutPutDTO> response = missionController.createNewMission(
                new com.example.gamify.models.dtos.input.MissionInputDTO(profileId, "Tutorial", 2, 1, java.util.Optional.empty())
        );

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertEquals(dto, response.getBody());
    }

    @Test
    void voidMissionOperationsReturnPersonalizedSuccess() {
        UUID missionId = UUID.randomUUID();

        ResponseEntity<ApiSuccessResponse> completed = missionController.completeMission(missionId);
        ResponseEntity<ApiSuccessResponse> deleted = missionController.deleteMission(missionId);

        assertEquals(ApiMessages.MISSION_COMPLETED, completed.getBody().message());
        assertEquals("MISSION_COMPLETED", completed.getBody().code());
        assertEquals(200, completed.getBody().status());
        assertEquals(ApiMessages.MISSION_DELETED, deleted.getBody().message());
        verify(missionService).completeMission(missionId);
        verify(missionService).deleteMission(missionId);
    }

    @Test
    void taskDeletionAndProfileUpdateReturnSuccessMessages() {
        UUID id = UUID.randomUUID();

        ResponseEntity<ApiSuccessResponse> deleted = tasksController.deleteTask(id);
        ResponseEntity<ApiSuccessResponse> updated = profileController.updateUserInfo(
                new com.example.gamify.models.dtos.input.ProfileInputDTO("Ada", "https://example.com/a.png"),
                id
        );

        assertEquals(ApiMessages.TASK_DELETED, deleted.getBody().message());
        assertEquals("TASK_DELETED", deleted.getBody().code());
        assertEquals(ApiMessages.PROFILE_UPDATED, updated.getBody().message());
        assertEquals("PROFILE_UPDATED", updated.getBody().code());
        verify(tasksService).deleteTask(id);
        verify(profileService).updateProfileInfo(org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.eq(id));
    }

    @Test
    void storeItemCreationReturnsCreatedAndDeletionReturnsMessage() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        ItemOutputDTO item = new ItemOutputDTO(itemId, "Livro", 10, LocalDateTime.now(), null, null);
        when(storeItemService.addItemToStore(org.mockito.ArgumentMatchers.eq(profileId), org.mockito.ArgumentMatchers.any()))
                .thenReturn(item);

        ResponseEntity<ItemOutputDTO> created = storeController.addItem(
                new com.example.gamify.models.dtos.input.ItemInputDTO("Livro", 10),
                profileId
        );
        ResponseEntity<ApiSuccessResponse> deleted = storeController.deleteItem(profileId, itemId);

        assertEquals(HttpStatus.CREATED, created.getStatusCode());
        assertEquals(item, created.getBody());
        assertEquals(ApiMessages.ITEM_DELETED, deleted.getBody().message());
        assertEquals("ITEM_DELETED", deleted.getBody().code());
        verify(storeItemService).deleteStoreItem(profileId, itemId);
    }
}
