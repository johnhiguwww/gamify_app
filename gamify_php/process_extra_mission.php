<?php
require_once 'init.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['mission_id'])) {
    $_SESSION['message'] = ['type' => 'danger', 'text' => 'Requisição inválida.'];
    header("Location: dashboard.php");
    exit;
}

$userId = $_SESSION['user_id'];
$missionId = (int)$_POST['mission_id'];

$pdo->beginTransaction();

try {
    // Verifica se o usuário tem o item de missão extra
    $stmt = $pdo->prepare("SELECT i.id FROM items i JOIN user_items ui ON i.id = ui.item_id WHERE ui.user_id = ? AND i.effect = 'extra_mission' AND ui.quantity > 0");
    $stmt->execute([$userId]);
    if (!$stmt->fetch()) {
        throw new Exception("Você não possui o item necessário para adicionar uma missão extra.");
    }

    // Calcula o limite de missões
    $baseMissionLimit = (int)$pdo->query("SELECT COUNT(*) FROM missions")->fetchColumn();
    $missionLimit = $baseMissionLimit + 1; // +1 pelo item

    // Conta as missões atuais do usuário
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM user_missions WHERE user_id = ?");
    $stmt->execute([$userId]);
    $currentMissions = (int)$stmt->fetchColumn();

    if ($currentMissions >= $missionLimit) {
        throw new Exception("Você já atingiu seu limite de missões ativas.");
    }
    
    // Verifica se o usuário já tem essa missão
    $stmt = $pdo->prepare("SELECT 1 FROM user_missions WHERE user_id = ? AND mission_id = ?");
    $stmt->execute([$userId, $missionId]);
    if ($stmt->fetch()) {
        throw new Exception("Você já possui esta missão.");
    }

    // Adiciona a nova missão
    $stmt = $pdo->prepare("INSERT INTO user_missions (user_id, mission_id) VALUES (?, ?)");
    $stmt->execute([$userId, $missionId]);

    $pdo->commit();

    $_SESSION['message'] = ['type' => 'success', 'text' => 'Nova missão adicionada com sucesso!'];

} catch (Exception $e) {
    $pdo->rollBack();
    $_SESSION['message'] = ['type' => 'danger', 'text' => $e->getMessage()];
}

header("Location: dashboard.php");
exit;
