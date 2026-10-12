package com.example.gamify.controllers;

import com.example.gamify.models.dtos.absolute.ProfileDTO;
import com.example.gamify.models.dtos.input.TaskCompleteInputDTO;
import com.example.gamify.models.dtos.input.TasksInputDTO;
import com.example.gamify.models.dtos.output.TasksOutPutDTO;
import com.example.gamify.models.dtos.response.ApiMessages;
import com.example.gamify.models.dtos.response.ApiSuccessResponse;
import com.example.gamify.services.TasksService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RequestMapping("/tasks")
@RequiredArgsConstructor
@RestController
@Tag(name = "Tasks", description = "Endpoints relacionados a tarefas")
@Validated
public class TasksController {
    private final TasksService tasksService;

    @PostMapping("/newtask")
    @Operation(summary = "Criar tarefa")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Tarefa criada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da tarefa inválidos"),
            @ApiResponse(responseCode = "404", description = "Perfil não encontrado")
    })
    public ResponseEntity<TasksOutPutDTO> createNewTask(@Valid @RequestBody TasksInputDTO taskInputDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tasksService.createTask(taskInputDTO));
    }

    @PostMapping("/complete")
    @Operation(summary = "Concluir tarefa")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tarefa concluída com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da tarefa inválidos"),
            @ApiResponse(responseCode = "404", description = "Tarefa não encontrada"),
            @ApiResponse(responseCode = "409", description = "Tarefa já concluída")
    })
    public ResponseEntity<ProfileDTO> completeTask(@Valid @RequestBody TaskCompleteInputDTO request) {
        return ResponseEntity.ok(tasksService.completedTask(request.taskId()));
    }

    @PutMapping("/update")
    @Operation(summary = "Atualizar tarefa")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tarefa atualizada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da tarefa inválidos"),
            @ApiResponse(responseCode = "404", description = "Tarefa não encontrada")
    })
    public ResponseEntity<TasksOutPutDTO> updateTask(@Valid @RequestBody TasksInputDTO taskInputDTO,
                                                     @RequestParam UUID taskId) {
        return ResponseEntity.ok(tasksService.updateTask(taskInputDTO, taskId));
    }

    @PutMapping({"/complete-cycle/{taskId}", "/completecicle/{taskId}"})
    @Operation(summary = "Concluir ciclo da tarefa")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Ciclo de tarefa concluído com sucesso"),
            @ApiResponse(responseCode = "404", description = "Tarefa não encontrada"),
            @ApiResponse(responseCode = "409", description = "Tarefa já concluída")
    })
    public ResponseEntity<TasksOutPutDTO> completeTaskCycle(@PathVariable UUID taskId) {
        return ResponseEntity.ok(tasksService.completeCycleTask(taskId));
    }

    @DeleteMapping("/{taskId}")
    @Operation(summary = "Remover tarefa")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tarefa removida com sucesso"),
            @ApiResponse(responseCode = "404", description = "Tarefa não encontrada")
    })
    public ResponseEntity<ApiSuccessResponse> deleteTask(@PathVariable UUID taskId) {
        tasksService.deleteTask(taskId);
        return ResponseEntity.ok(ApiSuccessResponse.of("TASK_DELETED", ApiMessages.TASK_DELETED));
    }
}
