package com.example.gamify.services;

import com.example.gamify.models.entities.Item;
import com.example.gamify.models.entities.Profile;
import com.example.gamify.models.entities.Store;
import com.example.gamify.repository.ItemRepository;
import com.example.gamify.repository.ProfileRepository;
import com.example.gamify.repository.StoreRepository;
import com.example.gamify.utils.exceptions.InsufficientGoldException;
import com.example.gamify.utils.exceptions.ItemNotOwnedException;
import com.example.gamify.utils.exceptions.ItemPurchasedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StoreItemServiceTest {
    @Mock
    private StoreRepository storeRepository;
    @Mock
    private ItemRepository itemRepository;
    @Mock
    private ProfileRepository profileRepository;
    @InjectMocks
    private StoreItemService storeItemService;

    @Test
    void purchasesItemWhenGoldIsDeductedAtomically() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        Profile profile = profile(profileId, 40);
        Item item = itemOf(profile, 15);
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile));
        when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));
        when(profileRepository.deductGoldIfSufficient(profileId, 15)).thenReturn(1);
        when(itemRepository.save(item)).thenReturn(item);

        storeItemService.purchaseStoreItem(profileId, itemId);

        assertNotNull(item.getPurchaseAt());
        verify(profileRepository, never()).save(profile);
    }

    @Test
    void rejectsPurchaseWithoutEnoughGold() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        Profile profile = profile(profileId, 5);
        Item item = itemOf(profile, 15);
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile));
        when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));
        when(profileRepository.deductGoldIfSufficient(profileId, 15)).thenReturn(0);

        assertThrows(InsufficientGoldException.class, () -> storeItemService.purchaseStoreItem(profileId, itemId));
        verify(itemRepository, never()).save(item);
    }

    @Test
    void rejectsPurchaseOfAlreadyPurchasedItem() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        Profile profile = profile(profileId, 100);
        Item item = itemOf(profile, 15);
        item.setPurchaseAt(LocalDateTime.now());
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile));
        when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

        assertThrows(ItemPurchasedException.class, () -> storeItemService.purchaseStoreItem(profileId, itemId));
        verify(profileRepository, never()).deductGoldIfSufficient(profileId, 15);
    }

    @Test
    void rejectsDeleteOfPurchasedItem() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        Item item = itemOf(profile(profileId, 10), 15);
        item.setPurchaseAt(LocalDateTime.now());
        when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

        assertThrows(ItemPurchasedException.class, () -> storeItemService.deleteStoreItem(profileId, itemId));
        verify(itemRepository, never()).delete(item);
    }

    @Test
    void rejectsItemOwnedByAnotherProfile() {
        UUID profileId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        Item item = itemOf(profile(UUID.randomUUID(), 10), 15);
        when(profileRepository.findByUserId(profileId)).thenReturn(Optional.of(profile(profileId, 10)));
        when(itemRepository.findById(itemId)).thenReturn(Optional.of(item));

        assertThrows(ItemNotOwnedException.class, () -> storeItemService.purchaseStoreItem(profileId, itemId));
    }

    private Profile profile(UUID id, int gold) {
        Profile profile = new Profile();
        profile.setUserId(id);
        profile.setEmail(id + "@gamify.test");
        profile.setGold(gold);
        return profile;
    }

    private Item itemOf(Profile profile, int value) {
        Store store = new Store(profile, new ArrayList<>());
        Item item = new Item("Livro", value);
        store.addItem(item);
        return item;
    }
}
