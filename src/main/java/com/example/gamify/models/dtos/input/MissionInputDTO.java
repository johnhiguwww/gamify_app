package com.example.gamify.models.dtos.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.Optional;
import java.util.UUID;

@Schema(name = "DTO para a entrada de dados da missão")
public record MissionInputDTO(
        @NotNull(message = "O id do usuário é obrigatório")
        @Schema(description = "Id do usuário", example = "64d1c443-d9ee-4653-b39e-8f221e2c48c2")
        UUID userId,
        @NotBlank(message = "O título da missão é obrigatório")
        @Schema(description = "Título da missão", example = "Completar tutorial")
        String title,
        @Schema(name = "reward", description = "Recompensa em moeda da tarefa")
        @NotNull(message = "A recompensa é obrigatória")
        @Min(value = 0, message = "A recompensa não pode ser negativa")
        Integer reward,

        @Schema(name = "experience", description = "Experiência ganho ao completar a tarefa")
        @NotNull(message = "A experiência é obrigatória")
        @Min(value = 0, message = "A experiência não pode ser negativa")
        Integer experience,

        @Schema(description = "ID da tarefa associada", example = "64d1c443-d9ee-4653-b39e-8f221e2c48c2")
        Optional<UUID> taskId
) {
}
