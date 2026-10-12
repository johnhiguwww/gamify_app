package com.example.gamify.models.entities;

import com.example.gamify.models.dtos.absolute.TasksDTO;
import com.example.gamify.models.dtos.input.TasksInputDTO;
import com.example.gamify.models.dtos.output.TasksOutPutDTO;
import com.example.gamify.utils.entities.atributes.AttributesLebels;
import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyDaysOfWeekEnum;
import com.example.gamify.utils.entities.taskFrequencyOptions.TaskFrequencyEnum;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Entity
@Table(name = "tasks")
public class Tasks {
    @Id
    @UuidGenerator
    @Getter
    private UUID id;

    @Getter
    @Setter
    @ManyToOne
    @JoinColumn(nullable = false, updatable = false)
    private Profile profile;

    @Getter
    @Setter
    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Getter
    @Setter
    @Column(nullable = false)
    private String title;

    @Getter
    @Setter
    @Column(nullable = false)
    private int reward;

    @Getter
    @Setter
    @Column(nullable = false)
    private String description;

    @Getter
    @Setter
    @Column(nullable = false)
    private AttributesLebels attribute;

    @Getter
    @Setter
    @Column(nullable = false)
    private int experience;

    // Flag para indicar se pertence a uma missão
    @Getter
    @Setter
    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private boolean partOfMission = false;

    @Getter
    @Setter
    @Column(nullable = false)
    private TaskFrequencyEnum frequency;

    @Getter
    @Setter
    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private boolean finished = false;

    // ========== CAMPOS DE RECORRÊNCIA ==========

    @Getter
    @Setter
    @Column(nullable = true)
    private int recurrenceCount = 0;

    @Getter
    @Setter
    private LocalTime scheduledTime;

    @Getter
    @Setter
    @Enumerated(EnumType.STRING)
    private TaskFrequencyDaysOfWeekEnum daysOfWeek;

    @Getter
    @Setter
    @Column(columnDefinition = "TIMESTAMP")
    private LocalDateTime expirationDate;

    @Getter
    @Setter
    private LocalDateTime lastCompletedAt;

    @Getter
    @Setter
    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private boolean completedInCurrentCycle = false;

    public Tasks(){}

    public Tasks(
            String title, String description, int reward,
            int experience, TaskFrequencyEnum frequency,
            LocalTime scheduledTime, TaskFrequencyDaysOfWeekEnum daysOfWeek,
            LocalDateTime expirationDate, boolean partOfMission,
            Profile profile, LocalDateTime lastCompletedAt, boolean completedInCurrentCycle,
            AttributesLebels attribute
            ) {
        this.title = title;
        this.description = description;
        this.reward = reward;
        this.experience = experience;
        this.frequency = frequency;
        this.scheduledTime = scheduledTime;
        this.daysOfWeek = daysOfWeek;
        this.expirationDate = expirationDate;
        this.partOfMission = partOfMission;
        this.profile = profile;
        this.completedInCurrentCycle = completedInCurrentCycle;
        this.lastCompletedAt = lastCompletedAt;
        this.attribute = attribute;
    }

    public TasksDTO toDTO() {
        return new TasksDTO(
                id,
                title,
                description,
                reward,
                experience,
                finished ? "COMPLETED" : "PENDING",
                partOfMission,
                frequency.name(),
                scheduledTime,
                daysOfWeek != null ? List.of(daysOfWeek.name()) : null,
                expirationDate,
                lastCompletedAt,
                completedInCurrentCycle,
                createdAt
        );
    }

    public TasksOutPutDTO toOutputDTO() {
        return new TasksOutPutDTO(
                id,
                title,
                description,
                reward,
                experience,
                finished ? "COMPLETED" : "PENDING",
                partOfMission,
                frequency,
                scheduledTime,
                daysOfWeek != null ? List.of(daysOfWeek.name()) : null,
                expirationDate,
                lastCompletedAt,
                completedInCurrentCycle,
                createdAt,
                profile.toResumeDTO()
        );
    }

    public static Tasks fromInputDTO(TasksInputDTO taskInputDTO, Profile profile) {
        return new Tasks(
                taskInputDTO.title(),
                taskInputDTO.description(),
                taskInputDTO.reward(),
                taskInputDTO.experience(),
                taskInputDTO.frequency(),
                taskInputDTO.scheduledTime(),
                mapDaysOfWeek(taskInputDTO.daysOfWeek()),
                taskInputDTO.expirationDate(),
                taskInputDTO.partOfMission(),
                profile,
                null,
                false,
                taskInputDTO.attributes()
        );
    }

    public void updateFromInputDTO(TasksInputDTO taskInputDTO) {
        this.setTitle(taskInputDTO.title());
        this.setDescription(taskInputDTO.description());
        this.setReward(taskInputDTO.reward());
        this.setExperience(taskInputDTO.experience());
        this.setFrequency(taskInputDTO.frequency());
        this.setScheduledTime(taskInputDTO.scheduledTime());
        this.setDaysOfWeek(mapDaysOfWeek(taskInputDTO.daysOfWeek()));
        this.setExpirationDate(taskInputDTO.expirationDate());
        this.setPartOfMission(taskInputDTO.partOfMission());
        this.setAttribute(taskInputDTO.attributes());
    }

    private static TaskFrequencyDaysOfWeekEnum mapDaysOfWeek(List<String> daysOfWeek) {
        if (daysOfWeek == null || daysOfWeek.isEmpty()) {
            return null;
        }

        String joinedValue = String.join("_", daysOfWeek)
                .trim()
                .toUpperCase(Locale.ROOT)
                .replace('-', '_')
                .replace(' ', '_');

        for (TaskFrequencyDaysOfWeekEnum value : TaskFrequencyDaysOfWeekEnum.values()) {
            if (value.name().equals(joinedValue)) {
                return value;
            }
        }

        String firstDay = daysOfWeek.getFirst()
                .trim()
                .toUpperCase(Locale.ROOT)
                .replace('-', '_')
                .replace(' ', '_');

        try {
            return TaskFrequencyDaysOfWeekEnum.valueOf(firstDay);
        } catch (IllegalArgumentException ignored) {
            return null;
        }
    }
}
