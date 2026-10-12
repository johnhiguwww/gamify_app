package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class StoreNotFoundException extends GamifyException {
    public StoreNotFoundException(String message) {
        super(HttpStatus.NOT_FOUND, "STORE_NOT_FOUND", message);
    }
}
