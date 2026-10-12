package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class TaskAlreadyCompleted extends GamifyException {
    public TaskAlreadyCompleted(String message) {
        super(HttpStatus.CONFLICT, "TASK_ALREADY_COMPLETED", message);
    }
}
