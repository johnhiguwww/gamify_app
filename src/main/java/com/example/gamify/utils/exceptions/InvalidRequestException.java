package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class InvalidRequestException extends GamifyException {
    public InvalidRequestException(String message) {
        super(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", message);
    }
}
