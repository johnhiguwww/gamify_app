<?php
require_once "init.php";

//# Verifica login
if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mission_id'])) {
    $missionId = intval($_POST['mission_id']);
    $userId = $_SESSION['user_id'];

    // Verifica se já foi concluída
    $check = $pdo->prepare("SELECT 1 FROM user_missions WHERE user_id = ? AND mission_id = ?");
    $check->execute([$userId, $missionId]);

    if (!$check->fetch()) {
        // Pega recompensa
        $stmt = $pdo->prepare("SELECT xp_reward FROM missions WHERE id = ?");
        $stmt->execute([$missionId]);
        $mission = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($mission) {
            $xpReward = $mission['xp_reward'];

            // Registra missão concluída
            $insert = $pdo->prepare("INSERT INTO user_missions (user_id, mission_id) VALUES (?, ?)");
            $insert->execute([$userId, $missionId]);

            // Dá XP ao usuário
            $user = new User($pdo);
            $user->addXP($userId, $xpReward);
        }
    }
}

header("Location: dashboard.php");
exit();
