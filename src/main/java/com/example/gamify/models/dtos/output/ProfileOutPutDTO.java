package com.example.gamify.models.dtos.output;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

public record ProfileOutPutDTO(
    @Schema(description = "ID do perfil do usuário", example = "123e4567-e89b-12d3-a456-426614174000")
    UUID id,
    @Schema(name = "name", description = "Nome do perfil do usuário", example = "João")
    String name,
    @Schema(description = "Email do perfil do usuário", example = "teste@g.com")
    String email
) {
}
