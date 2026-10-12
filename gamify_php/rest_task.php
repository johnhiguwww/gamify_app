<?php
require_once 'init.php';

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
    // 2. Encontrar o item "Recomeço Consciente"
    $stmt = $pdo->prepare("SELECT id FROM items WHERE effect = 'reset_task' LIMIT 1");
    $stmt->execute();
    $resetItemId = $stmt->fetchColumn();

    if (!$resetItemId) {
        throw new Exception("O item de reset não foi encontrado no sistema.");
    }

    // 3. Verificar se o usuário possui o item
    $stmt = $pdo->prepare("SELECT quantity FROM user_items WHERE user_id = ? AND item_id = ? FOR UPDATE");
    $stmt->execute([$userId, $resetItemId]);
    $quantity = $stmt->fetchColumn();

    if (!$quantity || $quantity <= 0) {
        throw new Exception("Você não possui o item 'Recomeço Consciente' para resetar a tarefa.");
    }

    // 4. Deletar a conclusão da tarefa mais recente de hoje
    $stmt = $pdo->prepare(
        "DELETE FROM user_tasks 
         WHERE id = (
            SELECT id FROM user_tasks 
            WHERE user_id = ? AND task_id = ? AND DATE(completed_at) = ? 
            ORDER BY completed_at DESC LIMIT 1
         )"
    );
    $stmt->execute([$userId, $taskId, $today]);

    if ($stmt->rowCount() == 0) {
        throw new Exception("Nenhuma conclusão para esta tarefa hoje foi encontrada para resetar.");
    }

    // 5. Decrementar a quantidade do item
    $stmt = $pdo->prepare("UPDATE user_items SET quantity = quantity - 1 WHERE user_id = ? AND item_id = ?");
    $stmt->execute([$userId, $resetItemId]);

    // Opcional: remover o item se a quantidade for zero
    $stmt = $pdo->prepare("DELETE FROM user_items WHERE user_id = ? AND item_id = ? AND quantity <= 0");
    $stmt->execute([$userId, $resetItemId]);

    $pdo->commit();

    $_SESSION['message'] = ['type' => 'success', 'text' => 'Tarefa resetada com sucesso!'];

} catch (Exception $e) {
    $pdo->rollBack();
    $_SESSION['message'] = ['type' => 'danger', 'text' => $e->getMessage()];
}

header("Location: dashboard.php");
exit;
