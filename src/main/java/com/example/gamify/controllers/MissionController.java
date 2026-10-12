package com.example.gamify.controllers;

import com.example.gamify.models.dtos.input.MissionInputDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.ApiSuccessResponse;
import com.example.gamify.services.MissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RequiredArgsConstructor
@RequestMapping("/missions")
@RestController
@Validated
@Tag(name = "Missions", description = "Endpoints relacionados a missões")
public class MissionController {
    private final MissionService missionService;

    @PostMapping("/new")
    @Operation(summary = "Criar missão")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Missão criada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da missão inválidos"),
            @ApiResponse(responseCode = "404", description = "Perfil ou tarefa não encontrado")
    })
    public ResponseEntity<MissionOutPutDTO> createNewMission(@Valid @RequestBody MissionInputDTO missionInputDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(missionService.createNewMission(missionInputDTO));
    }

    @PutMapping("/complete")
    @Operation(summary = "Concluir missão")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Missão concluída com sucesso"),
            @ApiResponse(responseCode = "404", description = "Missão não encontrada"),
            @ApiResponse(responseCode = "409", description = "Missão já concluída")
    })
    public ResponseEntity<ApiSuccessResponse> completeMission(@RequestParam UUID missionId) {
        missionService.completeMission(missionId);
        return ResponseEntity.ok(ApiSuccessResponse.of("MISSION_COMPLETED", ApiMessages.MISSION_COMPLETED));
    }

    @PutMapping("/update")
    @Operation(summary = "Atualizar missão")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Missão atualizada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da missão inválidos"),
            @ApiResponse(responseCode = "404", description = "Missão ou tarefa não encontrada"),
            @ApiResponse(responseCode = "409", description = "Missão já concluída")
    })
    public ResponseEntity<MissionOutPutDTO> updateMission(@RequestParam UUID missionId,
                                                          @Valid @RequestBody MissionInputDTO missionInputDTO) {
        return ResponseEntity.ok(missionService.updateMission(missionId, missionInputDTO));
    }

    @DeleteMapping
    @Operation(summary = "Remover missão")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Missão removida com sucesso"),
            @ApiResponse(responseCode = "404", description = "Missão não encontrada"),
            @ApiResponse(responseCode = "409", description = "Missão já concluída")
    })
    public ResponseEntity<ApiSuccessResponse> deleteMission(@RequestParam UUID missionId) {
        missionService.deleteMission(missionId);
        return ResponseEntity.ok(ApiSuccessResponse.of("MISSION_DELETED", ApiMessages.MISSION_DELETED));
    }
}
