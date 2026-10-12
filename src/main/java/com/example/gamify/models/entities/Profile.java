package com.example.gamify.models.entities;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.resume.ProfileResumeDTO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Table(name = "profiles")
@Entity
public class Profile {
    @Id
    @Column(name="user_id")
    @Getter
    @Setter
    private UUID userId;

    @Getter
    @Setter
    @Column(unique = true)
    private String email;

    @Getter
    @OneToMany(mappedBy = "profile", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Tasks> tasks = new ArrayList<>();

    @Getter
    @Setter
    @OneToOne(mappedBy = "profile", cascade = CascadeType.ALL, orphanRemoval = true)
    private Store store;

    @Getter
    @OneToMany(mappedBy = "profile", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Mission> missions = new ArrayList<>();

    @Getter
    @Setter
    private String name;
    @Getter
    @Setter
    private String avatarUrl;
    @Getter
    @Setter
    @Column(name = "level", columnDefinition = "INT DEFAULT 1")
    private int level = 1;
    @Getter
    @Setter
    @Column(name = "experience", columnDefinition = "INT DEFAULT 0")
    private int experience = 0;
    @Getter
    @Setter
    @Column(name = "gold", columnDefinition = "INT DEFAULT 0")
    private int gold = 0;

    @Getter
    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "attributes_id")
    private Attributes attributes;

    public Profile() {
        setAttributes(null);
    }

    public Profile(UUID userId, String email, String name, String avatarUrl, int level, int experience, int gold, Attributes attributes) {
        this.userId = userId;
        this.email = email;
        this.name = name;
        this.avatarUrl = avatarUrl;
        this.level = level;
        this.experience = experience;
        this.gold = gold;
        setAttributes(attributes);
    }

    public void setAttributes(Attributes attributes) {
        this.attributes = attributes == null ? new Attributes(this) : attributes;
        this.attributes.setProfile(this);
    }

    public ProfileDTO toDTO() {
        return new ProfileDTO(
                userId, email, name, avatarUrl, level, experience, gold, attributes.toDTO());
    }

    public ProfileResumeDTO toResumeDTO() {
        return new ProfileResumeDTO(userId, email);
    }
}
