package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class ItemNotFoundException extends GamifyException {
    public ItemNotFoundException(String message) {
        super(HttpStatus.NOT_FOUND, "ITEM_NOT_FOUND", message);
    }
}
