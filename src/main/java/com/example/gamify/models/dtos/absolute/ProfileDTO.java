package com.example.gamify.models.dtos.absolute;

import com.example.gamify.models.dtos.output.AtributesOutPutDTO;
import com.example.gamify.models.entities.Tasks;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema(description = "DTO de perfil do usuário")
public record ProfileDTO(
        @Schema(description = "ID do usuário", example = "123e4567-e89b-12d3-a456-426614174000")
        UUID userId,
        @Schema(description = "Email do usuário", example = "johndoe@example.com")
        String email,
        @Schema(description = "Nome do usuário", example = "John Doe")
        String name,
        @Schema(description = "URL do avatar do usuário", example = "https://example.com/avatar.jpg")
        String avatarUrl,
        @Schema(description = "Nível do usuário", example = "1")
        int level,
        @Schema(description = "Experiência do usuário", example = "0")
        int experience,
        @Schema(description = "Ouro do usuário", example = "0")
        int gold,
        @Schema(description = "Atributos do usuário")
        AtributesOutPutDTO atributes
) {
}
