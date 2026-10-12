package com.example.gamify.utils.exceptions;

import org.springframework.http.HttpStatus;

public class TaskNotFound extends GamifyException {
    public TaskNotFound(String message) {
        super(HttpStatus.NOT_FOUND, "TASK_NOT_FOUND", message);
    }
}
