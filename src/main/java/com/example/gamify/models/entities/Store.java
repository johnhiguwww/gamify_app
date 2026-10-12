package com.example.gamify.models.entities;

import com.example.gamify.models.dtos.output.StoreOutputDTO;
import jakarta.persistence.*;
import lombok.Getter;
import org.hibernate.annotations.UuidGenerator;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
public class Store {
    @UuidGenerator
    @Id
    @Getter
    private UUID id;

    @Getter
    @OneToOne
    private Profile profile;

    @Getter
    @OneToMany(mappedBy = "store", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Item> items;

    public Store() {
    }

    public Store(Profile profile, List<Item> items) {
        this.profile = profile;
        this.items = items;
    }

    public void addItem(Item item) {
        if (items == null) {
            items = new ArrayList<>();
        }
        items.add(item);
        item.setStore(this);
    }

    public void removeItem(Item item) {
        if (items != null) {
            items.remove(item);
            item.setStore(null);
        }
    }

    public StoreOutputDTO toOutputDTO(){
        List<Item> safeItems = items == null ? List.of() : items;
        return new StoreOutputDTO(
                id,
                profile.getUserId(),
                safeItems.stream().map(Item::toOutputDTO).toList()
        );
    }
}
