package com.example.gamify.models.entities;

import com.example.gamify.models.dtos.output.ItemOutputDTO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
public class Item {
    @UuidGenerator
    @Id
    @Getter
    private UUID id;

    @Getter
    @Setter
    @Column(nullable = false)
    private String name;

    @Getter
    @Setter
    @Column(nullable = false)
    private int value;

    @Getter
    @Setter
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "store_id")
    private Store store;

    @Getter
    @Column(nullable = false, updatable = false, name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Setter
    @Getter
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @Getter
    @Setter
    @Column(nullable = true, name = "purchase_at")
    private LocalDateTime purchaseAt;

    public  Item() {
    }

    public Item(String name, int value) {
        this.name = name;
        this.value = value;
    }

    public ItemOutputDTO toOutputDTO() {
        return new ItemOutputDTO(id, name, value, createdAt, updatedAt, purchaseAt);
    }
}
