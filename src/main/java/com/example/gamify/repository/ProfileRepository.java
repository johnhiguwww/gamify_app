package com.example.gamify.repository;

import com.example.gamify.models.entities.Profile;
import org.jspecify.annotations.NullMarked;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {
    public Optional<Profile> findByUserId(UUID userId);
    public Optional<Profile> findByEmail(String email);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Profile p SET p.gold = p.gold - :value " +
            "WHERE p.userId = :userId AND p.gold >= :value")
    int deductGoldIfSufficient(@Param("userId") UUID userId, @Param("value") int value);
}
