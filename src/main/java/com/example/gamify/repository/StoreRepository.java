package com.example.gamify.repository;

import com.example.gamify.models.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface StoreRepository extends JpaRepository<Store, UUID> {
    Optional<Store> findById(UUID id);
    Optional<Store> findByProfile_UserId(UUID profile_UserId);
}
