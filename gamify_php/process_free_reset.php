<?php
require_once 'init.php';
require_once 'classes/AttributeManager.php';

// 1. Verificação de Segurança e Inputs
if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['task_id'])) {
    $_SESSION['message'] = ['type' => 'danger', 'text' => 'Requisição inválida.'];
    header("Location: dashboard.php");
    exit;
}

$userId = $_SESSION['user_id'];
$taskId = (int)$_POST['task_id'];
$today = date("Y-m-d");

$pdo->beginTransaction();

try {
    $attributeManager = new AttributeManager($pdo, $userId);

    // 2. Verificar se o usuário pode usar o reset gratuito
    if (!$attributeManager->canUseFreeReset()) {
        throw new Exception("Você não tem direito ao reset gratuito hoje ou não possui pontos de Autoconsciência suficientes.");
    }

    // 3. Deletar a conclusão da tarefa mais recente de hoje
    // Esta query é segura, pois deleta apenas o registro do próprio usuário e da tarefa específica.
    $stmt = $pdo->prepare(
        "DELETE FROM user_tasks WHERE id = (
            SELECT id FROM user_tasks
            WHERE user_id = :user_id AND task_id = :task_id AND DATE(completed_at) = :today
            ORDER BY completed_at DESC LIMIT 1
        )"
    );
    $stmt->execute([
        ':user_id' => $userId,
        ':task_id' => $taskId,
        ':today'   => $today
    ]);

    // Verifica se alguma linha foi de fato deletada
    if ($stmt->rowCount() == 0) {
        throw new Exception("Nenhuma conclusão para esta tarefa hoje foi encontrada para resetar.");
    }

    // 4. Registrar o uso do reset para evitar múltiplos usos no mesmo dia
    $attributeManager->recordFreeResetUsage();

    $pdo->commit();

    $_SESSION['message'] = ['type' => 'success', 'text' => 'Tarefa resetada com sucesso usando sua Autoconsciência!'];

} catch (Exception $e) {
    $pdo->rollBack();
    $_SESSION['message'] = ['type' => 'danger', 'text' => $e->getMessage()];
}

header("Location: dashboard.php");
exit;
