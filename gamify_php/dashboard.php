<?php
require_once 'init.php';
require_once 'classes/User.php';
require_once 'classes/Patents.php';
require_once 'utils.php';

if (!function_exists('xp_for_level')) {
    function xp_for_level($level) {
        return floor(100 * pow($level, 1.5));
    }
}

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit();
}

$userId = $_SESSION['user_id'];
$user = new User($pdo);
$userData = $user->getUserById($userId);

$patentsManager = new Patents();
$userPatent = $patentsManager->getPatentForLevel($userData['level'] ?? 1);

// --- LÓGICA DE MISSÕES CORRIGIDA ---
$stmtCompleted = $pdo->prepare("SELECT COUNT(*) FROM user_missions WHERE user_id = ?");
$stmtCompleted->execute([$userId]);
$completed_missions = $stmtCompleted->fetchColumn();

$stmtPending = $pdo->prepare("SELECT COUNT(*) FROM missions WHERE id NOT IN (SELECT mission_id FROM user_missions WHERE user_id = ?)");
$stmtPending->execute([$userId]);
$pending_missions = $stmtPending->fetchColumn();

$attributes_config = [
    'inteligencia' => ['icon' => 'fa-solid fa-brain', 'label' => 'Inteligência'],
    'forca' => ['icon' => 'fa-solid fa-dumbbell', 'label' => 'Força'],
    'espiritualidade' => ['icon' => 'fa-solid fa-om', 'label' => 'Espiritualidade'],
    'carisma' => ['icon' => 'fa-solid fa-people-group', 'label' => 'Carisma'],
    'percepcao_espacial' => ['icon' => 'fa-solid fa-map', 'label' => 'Percepção Espacial'],
    'autoconsciencia' => ['icon' => 'fa-solid fa-compass', 'label' => 'Autoconsciência'],
    'linguagem' => ['icon' => 'fa-solid fa-language', 'label' => 'Linguagem'],
    'raciocinio_logico' => ['icon' => 'fa-solid fa-calculator', 'label' => 'Raciocínio Lógico'],
    'musicalidade' => ['icon' => 'fa-solid fa-music', 'label' => 'Musicalidade'],
];

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - GamifyOS</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="dashboard-container">
        <div class="profile-main-card">
            <div class="profile-image-container">
                <img src="<?= htmlspecialchars($userData['avatar_url'] ?? 'assets/default-avatar.png') ?>" alt="Foto de Perfil">
            </div>
            <div class="profile-details">
                <h2 class="username"><?= htmlspecialchars($userData['name'] ?? 'Usuário') ?></h2>
                <p class="patent">Patente: <?= htmlspecialchars($userPatent['name'] ?? 'N/A') ?></p>
                <div class="stats-grid"><div class="stat-item"><i class="fa-solid fa-award"></i><span><?= $userData['level'] ?? 1 ?></span>Nível Global</div><div class="stat-item"><i class="fa-solid fa-coins"></i><span><?= $userData['gold'] ?? 0 ?></span>Gold</div></div>
                <div class="xp-bar-container">
                    <?php 
                        $level = $userData['level'] ?? 1;
                        $xp_for_prev_level = $level > 1 ? xp_for_level($level - 1) : 0;
                        $xp_for_next = xp_for_level($level);
                        $current_level_xp = ($userData['global_xp'] ?? 0) - $xp_for_prev_level;
                        $xp_needed = $xp_for_next - $xp_for_prev_level;
                        $xp_percent = $xp_needed > 0 ? ($current_level_xp / $xp_needed) * 100 : 0;
                    ?>
                    <div class="xp-bar" style="width: <?= $xp_percent ?>%;"></div>
                </div>
                <p class="xp-text"><?= $current_level_xp ?> / <?= $xp_needed ?> XP para o próximo nível</p>
                <h3 class="attributes-title">Atributos</h3>
                <div class="attributes-list">
                    <?php foreach ($attributes_config as $key => $config): 
                        $attr_level = $userData[$key . '_level'] ?? 0;
                        $attr_xp = $userData[$key . '_xp'] ?? 0;
                        $xp_for_next_attr = 100;
                    ?>
                    <div class="attribute-row"><i class="<?= $config['icon'] ?>"></i><span class="attribute-name"><?= $config['label'] ?> <strong>Nível <?= $attr_level ?></strong></span><span class="attribute-xp"><?= $attr_xp % $xp_for_next_attr ?>/<?= $xp_for_next_attr ?> XP</span></div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        <div class="widgets-column">
            <div class="widget-card">
                <div class="widget-header">
                    <h3><i class="fa-solid fa-trophy"></i> Missões</h3>
                    <a href="missions.php">Gerenciar</a>
                </div>
                <div class="widget-content-split"><div class="split-item"><i class="fa-solid fa-check-circle"></i><span><?= $completed_missions ?></span>Concluídas</div><div class="split-item"><i class="fa-solid fa-list-ul"></i><span><?= $pending_missions ?></span>Pendentes</div></div>
            </div>
            <div class="widget-card">
                <div class="widget-header">
                     <h3><i class="fa-solid fa-list-check"></i> Tarefas</h3>
                     <a href="admin_tasks.php">Gerenciar</a>
                </div>
                 <div class="widget-content-full"><p>Acesse o painel para ver e gerenciar suas tarefas diárias.</p></div>
            </div>
            <div class="widget-card">
                 <div class="widget-header">
                    <h3><i class="fa-solid fa-store"></i> Loja</h3>
                </div>
                <div class="widget-content-full"><a href="shop.php" class="action-button">Acessar a Loja de Itens</a></div>
            </div>
        </div>
    </div>
</body>
</html>
