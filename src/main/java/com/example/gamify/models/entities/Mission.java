package com.example.gamify.models.entities;

import com.example.gamify.models.dtos.input.MissionInputDTO;
import com.example.gamify.models.dtos.output.MissionOutPutDTO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Entity
@SuppressWarnings("JpaDataSourceORMInspection")
@Table(name = "missions")
public class Mission {
    @Id
    @UuidGenerator
    @Getter
    private UUID id;

    @Getter
    @ManyToOne
    @JoinColumn(nullable = false, updatable = false)
    private Profile profile;

    @Getter
    @OneToOne
    @JoinColumn(nullable = true, updatable = false)
    private Tasks task;

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
    private int experience;

    @Getter
    @Setter
    @Column(nullable = false)
    private int reward;

    @Getter
    @Setter
    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
    private boolean finished = false;

    @Getter
    @Setter
    private LocalDateTime updatedAt = LocalDateTime.now();

    @Getter
    @Setter
    private LocalDateTime finishedAt;

    public Mission(){}

    public Mission(Profile profile, String title, int experience, int reward) {
        this.profile = profile;
        this.title = title;
        this.experience = experience;
        this.reward = reward;
    }

    public MissionOutPutDTO toMissionOutPutDTO() {
        return new MissionOutPutDTO(
                this.id,
                this.title,
                this.experience,
                this.reward,
                this.finished,
                Optional.ofNullable(this.task).map(Tasks::toOutputDTO).orElse(null),
                profile.toResumeDTO()
        );
    }

    public void updateFromMissionInputDTO(MissionInputDTO missionInputDTO, Optional<Tasks> task) {
        this.title = missionInputDTO.title();
        this.experience = missionInputDTO.experience();
        this.reward = missionInputDTO.reward();
        this.task = task.orElse(null);
        this.updatedAt = LocalDateTime.now();
    }

    static public Mission fromMissionInputDTO(MissionInputDTO missionInputDTO, Profile profile, Optional<Tasks> task) {
        Mission mission = new Mission();
        mission.profile = profile;
        mission.title = missionInputDTO.title();
        mission.experience = missionInputDTO.experience();
        mission.reward = missionInputDTO.reward();
        mission.task = task.orElse(null);
        return mission;
    }
}
