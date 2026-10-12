package com.example.gamify.models.dtos.resume;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

@Schema(name = "ProfileResumeDTO", description = "Resumo das informações do perfil")
public record ProfileResumeDTO (
        @Schema(description = "ID do perfil", example = "123e4567-e89b-12d3-a456-426614174000")
        UUID id,
        @Schema(description = "Email do perfil", example = "exemplo@dominio.com")
        String email

){
}
