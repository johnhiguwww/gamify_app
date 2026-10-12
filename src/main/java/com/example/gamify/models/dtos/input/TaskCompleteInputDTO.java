package com.example.gamify.models.dtos.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record TaskCompleteInputDTO(
        @Schema(description = "ID da tarefa a ser concluída", example = "123e4567-e89b-12d3-a456-426614174000")
        @NotNull(message = "O ID da tarefa é obrigatório")
        UUID taskId
) {
}
