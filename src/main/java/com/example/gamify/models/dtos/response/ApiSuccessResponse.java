package com.example.gamify.models.dtos.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Resposta padronizada de sucesso para operações sem corpo de recurso")
public record ApiSuccessResponse(
        @Schema(description = "Momento em que a operação foi concluída")
        LocalDateTime timestamp,
        @Schema(description = "Código HTTP", example = "200")
        int status,
        @Schema(description = "Código estável do sucesso", example = "MISSION_COMPLETED")
        String code,
        @Schema(description = "Mensagem personalizada de sucesso")
        String message
) {
    public static ApiSuccessResponse of(String code, String message) {
        return new ApiSuccessResponse(LocalDateTime.now(), 200, code, message);
    }
}
