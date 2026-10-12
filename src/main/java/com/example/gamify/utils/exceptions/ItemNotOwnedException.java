package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class ItemNotOwnedException extends GamifyException {
    public ItemNotOwnedException(String message) {
        super(HttpStatus.FORBIDDEN, "ITEM_NOT_OWNED", message);
    }
}
