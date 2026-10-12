package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class InsufficientGoldException extends GamifyException {
    public InsufficientGoldException(String message) {
        super(HttpStatus.CONFLICT, "INSUFFICIENT_GOLD", message);
    }
}
