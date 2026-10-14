package com.example.gamify.utils.exceptions;

public class ProfileNotExists extends RuntimeException {
    public ProfileNotExists(String message) {
        super(message);
    }
}
