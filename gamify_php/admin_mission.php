<?php
require_once 'init.php'; // Includes the database connection ($pdo)
require_once 'classes/User.php'; // Include the User class to handle XP

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

$userId = $_SESSION['user_id'];
$message = '';
$mission_to_edit = null;

// Handle form submissions for adding/editing missions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_mission'])) {
    $title = trim($_POST['title']);
    $xp_reward = filter_input(INPUT_POST, 'xp_reward', FILTER_VALIDATE_INT);
    $gold_reward = filter_input(INPUT_POST, 'gold_reward', FILTER_VALIDATE_INT);
    $image_url = filter_input(INPUT_POST, 'image_url', FILTER_VALIDATE_URL);
    $mission_id = filter_input(INPUT_POST, 'mission_id', FILTER_VALIDATE_INT);

    if ($title && $xp_reward !== false && $gold_reward !== false) {
        if ($mission_id) {
            $stmt = $pdo->prepare("UPDATE missions SET title = ?, xp_reward = ?, gold_reward = ?, image_url = ? WHERE id = ?");
            $stmt->execute([$title, $xp_reward, $gold_reward, $image_url, $mission_id]);
            $message = "Missão atualizada com sucesso!";
        } else {
            $stmt = $pdo->prepare("INSERT INTO missions (title, xp_reward, gold_reward, image_url) VALUES (?, ?, ?, ?)");
            $stmt->execute([$title, $xp_reward, $gold_reward, $image_url]);
            $message = "Missão adicionada com sucesso!";
        }
    } else {
        $message = "Por favor, preencha todos os campos corretamente.";
    }
}

// Handle mission completion from admin page
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['complete_mission'])) {
    $mission_id_to_complete = filter_input(INPUT_POST, 'mission_id_to_complete', FILTER_VALIDATE_INT);

    if ($mission_id_to_complete) {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM user_missions WHERE user_id = ? AND mission_id = ?");
        $stmt->execute([$userId, $mission_id_to_complete]);

        if ($stmt->fetchColumn() == 0) {
            $stmt = $pdo->prepare("SELECT xp_reward, gold_reward FROM missions WHERE id = ?");
            $stmt->execute([$mission_id_to_complete]);
            $mission_rewards = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($mission_rewards) {
                $stmt = $pdo->prepare("INSERT INTO user_missions (user_id, mission_id) VALUES (?, ?)");
                $stmt->execute([$userId, $mission_id_to_complete]);

                $user = new User($pdo);
                $user->addXpAndGold($userId, $mission_rewards['xp_reward'], $mission_rewards['gold_reward']);

                $message = "Missão concluída com sucesso!";
            } else {
                $message = "Missão não encontrada.";
            }
        } else {
            $message = "Esta missão já foi concluída.";
        }
    }
}


// Handle mission deletion
if (isset($_GET['delete_mission'])) {
    $mission_id_to_delete = filter_input(INPUT_GET, 'delete_mission', FILTER_VALIDATE_INT);
    if ($mission_id_to_delete) {
        $stmt = $pdo->prepare("DELETE FROM missions WHERE id = ?");
        $stmt->execute([$mission_id_to_delete]);
        $message = "Missão excluída com sucesso!";
    }
}

// Fetch mission for editing
if (isset($_GET['edit_mission'])) {
    $mission_id_to_edit = filter_input(INPUT_GET, 'edit_mission', FILTER_VALIDATE_INT);
    if ($mission_id_to_edit) {
        $stmt = $pdo->prepare("SELECT * FROM missions WHERE id = ?");
        $stmt->execute([$mission_id_to_edit]);
        $mission_to_edit = $stmt->fetch(PDO::FETCH_ASSOC);
    }
}

// Fetch all missions
$missions_stmt = $pdo->query("SELECT * FROM missions ORDER BY id DESC");
$missions_list = $missions_stmt->fetchAll(PDO::FETCH_ASSOC);

// Fetch completed missions for the user
$userMissionsStmt = $pdo->prepare("SELECT mission_id FROM user_missions WHERE user_id = ?");
$userMissionsStmt->execute([$userId]);
$completedMissions = $userMissionsStmt->fetchAll(PDO::FETCH_COLUMN);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Missões</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: var(--bg); }
        .admin-container { max-width: 1200px; margin: 24px auto; padding: 16px; }
        .admin-header { font-size: 1.5rem; font-weight: bold; margin-bottom: 1rem; }
        .admin-header a { color: var(--primary); text-decoration: none; }
        .admin-section { background: var(--card); border-radius: var(--radius); box-shadow: var(--shadow); padding: 20px; margin-bottom: 2rem; }
        .admin-section h2 { margin-top: 0; font-size: 1.2rem; border-bottom: 2px solid #eee; padding-bottom: 8px; }
        form div { margin-bottom: 1rem; }
        form label { display: block; margin-bottom: 5px; font-weight: bold; }
        form input[type="text"], form input[type="number"], form input[type="url"] { width: 100%; padding: 10px; box-sizing: border-box; border: 1px solid #ddd; border-radius: 8px; }
        form button { background: var(--primary); color: #fff; padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
        .mission-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-top: 1rem; }
        .mission-card { background: #f8f9fa; border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden; display: flex; flex-direction: column; }
        .mission-card img { width: 100%; height: 160px; object-fit: cover; }
        .mission-card-content { padding: 15px; flex-grow: 1; }
        .mission-card-content h3 { margin: 0 0 10px; font-size: 1.1rem; }
        .mission-card-rewards { display: flex; gap: 15px; margin-bottom: 15px; font-size: 0.9rem; }
        .mission-card-actions { padding: 10px 15px; border-top: 1px solid #eee; display: flex; align-items: center; gap: 10px; }
        .mission-card-actions a { color: var(--primary); text-decoration: none; }
        .mission-card-actions a.delete { color: #dc3545; }
        .mission-card-actions .complete-btn { background: var(--secondary); color: #fff; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer; font-size: 0.9rem; }
        .mission-card-actions .completed-status { color: var(--secondary); font-weight: bold; font-size: 0.9rem; }
        .message { padding: 1rem; margin-bottom: 1rem; border-radius: 8px; color: #fff; }
        .message.success { background-color: #198754; }
        .message.error { background-color: #dc3545; }
    </style>
</head>
<body>
    <header>
        <h1><i class="fa-solid fa-gamepad"></i> GamifyOS Dashboard</h1>
        <a href="logout.php" class="logout-btn"><i class="fa-solid fa-right-from-bracket"></i> Sair</a>
    </header>

    <div class="admin-container">
        <div class="admin-header"><a href="dashboard.php">Dashboard</a> > Gerenciar Missões</div>

        <?php if ($message): ?>
            <div class="message <?php echo strpos($message, 'sucesso') !== false ? 'success' : 'error'; ?>"><?= htmlspecialchars($message); ?></div>
        <?php endif; ?>



        <div class="admin-section">
            <h2>Missões Existentes</h2>
            <div class="mission-cards">
                <?php foreach ($missions_list as $mission): ?>
                    <div class="mission-card">
                        <img src="<?= htmlspecialchars($mission['image_url'] ?: 'https://via.placeholder.com/300x160?text=Sem+Imagem') ?>" alt="Imagem da Missão">
                        <div class="mission-card-content">
                            <h3><?= htmlspecialchars($mission['title']); ?></h3>
                            <div class="mission-card-rewards">
                                <span><i class="fa-solid fa-star"></i> <?= $mission['xp_reward']; ?> XP</span>
                                <span><i class="fa-solid fa-coins"></i> <?= $mission['gold_reward']; ?> Gold</span>
                            </div>
                        </div>
                        <div class="mission-card-actions">
                            <a href="admin_mission.php?edit_mission=<?= $mission['id']; ?>">Editar</a>
                            <a href="admin_mission.php?delete_mission=<?= $mission['id']; ?>" class="delete" onclick="return confirm('Tem certeza que deseja excluir esta missão?');">Excluir</a>
                            <div style="margin-left: auto;">
                                <?php if (in_array($mission['id'], $completedMissions)): ?>
                                    <span class="completed-status">Concluída</span>
                                <?php else: ?>
                                    <form action="admin_mission.php" method="POST" style="display: inline;">
                                        <input type="hidden" name="mission_id_to_complete" value="<?= $mission['id']; ?>">
                                        <button type="submit" name="complete_mission" class="complete-btn">Concluir</button>
                                    </form>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
        <div class="admin-section">
            <h2><?= $mission_to_edit ? 'Editar Missão' : 'Adicionar Nova Missão'; ?></h2>
            <form action="admin_mission.php" method="POST">
                <input type="hidden" name="mission_id" value="<?= $mission_to_edit['id'] ?? ''; ?>">
                <div>
                    <label for="title">Título da Missão:</label>
                    <input type="text" name="title" id="title" value="<?= htmlspecialchars($mission_to_edit['title'] ?? ''); ?>" required>
                </div>
                <div>
                    <label for="xp_reward">Recompensa de XP:</label>
                    <input type="number" name="xp_reward" id="xp_reward" value="<?= $mission_to_edit['xp_reward'] ?? ''; ?>" required>
                </div>
                <div>
                    <label for="gold_reward">Recompensa de Gold:</label>
                    <input type="number" name="gold_reward" id="gold_reward" value="<?= htmlspecialchars($mission_to_edit['gold_reward'] ?? '0'); ?>" required>
                </div>
                <div>
                    <label for="image_url">URL da Imagem:</label>
                    <input type="url" name="image_url" id="image_url" value="<?= htmlspecialchars($mission_to_edit['image_url'] ?? ''); ?>">
                    <p>Pegue uma imagem na internet</p>
                </div>
                <div>
                    <button type="submit" name="save_mission"><?= $mission_to_edit ? 'Atualizar Missão' : 'Adicionar Missão'; ?></button>
                    <?php if ($mission_to_edit): ?>
                        <a href="admin_mission.php" style="margin-left: 10px;">Cancelar Edição</a>
                    <?php endif; ?>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
