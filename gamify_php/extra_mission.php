<?php
require_once 'init.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$userId = $_SESSION['user_id'];

// Busca missões que o usuário ainda não aceitou
$stmt = $pdo->prepare(
    "SELECT m.* FROM missions m
     LEFT JOIN user_missions um ON m.id = um.mission_id AND um.user_id = ?
     WHERE um.mission_id IS NULL"
);
$stmt->execute([$userId]);
$availableMissions = $stmt->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Escolher Missão Extra - GamifyOS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h1>Escolher Missão Extra</h1>
        <?php if (empty($availableMissions)): ?>
            <p>Não há novas missões disponíveis no momento.</p>
            <a href="dashboard.php">Voltar ao Dashboard</a>
        <?php else: ?>
            <form action="process_extra_mission.php" method="POST">
                <p>Selecione uma das missões abaixo para adicioná-la às suas missões ativas:</p>
                <div class="list">
                    <?php foreach ($availableMissions as $mission): ?>
                        <label class="list-item">
                            <input type="radio" name="mission_id" value="<?= $mission['id']; ?>" required>
                            <div>
                                <strong><?= htmlspecialchars($mission['title']); ?></strong>
                                <p><?= htmlspecialchars($mission['description']); ?></p>
                            </div>
                        </label>
                    <?php endforeach; ?>
                </div>
                <button type="submit" class="btn" style="margin-top: 15px;">Adicionar Missão</button>
            </form>
        <?php endif; ?>
    </div>
</body>
</html>
