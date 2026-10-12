package com.example.gamify.models.dtos.input;

import com.example.gamify.utils.entities.atributes.AttributesLebels;
import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyEnum;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Schema(description = "DTO para entrada de tarefas")
public record TasksInputDTO(
        @Schema(name = "profileUuid", description = "UUID do perfil do usuário que a tarefa pertence")
        @NotNull(message = "O UUID do perfil é obrigatório")
        UUID profileUuid,
        
        @Schema(name = "title", description = "Título da tarefa")
        @NotBlank(message = "O título é obrigatório")
        String title,
        
        @Schema(name = "description", description = "Descrição da tarefa")
        @NotBlank(message = "A descrição é obrigatória")
        String description,

        @Schema(name = "reward", description = "Recompensa em moeda da tarefa")
        @NotNull(message = "A recompensa é obrigatória")
        @Min(value = 1, message = "A recompensa não pode ser negativa")
        Integer reward,

        @Schema(name = "experience", description = "Experiência ganho ao completar a tarefa")
        @NotNull(message = "A experiência é obrigatória")
        @Min(value = 1, message = "A experiência não pode ser negativa")
        Integer experience,

        @Schema(name = "attributes", description = "Atributo da tarefa, exemplo: charisma")
        @NotNull(message = "O atributo é obrigatório")
        AttributesLebels attributes,
        
        @Schema(name = "frequency", description = "Frequência de recorrência (UNICA, DIARIO, SEMANAL, MENSAL)")
        @NotNull(message = "A frequência é obrigatória")
        TaskFrequencyEnum frequency,
        
        @Schema(name = "scheduledTime", description = "Horário agendado para a tarefa (ex: 14:30) - opcional")
        @JsonFormat(pattern = "HH:mm")
        LocalTime scheduledTime,
        
        @Schema(name = "daysOfWeek", description = "Dias da semana para recorrência (ex: [\"MON\", \"WED\", \"FRI\"]) - obrigatório se frequência é SEMANAL", defaultValue = "[\"MON\"]")
        List<String> daysOfWeek,
        
        @Schema(name = "expirationDate", description = "Data de expiração da tarefa (nulo = indefinida) - opcional")
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
        LocalDateTime expirationDate,
        
        @Schema(name = "partOfMission", description = "Indica se a tarefa faz parte de uma missão")
        boolean partOfMission
) {
}
