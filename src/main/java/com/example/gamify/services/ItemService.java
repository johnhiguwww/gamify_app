package com.example.gamify.services;

import com.example.gamify.models.dtos.input.ItemInputDTO;
import com.example.gamify.models.dtos.output.ItemOutputDTO;
import com.example.gamify.models.entities.Item;
import com.example.gamify.repository.ItemRepository;
import com.example.gamify.utils.exceptions.ItemNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ItemService {
    private final ItemRepository itemRepository;

    @Transactional
    public Item createNewItem(@NonNull ItemInputDTO itemInputDTO) {
        log.info("Criando item avulso '{}'", itemInputDTO.name());
        Item item = new Item(itemInputDTO.name(), itemInputDTO.value());
        Item saved = itemRepository.save(item);
        log.info("Item avulso {} criado", saved.getId());
        return saved;
    }

    public ItemOutputDTO getItemById(UUID itemId) {
        log.info("Consultando item {}", itemId);
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> {
                    log.warn("Item {} não encontrado", itemId);
                    return new ItemNotFoundException("Item não encontrado com id: " + itemId);
                });
        return item.toOutputDTO();
    }
}

