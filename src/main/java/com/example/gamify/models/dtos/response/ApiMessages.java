package com.example.gamify.models.dtos.response;

public final class ApiMessages {
    public static final String MISSION_COMPLETED = "Missão concluída com sucesso.";
    public static final String MISSION_DELETED = "Missão removida com sucesso.";
    public static final String TASK_DELETED = "Tarefa removida com sucesso.";
    public static final String PROFILE_UPDATED = "Perfil atualizado com sucesso.";
    public static final String ITEM_DELETED = "Item removido da loja com sucesso.";
    public static final String VALIDATION_ERROR = "Os dados enviados são inválidos.";
    public static final String MALFORMED_BODY = "O corpo da requisição está malformado ou incompleto.";
    public static final String INVALID_PARAMETER = "Um parâmetro da requisição é inválido.";
    public static final String MISSING_PARAMETER = "Um parâmetro obrigatório não foi informado.";
    public static final String INTERNAL_ERROR = "Ocorreu um erro interno. Tente novamente mais tarde.";

    private ApiMessages() {
    }
}
