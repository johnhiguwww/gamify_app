<?php

if (!function_exists('getUserActiveEffects')) {
    /**
     * Busca todos os efeitos de itens ativos para um usuário.
     *
     * @param PDO $pdo O objeto de conexão com o banco de dados.
     * @param int $userId O ID do usuário.
     * @return array Uma lista de efeitos ativos.
     */
    function getUserActiveEffects(PDO $pdo, int $userId): array {
        $effectsStmt = $pdo->prepare(
            "SELECT i.effect, i.xp_boost, ue.expires_at
             FROM user_effects ue
             JOIN items i ON ue.item_id = i.id
             WHERE ue.user_id = ? AND ue.expires_at > DATETIME('now')"
        );
        $effectsStmt->execute([$userId]);
        return $effectsStmt->fetchAll(PDO::FETCH_ASSOC);
    }
}

// Futuramente, outras funções utilitárias podem ser adicionadas aqui.
