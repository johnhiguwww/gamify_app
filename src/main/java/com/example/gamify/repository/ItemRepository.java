package com.example.gamify.repository;

import com.example.gamify.models.entities.Item;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ItemRepository extends JpaRepository<Item, UUID> {
    Optional<Item> findById(UUID id);
}

