package com.example.gamify.repository;

import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Tasks;
import org.jspecify.annotations.NullMarked;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.scheduling.config.Task;

import java.util.Optional;
import java.util.UUID;

public interface TasksRepository extends JpaRepository<Tasks, UUID> {
    @NullMarked
    public Optional<Tasks> findById(UUID id);

    public Optional<Tasks> findByProfile(Profile profile);
}
