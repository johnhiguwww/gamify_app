<?php
require_once 'init.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$userId = $_SESSION['user_id'];

// Busca missões que o usuário JÁ ACEITOU e que estão em progresso
$stmtInProgress = $pdo->prepare(
    "SELECT m.* FROM missions m
     JOIN user_missions um ON m.id = um.mission_id
     WHERE um.user_id = ?"
);
$stmtInProgress->execute([$userId]);
$inProgressMissions = $stmtInProgress->fetchAll(PDO::FETCH_ASSOC);

// Busca missões que o usuário AINDA NÃO ACEITOU
$stmtAvailable = $pdo->prepare(
    "SELECT m.* FROM missions m
     LEFT JOIN user_missions um ON m.id = um.mission_id AND um.user_id = ?
     WHERE um.mission_id IS NULL"
);
$stmtAvailable->execute([$userId]);
$availableMissions = $stmtAvailable->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Missões - GamifyOS</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .missions-page-container {
            max-width: 900px;
            margin: 24px auto;
        }
        .widget-card { margin-bottom: 24px; }
        .mission-item {
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
        }
        .mission-item:last-child { border-bottom: none; }
        .mission-item h4 { margin: 0 0 5px; }
        .mission-item p { margin: 0; font-size: 0.9rem; color: var(--secondary-text-color); }
        .no-missions { text-align: center; padding: 20px; color: var(--secondary-text-color); }
    </style>
</head>
<body>
    <div class="missions-page-container">
        <!-- Missões em Progresso -->
        <div class="widget-card">
            <div class="widget-header"><h3>Missões em Andamento</h3></div>
            <div class="missions-list">
                <?php if (empty($inProgressMissions)): ?>
                    <p class="no-missions">Você não possui missões em andamento.</p>
                <?php else: ?>
                    <?php foreach ($inProgressMissions as $mission): ?>
                        <div class="mission-item">
                            <h4><?= htmlspecialchars($mission['title']); ?></h4>
                            <p><?= htmlspecialchars($mission['description']); ?></p>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <!-- Missões Disponíveis -->
        <div class="widget-card">
            <div class="widget-header"><h3>Missões Disponíveis</h3></div>
             <div class="missions-list">
                <?php if (empty($availableMissions)): ?>
                    <p class="no-missions">Não há novas missões disponíveis no momento.</p>
                <?php else: ?>
                    <form action="process_extra_mission.php" method="POST">
                        <?php foreach ($availableMissions as $mission): ?>
                            <label class="mission-item" style="display: flex; align-items: center; gap: 15px;">
                                <input type="radio" name="mission_id" value="<?= $mission['id']; ?>" required>
                                <div>
                                    <h4><?= htmlspecialchars($mission['title']); ?></h4>
                                    <p><?= htmlspecialchars($mission['description']); ?></p>
                                </div>
                            </label>
                        <?php endforeach; ?>
                        <div style="padding: 15px; text-align: right;">
                             <button type="submit" class="action-button" style="width: auto; padding: 10px 20px;">Aceitar Missão</button>
                        </div>
                    </form>
                <?php endif; ?>
            </div>
        </div>
         <div style="text-align: center; margin-top: 20px;">
            <a href="dashboard.php" style="color: var(--secondary-text-color);">Voltar ao Dashboard</a>
        </div>
    </div>
</body>
</html>
