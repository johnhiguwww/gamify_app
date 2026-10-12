package com.example.gamify.models.dtos.output;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "DTO de atributos do usuário")
public record AtributesOutPutDTO(
        @Schema(description = "Força do usuário", example = "0")
        int strength,
        @Schema(description = "Espiritualidade do usuário", example = "0")
        int spirituality,
        @Schema(description = "Inteligência do usuário", example = "0")
        int intelligence,
        @Schema(description = "Carisma do usuário", example = "0")
        int charisma,
        @Schema(description = "Percepção espacial do usuário", example = "0")
        int spatialPerception,
        @Schema(description = "Autoconsciência do usuário", example = "0")
        int selfAwareness,
        @Schema(description = "Linguagem do usuário", example = "0")
        int language,
        @Schema(description = "Raciocínio lógico do usuário", example = "0")
        int logicalReasoning,
        @Schema(description = "Musicalidade do usuário", example = "0")
        int musicality
) {
}
