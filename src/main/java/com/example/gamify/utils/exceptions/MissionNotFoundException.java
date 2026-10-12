package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class MissionNotFoundException extends GamifyException {
    public MissionNotFoundException(String message) {
        super(HttpStatus.NOT_FOUND, "MISSION_NOT_FOUND", message);
    }
}
