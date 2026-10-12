package com.example.gamify.models.dtos.response;

import com.example.gamify.utils.exceptions.GamifyException;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "Resposta padronizada de erro da API")
public record ApiErrorResponse(
        @Schema(description = "Momento em que o erro foi registrado")
        LocalDateTime timestamp,
        @Schema(description = "Código HTTP", example = "404")
        int status,
        @Schema(description = "Razão HTTP", example = "Not Found")
        String error,
        @Schema(description = "Código estável do erro", example = "PROFILE_NOT_FOUND")
        String code,
        @Schema(description = "Mensagem personalizada para o cliente")
        String message,
        @Schema(description = "Caminho da requisição", example = "/profiles/uuid")
        String path,
        @Schema(description = "Violações de campo, quando a falha é de validação")
        List<FieldViolation> violations
) {
    public static ApiErrorResponse of(HttpStatus status, String code, String message, String path, List<FieldViolation> violations) {
        return new ApiErrorResponse(
                LocalDateTime.now(),
                status.value(),
                status.getReasonPhrase(),
                code,
                message,
                path,
                violations == null ? List.of() : List.copyOf(violations)
        );
    }

    public static ApiErrorResponse of(GamifyException exception, String path) {
        return of(exception.getStatus(), exception.getCode(), exception.getMessage(), path, List.of());
    }
}
