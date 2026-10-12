package com.example.gamify.controllers;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.absolute.TasksDTO;
import com.example.gamify.models.dtos.input.ProfileInputDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.ApiSuccessResponse;
import com.example.gamify.services.ProfileQueryService;
import com.example.gamify.services.ProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RequiredArgsConstructor
@RestController
@RequestMapping("/profiles")
@Validated
@Tag(name = "Profiles", description = "Endpoints relacionados a perfis")
public class ProfileController {
    private final ProfileService profileService;
    private final ProfileQueryService profileQueryService;

    @GetMapping("/by-user-email/{email}")
    @Operation(summary = "Obter perfil por email do usuário", description = "Retorna o perfil do usuário com base no email fornecido.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil encontrado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<ProfileDTO> getProfileByUserEmail(@PathVariable String email) {
        return ResponseEntity.ok(profileQueryService.getProfileByEmail(email));
    }

    @GetMapping("/by-user-uuid/{uuid}")
    @Operation(summary = "Obter perfil por UUID do usuário")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil encontrado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<ProfileDTO> getProfileByUserUuid(@PathVariable UUID uuid) {
        return ResponseEntity.ok(profileQueryService.getProfileByUserId(uuid));
    }

    @GetMapping("/{uuid}/my_tasks")
    @Operation(summary = "Obter tarefas do perfil por UUID", description = "Retorna as tarefas associadas ao perfil do usuário.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tarefas obtidas com sucesso"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<List<TasksDTO>> getMyTasks(@PathVariable UUID uuid) {
        return ResponseEntity.ok(profileQueryService.getProfileTasks(uuid));
    }

    @GetMapping("/{uuid}/my_missions")
    @Operation(summary = "Obter missões do perfil por UUID", description = "Retorna as missões associadas ao perfil do usuário.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Missões obtidas com sucesso"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<List<MissionOutPutDTO>> getMyMissions(@PathVariable UUID uuid) {
        return ResponseEntity.ok(profileQueryService.getProfileMissions(uuid));
    }

    @PutMapping("/update/{uuid}")
    @Operation(summary = "Atualizar informações do perfil")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados do perfil inválidos"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<ApiSuccessResponse> updateUserInfo(@RequestBody @Valid ProfileInputDTO profileDTO,
                                                            @PathVariable UUID uuid) {
        profileService.updateProfileInfo(profileDTO, uuid);
        return ResponseEntity.ok(ApiSuccessResponse.of("PROFILE_UPDATED", ApiMessages.PROFILE_UPDATED));
    }
}
