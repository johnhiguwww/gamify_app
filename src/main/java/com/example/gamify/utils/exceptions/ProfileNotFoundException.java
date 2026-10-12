package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class ProfileNotFoundException extends GamifyException {
    public ProfileNotFoundException(String message) {
        super(HttpStatus.NOT_FOUND, "PROFILE_NOT_FOUND", message);
    }
}
