package com.example.gamify.models.dtos.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "DTO para entrada de dados do item")
public record ItemInputDTO(
        @Schema(description = "O título do item", example = "Livro")
        @NotBlank(message = "O nome do item não pode estar vazio")
        String name,
        @Schema(description = "Valor do item", example = "100")
        @Min(value = 1, message = "O valor deve ser maior ou igual a 1")
        int value
) {
}

