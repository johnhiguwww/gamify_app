<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once "init.php";
require_once "classes/User.php";
require_once "utils.php";
require_once "classes/AttributeManager.php";
require_once "classes/EngagementManager.php"; // Incluído

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['task_id'])) {
    $taskId = (int)$_POST['task_id'];
    $userId = $_SESSION['user_id'];

    $response = [
        'success' => false,
        'message' => 'Ocorreu um erro.'
    ];

    $stmt = $pdo->prepare("SELECT * FROM tasks WHERE id = ?");
    $stmt->execute([$taskId]);
    $task = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($task) {
        $pdo->beginTransaction();
        try {
            $baseXp = (int)$task['xp_reward'];
            $goldReward = (int)$task['gold_reward'];
            $attributeName = $task['attribute_id'];

            // 1. Calcular bônus de atributo (Inteligência/Força)
            $attributeManager = new AttributeManager($pdo, $userId);
            $xpAfterAttributeBonus = $attributeManager->calculateXpWithBonus($baseXp, $attributeName);
            
            // 2. Buscar e aplicar bônus de itens (efeitos ativos)
            $activeEffects = getUserActiveEffects($pdo, $userId);
            $itemXpMultiplier = 1.0;
            if ($activeEffects) {
                // ... (lógica de multiplicadores de item)
            }
            $finalXpReward = (int)round($xpAfterAttributeBonus * $itemXpMultiplier);

            // 3. Salvar progresso e recompensas
            $stmt = $pdo->prepare("INSERT INTO user_tasks (user_id, task_id) VALUES (?, ?)");
            $stmt->execute([$userId, $taskId]);

            $user = new User($pdo);
            $result = $user->addXpAndGold($userId, $finalXpReward, $goldReward, $attributeName);

            // 4. PROCESSAR ENGAJAMENTO (Streak, Conquistas, Histórico)
            $engagementManager = new EngagementManager($pdo, $userId);
            $engagementManager->processTaskCompletion($finalXpReward);

            $pdo->commit();

            $response = [
                'success' => true,
                'xp_gained' => $finalXpReward,
                'gold_gained' => $goldReward,
                'attribute' => $attributeName,
                'level_up' => $result['level_up']
            ];
        } catch (Exception $e) {
            $pdo->rollBack();
            $response = ['success' => false, 'message' => 'Erro no processamento: ' . $e->getMessage()];
        }
    }

    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
} else {
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'message' => 'Requisição inválida.']);
    exit();
}
