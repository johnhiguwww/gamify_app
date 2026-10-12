package com.example.gamify.models.dtos.output;

import com.example.gamify.models.dtos.resume.ProfileResumeDTO;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

@Schema(description = "DTO de saída para missões")
public record MissionOutPutDTO(
        @Schema(name = "id", description = "ID da missão")
        UUID id,
        @Schema(name = "title", description = "Título da missão")
        String title,
        @Schema(name = "experience", description = "Experiência concedida pela missão")
        int experience,
        @Schema(name = "reward", description = "Recompensa em ouro da missão")
        int reward,
        @Schema(name = "finished", description = "Indica se a missão foi concluída")
        boolean finished,
        @Schema(name = "tasks", description = "Tarefas associadas à missão")
        TasksOutPutDTO tasks,
        @Schema(name = "profile", description = "Perfil associado à missão")
        ProfileResumeDTO profile
) {
}
