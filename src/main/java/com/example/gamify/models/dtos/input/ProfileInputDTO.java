package com.example.gamify.models.dtos.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.validator.constraints.URL;

public record ProfileInputDTO (
        @Schema(name="userName", description="Nome do usuário", example="John Doe")
        @NotBlank(message = "O nome não pode estar vazio")
        String name,
        @Schema(name="avatarUrl", description="URL do avatar do usuário", example="https://example.com/avatar.jpg")
        @NotBlank(message = "A URL do avatar não pode estar vazia")
        @URL(message = "A URL do avatar deve ser uma URL válida")
        String avatarUrl
){
}
