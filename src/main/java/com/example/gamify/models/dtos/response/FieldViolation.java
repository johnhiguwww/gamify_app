package com.example.gamify.models.dtos.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Detalhe de um campo inválido")
public record FieldViolation(
        @Schema(description = "Campo que falhou na validação", example = "title")
        String field,
        @Schema(description = "Mensagem personalizada do campo", example = "O título é obrigatório")
        String message
) {
}
