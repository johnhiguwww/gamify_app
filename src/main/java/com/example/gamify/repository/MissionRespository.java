package com.example.gamify.repository;

import com.example.gamify.models.entities.Mission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MissionRespository extends JpaRepository<Mission, UUID> {
}
