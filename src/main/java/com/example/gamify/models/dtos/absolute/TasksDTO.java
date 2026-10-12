package com.example.gamify.models.dtos.absolute;


import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyDaysOfWeekEnum;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record TasksDTO(
    @Schema(description = "ID da tarefa", example = "123e4567-e89b-12d3-a456-426614174000")
    UUID id,
    @Schema(description = "Título da tarefa", example = "Complete a missão")
    String title,
    @Schema(description = "Descrição da tarefa", example = "Complete a missão para ganhar recompensa")
    String description,
    @Schema(description = "Recompensa da tarefa", example = "100")
    int reward,
    @Schema(description = "Experiência da tarefa", example = "50")
    int experience,
    @Schema(description = "Status da tarefa", example = "PENDING")
    String finished,
    @Schema(description = "Indica se a tarefa faz parte de uma missão", example = "false")
    boolean partOfMission,
    @Schema(description = "Frequência de recorrência da tarefa (UNICA, DIARIO, SEMANAL, MENSAL)", example = "DIARIO")
    String frequency,
    @Schema(description = "Horário agendado para a tarefa (ex: 14:30)", example = "14:30")
    LocalTime scheduledTime,
    @Schema(description = "Dias da semana para recorrência (ex: [\"MON\", \"WED\", \"FRI\"])", example = "[\"MON\", \"WED\", \"FRI\"]")
    List<String> daysOfWeek,
    @Schema(description = "Data de expiração da tarefa (nulo = indefinida)", example = "2024-12-31T23:59:59")
    LocalDateTime expirationDate,
    @Schema(description = "Última data de conclusão da tarefa", example = "2024-12-01T10:00:00")
    LocalDateTime lastCompletedAt,
    @Schema(description = "Indica se a tarefa foi concluída no ciclo atual", example = "false")
    boolean completedInCurrentCycle,
    @Schema(description = "Data de criação da tarefa", example = "2024-11-01T09:00:00")
    LocalDateTime createdAt
) {
}
