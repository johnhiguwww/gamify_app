package com.example.gamify.config;

import com.example.gamify.models.dtos.response.ApiErrorResponse;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.FieldViolation;
import com.example.gamify.utils.exceptions.GamifyException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Slf4j
@Order(Ordered.HIGHEST_PRECEDENCE)
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(GamifyException.class)
    public ResponseEntity<ApiErrorResponse> handleGamify(GamifyException exception, HttpServletRequest request) {
        log.warn("Falha de negócio [{}] em {}: {}", exception.getCode(), request.getRequestURI(), exception.getMessage());
        return ResponseEntity.status(exception.getStatus())
                .body(ApiErrorResponse.of(exception, request.getRequestURI()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleInvalidBody(MethodArgumentNotValidException exception, HttpServletRequest request) {
        List<FieldViolation> violations = exception.getBindingResult().getFieldErrors().stream()
                .map(error -> new FieldViolation(error.getField(), error.getDefaultMessage()))
                .toList();
        log.warn("Validação rejeitada em {}: {}", request.getRequestURI(), violations);
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_ERROR",
                ApiMessages.VALIDATION_ERROR,
                request.getRequestURI(),
                violations
        ));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleConstraintViolation(ConstraintViolationException exception, HttpServletRequest request) {
        List<FieldViolation> violations = exception.getConstraintViolations().stream()
                .map(violation -> new FieldViolation(violation.getPropertyPath().toString(), violation.getMessage()))
                .toList();
        log.warn("Restrição violada em {}: {}", request.getRequestURI(), violations);
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_ERROR",
                ApiMessages.VALIDATION_ERROR,
                request.getRequestURI(),
                violations
        ));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiErrorResponse> handleUnreadableBody(HttpMessageNotReadableException exception, HttpServletRequest request) {
        log.warn("Corpo ilegível em {}: {}", request.getRequestURI(), exception.getMessage());
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "MALFORMED_BODY",
                ApiMessages.MALFORMED_BODY,
                request.getRequestURI(),
                List.of()
        ));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException exception, HttpServletRequest request) {
        String message = "O parâmetro '" + exception.getName() + "' possui um formato inválido.";
        log.warn("Parâmetro inválido em {}: {}", request.getRequestURI(), message);
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "INVALID_PARAMETER",
                message,
                request.getRequestURI(),
                List.of()
        ));
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiErrorResponse> handleMissingParameter(MissingServletRequestParameterException exception, HttpServletRequest request) {
        String message = "O parâmetro '" + exception.getParameterName() + "' é obrigatório.";
        log.warn("Parâmetro ausente em {}: {}", request.getRequestURI(), message);
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "MISSING_PARAMETER",
                message,
                request.getRequestURI(),
                List.of()
        ));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiErrorResponse> handleIllegalArgument(IllegalArgumentException exception, HttpServletRequest request) {
        String message = exception.getMessage() == null || exception.getMessage().isBlank()
                ? ApiMessages.INVALID_PARAMETER
                : exception.getMessage();
        log.warn("Argumento inválido em {}: {}", request.getRequestURI(), message);
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "INVALID_REQUEST",
                message,
                request.getRequestURI(),
                List.of()
        ));
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiErrorResponse> handleStatus(ResponseStatusException exception, HttpServletRequest request) {
        HttpStatus status = HttpStatus.valueOf(exception.getStatusCode().value());
        String message = exception.getReason() == null ? status.getReasonPhrase() : exception.getReason();
        log.warn("Status HTTP {} em {}: {}", status.value(), request.getRequestURI(), message);
        return ResponseEntity.status(status).body(ApiErrorResponse.of(
                status,
                "HTTP_" + status.value(),
                message,
                request.getRequestURI(),
                List.of()
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleUnexpected(Exception exception, HttpServletRequest request) {
        log.error("Erro interno em {}", request.getRequestURI(), exception);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiErrorResponse.of(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_ERROR",
                ApiMessages.INTERNAL_ERROR,
                request.getRequestURI(),
                List.of()
        ));
    }
}
