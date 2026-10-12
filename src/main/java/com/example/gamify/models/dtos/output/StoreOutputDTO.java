package com.example.gamify.models.dtos.output;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

public record StoreOutputDTO(
        @Schema(description = "O ID da loja", example = "123e4567-e89b-12d3-a456-426614174000")
        UUID id,
        @Schema(description = "O ID do perfil associado à loja", example = "123e4567-e89b-12d3-a456-426614174000")
        UUID profileId,
        @Schema(description = "A lista de itens disponíveis na loja")
        List<ItemOutputDTO> items
) {
}
