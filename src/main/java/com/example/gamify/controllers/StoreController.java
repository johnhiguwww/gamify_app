package com.example.gamify.controllers;

import com.example.gamify.models.dtos.input.ItemInputDTO;
import com.example.gamify.models.dtos.output.ItemOutputDTO;
import com.example.gamify.models.dtos.output.StoreOutputDTO;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.ApiSuccessResponse;
import com.example.gamify.services.ProfileQueryService;
import com.example.gamify.services.StoreItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RequiredArgsConstructor
@RestController
@RequestMapping("/profiles")
@Validated
@Tag(name = "Store", description = "Endpoints da loja e dos itens do perfil")
public class StoreController {
    private final ProfileQueryService profileQueryService;
    private final StoreItemService storeItemService;

    @GetMapping("/{uuid}/mystore")
    @Operation(summary = "Obter loja do perfil")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Loja obtida com sucesso"),
            @ApiResponse(responseCode = "404", description = "Perfil ou loja não encontrado")
    })
    public ResponseEntity<StoreOutputDTO> getMyStore(@PathVariable UUID uuid) {
        return ResponseEntity.ok(profileQueryService.getStoreByProfileId(uuid));
    }

    @PostMapping("/{uuid}/addItem")
    @Operation(summary = "Adicionar novo item à loja")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Item adicionado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados do item inválidos"),
            @ApiResponse(responseCode = "404", description = "Perfil ou loja não encontrado")
    })
    public ResponseEntity<ItemOutputDTO> addItem(@RequestBody @Valid ItemInputDTO itemInputDTO, @PathVariable UUID uuid) {
        return ResponseEntity.status(HttpStatus.CREATED).body(storeItemService.addItemToStore(uuid, itemInputDTO));
    }

    @PutMapping("/{profileId}/updateItem/{itemId}")
    @Operation(summary = "Atualizar item da loja")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Item atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados do item inválidos"),
            @ApiResponse(responseCode = "403", description = "Item não pertence ao perfil"),
            @ApiResponse(responseCode = "404", description = "Perfil ou item não encontrado")
    })
    public ResponseEntity<ItemOutputDTO> updateItem(@RequestBody @Valid ItemInputDTO itemInputDTO,
                                                    @PathVariable UUID profileId,
                                                    @PathVariable UUID itemId) {
        return ResponseEntity.ok(storeItemService.updateStoreItem(profileId, itemId, itemInputDTO));
    }

    @DeleteMapping("/{profileId}/deleteItem/{itemId}")
    @Operation(summary = "Remover item da loja")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Item removido com sucesso"),
            @ApiResponse(responseCode = "403", description = "Item não pertence ao perfil"),
            @ApiResponse(responseCode = "404", description = "Perfil ou item não encontrado"),
            @ApiResponse(responseCode = "409", description = "Item já foi comprado")
    })
    public ResponseEntity<ApiSuccessResponse> deleteItem(@PathVariable UUID profileId, @PathVariable UUID itemId) {
        storeItemService.deleteStoreItem(profileId, itemId);
        return ResponseEntity.ok(ApiSuccessResponse.of("ITEM_DELETED", ApiMessages.ITEM_DELETED));
    }

    @PutMapping("/{profileId}/purchaseItem/{itemId}")
    @Operation(summary = "Comprar item da loja")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Item comprado com sucesso"),
            @ApiResponse(responseCode = "403", description = "Item não pertence ao perfil"),
            @ApiResponse(responseCode = "404", description = "Perfil ou item não encontrado"),
            @ApiResponse(responseCode = "409", description = "Ouro insuficiente ou item já comprado")
    })
    public ResponseEntity<ItemOutputDTO> purchaseItem(@PathVariable UUID profileId, @PathVariable UUID itemId) {
        return ResponseEntity.ok(storeItemService.purchaseStoreItem(profileId, itemId));
    }
}
