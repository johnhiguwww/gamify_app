package com.example.gamify.models.dtos.output;

import com.example.gamify.models.dtos.resume.ProfileResumeDTO;
import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyEnum;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Schema(description = "DTO de saída para tarefas")
public record TasksOutPutDTO(
        @Schema(name = "id", description = "ID da tarefa")
        UUID id,
        @Schema(name = "title", description = "Título da tarefa")
        String title,
        @Schema(name = "description", description = "Descrição da tarefa")
        String description,
        @Schema(name = "reward", description = "Recompensa da tarefa")
        int reward,
        @Schema(name = "experience", description = "Experiência da tarefa")
        int experience,
        @Schema(name = "finished", description = "Status da tarefa")
        String finished,
        @Schema(name = "partOfMission", description = "Indica se a tarefa faz parte de uma missão")
        boolean partOfMission,
        @Schema(name = "frequency", description = "Frequência de recorrência da tarefa (UNICA, DIARIO, SEMANAL, MENSAL)")
        TaskFrequencyEnum frequency,
        @Schema(name = "scheduledTime", description = "Horário agendado para a tarefa (ex: 14:30)")
        LocalTime scheduledTime,
        @Schema(name = "daysOfWeek", description = "Dias da semana para recorrência (ex: [\"MON\", \"WED\", \"FRI\"])")
        List<String> daysOfWeek,
        @Schema(name = "expirationDate", description = "Data de expiração da tarefa (nulo = indefinida)")
        LocalDateTime expirationDate,
        @Schema(name = "lastCompletedAt", description = "Última data de conclusão da tarefa")
        LocalDateTime lastCompletedAt,
        @Schema(name = "completedInCurrentCycle", description = "Indica se a tarefa foi concluída no ciclo atual")
        boolean completedInCurrentCycle,
        @Schema(name = "createdAt", description = "Data de criação da tarefa")
        LocalDateTime createdAt,
        @Schema(name = "profile", description = "Perfil associado à tarefa")
        ProfileResumeDTO profile
) {
}
