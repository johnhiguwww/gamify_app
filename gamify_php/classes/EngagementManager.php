<?php

class EngagementManager {
    private PDO $pdo;
    private int $userId;
    private array $userData;

    public function __construct(PDO $pdo, int $userId) {
        $this->pdo = $pdo;
        $this->userId = $userId;
        $this->loadUserData();
    }

    /**
     * Carrega os dados essenciais do usuário para evitar consultas repetidas.
     */
    private function loadUserData(): void {
        $stmt = $this->pdo->prepare(
            "SELECT id, global_xp, level, streak_days, last_activity_date FROM users WHERE id = ?"
        );
        $stmt->execute([$this->userId]);
        $this->userData = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Método principal para processar eventos após a conclusão de uma tarefa.
     * @param int $xpGained XP ganho na tarefa.
     */
    public function processTaskCompletion(int $xpGained): void {
        $this->updateUserStreak();
        $this->logWeeklyProgress($xpGained);
        $this->checkAndAwardAchievements();
    }

    /**
     * Atualiza a sequência (streak) de dias ativos do usuário.
     */
    private function updateUserStreak(): void {
        $today = date('Y-m-d');
        $lastActivity = $this->userData['last_activity_date'];

        // Se a última atividade foi hoje, não faz nada.
        if ($today === $lastActivity) {
            return;
        }

        $currentStreak = (int)$this->userData['streak_days'];
        $yesterday = date('Y-m-d', strtotime('-1 day'));

        if ($lastActivity === $yesterday) {
            // Continua o streak
            $newStreak = $currentStreak + 1;
        } else {
            // Quebrou o streak ou é o primeiro dia
            $newStreak = 1;
        }

        $stmt = $this->pdo->prepare(
            "UPDATE users SET streak_days = ?, last_activity_date = ? WHERE id = ?"
        );
        $stmt->execute([$newStreak, $today, $this->userId]);
        
        // Atualiza os dados locais para a verificação de conquistas no mesmo ciclo
        $this->userData['streak_days'] = $newStreak;

        $this->addNotification("🔥 Sequência de {$newStreak} dias!", 'streak');
    }

    /**
     * Registra o progresso da semana (XP e tarefas).
     * @param int $xpGained XP ganho na tarefa.
     */
    private function logWeeklyProgress(int $xpGained): void {
        $year = date('Y');
        $weekNumber = date('W');

        $stmt = $this->pdo->prepare(
            "INSERT INTO weekly_history (user_id, year, week_number, xp_gained, tasks_completed)
             VALUES (?, ?, ?, ?, 1)
             ON CONFLICT(user_id, year, week_number) DO UPDATE SET
             xp_gained = xp_gained + excluded.xp_gained,
             tasks_completed = tasks_completed + 1"
        );
        $stmt->execute([$this->userId, $year, $weekNumber, $xpGained]);
    }

    /**
     * Verifica todas as conquistas possíveis e concede se os critérios forem atendidos.
     */
    private function checkAndAwardAchievements(): void {
        $this->checkStreakAchievements();
        $this->checkLevelAchievements();
        $this->checkTaskCompletionAchievements();
        // Futuras verificações de conquistas podem ser adicionadas aqui.
    }
    
    private function checkStreakAchievements(): void {
        if ($this->userData['streak_days'] >= 7) {
            $this->awardAchievement('STREAK_7_DAYS');
        }
    }
    
    private function checkLevelAchievements(): void {
        if ($this->userData['level'] >= 5) {
            $this->awardAchievement('REACH_LEVEL_5');
        }
    }

    private function checkTaskCompletionAchievements(): void {
        $stmt = $this->pdo->prepare("SELECT COUNT(id) FROM user_tasks WHERE user_id = ?");
        $stmt->execute([$this->userId]);
        $totalTasks = $stmt->fetchColumn();

        if ($totalTasks >= 50) {
            $this->awardAchievement('COMPLETE_50_TASKS');
        }
    }

    /**
     * Concede uma conquista a um usuário, garantindo que não seja duplicada.
     * @param string $achievementKey A chave única da conquista.
     */
    private function awardAchievement(string $achievementKey): void {
        $this->pdo->beginTransaction();
        try {
            // 1. Pega os detalhes da conquista e verifica se ela já foi concedida (com lock)
            $stmt = $this->pdo->prepare(
                "SELECT a.id, a.name, a.reward_xp, a.reward_gold
                 FROM achievements a
                 LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = ?
                 WHERE a.achievement_key = ? AND ua.id IS NULL
                 LIMIT 1 FOR UPDATE"
            );
            $stmt->execute([$this->userId, $achievementKey]);
            $achievement = $stmt->fetch(PDO::FETCH_ASSOC);

            // 2. Se a busca não retornou nada, é porque a conquista não existe ou já foi ganha.
            if (!$achievement) {
                $this->pdo->rollBack();
                return;
            }

            // 3. Insere o registro na tabela de conquistas do usuário
            $stmt = $this->pdo->prepare(
                "INSERT INTO user_achievements (user_id, achievement_id, unlocked_at) VALUES (?, ?, ?)"
            );
            $stmt->execute([$this->userId, $achievement['id'], date('Y-m-d H:i:s')]);

            // 4. Aplica as recompensas
            if ($achievement['reward_xp'] > 0 || $achievement['reward_gold'] > 0) {
                $stmt = $this->pdo->prepare(
                    "UPDATE users SET global_xp = global_xp + ?, gold = gold + ? WHERE id = ?"
                );
                $stmt->execute([
                    $achievement['reward_xp'],
                    $achievement['reward_gold'],
                    $this->userId
                ]);
            }
            
            $this->pdo->commit();

            $this->addNotification("🏅 Conquista: {$achievement['name']}!", 'achievement');

        } catch (Exception $e) {
            $this->pdo->rollBack();
            // Logar o erro em um cenário real, mas não quebrar a aplicação
        }
    }

    /**
     * Adiciona uma notificação de feedback à sessão do usuário.
     * @param string $text O texto da notificação.
     * @param string $type Um tipo para estilização (ex: 'streak', 'achievement').
     */
    private function addNotification(string $text, string $type): void {
        if (!isset($_SESSION['engagement_notifications'])) {
            $_SESSION['engagement_notifications'] = [];
        }
        $_SESSION['engagement_notifications'][] = ['text' => $text, 'type' => $type];
    }
}
