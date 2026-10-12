package com.example.gamify.models.dtos.output;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

public record ItemOutputDTO(
        @Schema(description = "The ID of the item", example = "1")
        UUID id,
        @Schema(description = "The title of the item", example = "Livro")
        String title,
        @Schema(description = "The value of the item", example = "100")
        int value,
        @Schema(description = "The creation date of the item", example = "2026-09-05T04:16:19.371Z")
        LocalDateTime created_at,
        @Schema(description = "The last update date of the item", example = "2026-09-05T04:16:19.371Z")
        LocalDateTime updated_at,
        @Schema(description = "The purchase date of the item", example = "2026-09-05T04:16:19.371Z")
        LocalDateTime purchase_at
) {
}
