package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class ItemPurchasedException extends GamifyException {
    public ItemPurchasedException(String message) {
        super(HttpStatus.CONFLICT, "ITEM_ALREADY_PURCHASED", message);
    }
}
