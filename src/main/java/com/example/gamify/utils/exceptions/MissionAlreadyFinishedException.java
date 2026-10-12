package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class MissionAlreadyFinishedException extends GamifyException {
    public MissionAlreadyFinishedException(String message) {
        super(HttpStatus.CONFLICT, "MISSION_ALREADY_FINISHED", message);
    }
}
