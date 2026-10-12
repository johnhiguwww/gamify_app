package com.example.gamify.services;

import com.example.gamify.models.dtos.input.ItemInputDTO;
import com.example.gamify.models.dtos.output.ItemOutputDTO;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import com.example.gamify.utils.exceptions.StoreNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class StoreService {
    private final StoreItemService storeItemService;

    public ItemOutputDTO addNewItem(ItemInputDTO itemInputDTO, UUID profileId)
            throws ProfileNotFoundException, StoreNotFoundException {
        log.info("Delegando inclusão de item '{}' para a loja do perfil {}", itemInputDTO.name(), profileId);
        return storeItemService.addItemToStore(profileId, itemInputDTO);
    }
}


