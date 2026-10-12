package com.example.gamify.config;

import com.example.gamify.models.dtos.response.ApiErrorResponse;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.utils.exceptions.InsufficientGoldException;
import com.example.gamify.utils.exceptions.ItemNotOwnedException;
import com.example.gamify.utils.exceptions.MissionNotFoundException;
import com.example.gamify.utils.exceptions.ProfileNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class GlobalExceptionHandlerTest {
    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();
    private HttpServletRequest request;

    @BeforeEach
    void setUp() {
        request = mock(HttpServletRequest.class);
        when(request.getRequestURI()).thenReturn("/missions/complete");
    }

    @Test
    void mapsDomainExceptionToPersonalizedError() {
        ResponseEntity<ApiErrorResponse> response = handler.handleGamify(
                new MissionNotFoundException("Missão não encontrada com id: 1"),
                request
        );

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("MISSION_NOT_FOUND", response.getBody().code());
        assertEquals("Missão não encontrada com id: 1", response.getBody().message());
        assertEquals("/missions/complete", response.getBody().path());
        assertEquals(404, response.getBody().status());
    }

    @Test
    void mapsForbiddenAndConflictCodes() {
        ResponseEntity<ApiErrorResponse> forbidden = handler.handleGamify(
                new ItemNotOwnedException("Item não pertence ao perfil"),
                request
        );
        ResponseEntity<ApiErrorResponse> conflict = handler.handleGamify(
                new InsufficientGoldException("Ouro insuficiente: 1 < 10"),
                request
        );

        assertEquals(HttpStatus.FORBIDDEN, forbidden.getStatusCode());
        assertEquals("ITEM_NOT_OWNED", forbidden.getBody().code());
        assertEquals(HttpStatus.CONFLICT, conflict.getStatusCode());
        assertEquals("INSUFFICIENT_GOLD", conflict.getBody().code());
    }

    @Test
    void hidesUnexpectedFailuresBehindGenericMessage() {
        ResponseEntity<ApiErrorResponse> response = handler.handleUnexpected(
                new IllegalStateException("sql detail"),
                request
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertEquals("INTERNAL_ERROR", response.getBody().code());
        assertEquals(ApiMessages.INTERNAL_ERROR, response.getBody().message());
        assertFalse(response.getBody().message().contains("sql"));
    }

    @Test
    void returnsFieldViolationsForInvalidBody() throws NoSuchMethodException {
        BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(new Object(), "mission");
        bindingResult.addError(new FieldError("mission", "title", "O título da missão é obrigatório"));
        MethodParameter parameter = new MethodParameter(Sample.class.getDeclaredMethod("accept", String.class), 0);
        MethodArgumentNotValidException exception = new MethodArgumentNotValidException(parameter, bindingResult);

        ResponseEntity<ApiErrorResponse> response = handler.handleInvalidBody(exception, request);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals("VALIDATION_ERROR", response.getBody().code());
        assertEquals(ApiMessages.VALIDATION_ERROR, response.getBody().message());
        assertEquals("title", response.getBody().violations().getFirst().field());
        assertEquals("O título da missão é obrigatório", response.getBody().violations().getFirst().message());
    }

    @Test
    void profileNotFoundKeepsCallerMessage() {
        ResponseEntity<ApiErrorResponse> response = handler.handleGamify(
                new ProfileNotFoundException("Não há perfil para o usuário com UUID: abc"),
                request
        );

        assertEquals("PROFILE_NOT_FOUND", response.getBody().code());
        assertEquals("Não há perfil para o usuário com UUID: abc", response.getBody().message());
    }

    private static class Sample {
        @SuppressWarnings("unused")
        void accept(String value) {
        }
    }
}
