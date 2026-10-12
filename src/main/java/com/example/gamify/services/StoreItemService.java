package com.example.gamify.services;

import com.example.gamify.models.dtos.input.ItemInputDTO;
import com.example.gamify.models.dtos.output.ItemOutputDTO;
import com.example.gamify.models.entities.Item;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Store;
import com.example.gamify.repository.ItemRepository;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.StoreRepository;
import com.example.gamify.utils.exceptions.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.resilience.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class StoreItemService {
    private final StoreRepository storeRepository;
    private final ItemRepository itemRepository;
    private final ProfileRepository profileRepository;

    private Store getUserStore(UUID profileId) throws StoreNotFoundException {
        Profile profile = profileRepository.findByUserId(profileId)
                .orElseThrow(() -> {
                    log.warn("Perfil {} não encontrado ao acessar a loja", profileId);
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + profileId);
                });
        if (profile.getStore() == null) {
            log.info("Criando uma loja para o usuário: {}", profile.getEmail());
            Store newStore = new Store(profile, new ArrayList<>());
            storeRepository.save(newStore);
            profile.setStore(newStore);
            profileRepository.save(profile);
        }
        return profile.getStore();
    }

    @Transactional
    public ItemOutputDTO addItemToStore(UUID profileId, ItemInputDTO dto)
            throws ProfileNotFoundException, StoreNotFoundException {
        log.info("Adicionando novo item à loja. ProfileId: {}, Nome: {}, Valor: {}", profileId, dto.name(), dto.value());

        Store store = getUserStore(profileId);

        Item newItem = new Item(dto.name(), dto.value());
        store.addItem(newItem);
        storeRepository.save(store);
        log.info("Item adicionado com sucesso. ItemId: {}, ProfileId: {}", newItem.getId(), profileId);
        return newItem.toOutputDTO();
    }

    @Transactional
    public ItemOutputDTO updateStoreItem(UUID profileId, UUID itemId, ItemInputDTO dto)
            throws ProfileNotFoundException, ItemNotFoundException, ItemNotOwnedException {
        log.info("Atualizando item da loja. ProfileId: {}, ItemId: {}, Novo Nome: {}", profileId, itemId, dto.name());

        Item item = getOwnedItem(profileId, itemId);
        item.setName(dto.name());
        item.setValue(dto.value());
        item.setUpdatedAt(LocalDateTime.now());
        itemRepository.save(item);
        log.info("Item atualizado com sucesso. ItemId: {}, ProfileId: {}", itemId, profileId);
        return item.toOutputDTO();
    }

    @Transactional
    public void deleteStoreItem(UUID profileId, UUID itemId)
            throws ProfileNotFoundException, ItemNotFoundException, ItemNotOwnedException, ItemPurchasedException {
        log.info("Removendo item da loja. ProfileId: {}, ItemId: {}", profileId, itemId);

        Item item = getOwnedItem(profileId, itemId);

        if (item.getPurchaseAt() != null) {
            log.warn("Tentativa de remover item já comprado. ItemId: {}, ProfileId: {}", itemId, profileId);
            throw new ItemPurchasedException("Não é possível remover um item que já foi comprado: " + itemId);
        }

        Store store = item.getStore();
        store.removeItem(item);
        storeRepository.save(store);
        itemRepository.delete(item);
        log.info("Item removido com sucesso. ItemId: {}, ProfileId: {}", itemId, profileId);
    }

    @Transactional
    @Retryable(value = OptimisticLockingFailureException.class, maxRetries = 3)
    public ItemOutputDTO purchaseStoreItem(UUID profileId, UUID itemId)
            throws ProfileNotFoundException, ItemNotFoundException, ItemNotOwnedException, InsufficientGoldException {
        log.info("Comprando item da loja. ProfileId: {}, ItemId: {}", profileId, itemId);

        Profile profile = profileRepository.findByUserId(profileId)
                .orElseThrow(() -> {
                    log.warn("Perfil não encontrado na compra. ProfileId: {}", profileId);
                    return new ProfileNotFoundException("Não há perfil para o usuário com UUID: " + profileId);
                });

        Item item = getOwnedItem(profileId, itemId);
        if (item.getPurchaseAt() != null) {
            log.warn("Tentativa de comprar item já adquirido. ItemId: {}, ProfileId: {}", itemId, profileId);
            throw new ItemPurchasedException("Não é possível comprar um item que já foi comprado: " + itemId);
        }

        int goldBefore = profile.getGold();
        int updated = profileRepository.deductGoldIfSufficient(profileId, item.getValue());
        if (updated == 0) {
            log.warn("Ouro insuficiente para compra. ProfileId: {}, OuroDisponível: {}, ValorItem: {}",
                    profileId, goldBefore, item.getValue());
            throw new InsufficientGoldException(
                    String.format("Ouro insuficiente: %d < %d", goldBefore, item.getValue())
            );
        }

        item.setPurchaseAt(LocalDateTime.now());
        itemRepository.save(item);
        log.info("Item comprado com sucesso. ItemId: {}, ProfileId: {}, OuroRestante: {}",
                itemId, profileId, goldBefore - item.getValue());
        return item.toOutputDTO();
    }

    private Item getOwnedItem(UUID profileId, UUID itemId)
            throws ProfileNotFoundException, ItemNotFoundException, ItemNotOwnedException {
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> {
                    log.warn("Item não encontrado. ItemId: {}", itemId);
                    return new ItemNotFoundException("Item não encontrado com id: " + itemId);
                });

        if (item.getStore() == null || item.getStore().getProfile() == null
                || !item.getStore().getProfile().getUserId().equals(profileId)) {
            log.warn("Item não pertence ao perfil. ItemId: {}, ProfileId: {}", itemId, profileId);
            throw new ItemNotOwnedException(
                    String.format("Item %s não pertence ao perfil %s", itemId, profileId)
            );
        }

        return item;
    }
}
