<?php
require_once 'init.php'; // Includes the database connection ($pdo)

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

// Define the list of attributes
$attributes = [
    'inteligencia' => 'Inteligência',
    'forca' => 'Força',
    'espiritualidade' => 'Espiritualidade',
    'carisma' => 'Carisma',
    'percepcao_espacial' => 'Percepção Espacial',
    'autoconsciencia' => 'Autoconsciência',
    'linguagem' => 'Linguagem',
    'raciocinio_logico' => 'Raciocínio Lógico',
    'musicalidade' => 'Musicalidade'
];

$message = '';
$task_to_edit = null;

// Handle form submissions for adding/editing tasks
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_task'])) {
    $title = trim($_POST['title']);
    $xp_reward = filter_input(INPUT_POST, 'xp_reward', FILTER_VALIDATE_INT);
    $gold_reward = filter_input(INPUT_POST, 'gold_reward', FILTER_VALIDATE_INT);
    $attribute_id = $_POST['attribute_id']; // Get the selected attribute
    $task_id = filter_input(INPUT_POST, 'task_id', FILTER_VALIDATE_INT);

    // Validate that the attribute is valid
    if ($title && $xp_reward !== false && $gold_reward !== false && array_key_exists($attribute_id, $attributes)) {
        if ($task_id) {
            // Update existing task
            $stmt = $pdo->prepare("UPDATE tasks SET title = ?, xp_reward = ?, gold_reward = ?, attribute_id = ? WHERE id = ?");
            if ($stmt->execute([$title, $xp_reward, $gold_reward, $attribute_id, $task_id])) {
                $message = "Tarefa atualizada com sucesso!";
            } else {
                $message = "Erro ao atualizar a tarefa.";
            }
        } else {
            // Add new task
            $stmt = $pdo->prepare("INSERT INTO tasks (title, xp_reward, gold_reward, attribute_id) VALUES (?, ?, ?, ?)");
            if ($stmt->execute([$title, $xp_reward, $gold_reward, $attribute_id])) {
                $message = "Tarefa adicionada com sucesso!";
            } else {
                $message = "Erro ao adicionar a tarefa.";
            }
        }
    } else {
        $message = "Por favor, preencha todos os campos corretamente.";
    }
}

// Handle task deletion
if (isset($_GET['delete_task'])) {
    $task_id_to_delete = filter_input(INPUT_GET, 'delete_task', FILTER_VALIDATE_INT);
    if ($task_id_to_delete) {
        $stmt = $pdo->prepare("DELETE FROM tasks WHERE id = ?");
        if ($stmt->execute([$task_id_to_delete])) {
            $message = "Tarefa excluída com sucesso!";
        } else {
            $message = "Erro ao excluir a tarefa.";
        }
    }
}

// Fetch task for editing
if (isset($_GET['edit_task'])) {
    $task_id_to_edit = filter_input(INPUT_GET, 'edit_task', FILTER_VALIDATE_INT);
    if ($task_id_to_edit) {
        $stmt = $pdo->prepare("SELECT * FROM tasks WHERE id = ?");
        $stmt->execute([$task_id_to_edit]);
        $task_to_edit = $stmt->fetch(PDO::FETCH_ASSOC);
    }
}

// Fetch all tasks
$tasks_stmt = $pdo->query("SELECT * FROM tasks ORDER BY id DESC");
$tasks_list = $tasks_stmt->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Tarefas</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

    <style>
        /* Estilos específicos para a página de administração de tarefas */
        body {
            background: var(--bg);
        }
        .admin-container {
            max-width: 900px;
            margin: 24px auto;
            padding: 16px;
        }
        .admin-header {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
        }
        .admin-header a {
            color: var(--primary);
            text-decoration: none;
        }
        .admin-section {
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 20px;
            margin-bottom: 2rem;
        }
        .admin-section h2 {
            margin-top: 0;
            font-size: 1.2rem;
            border-bottom: 2px solid #eee;
            padding-bottom: 8px;
        }
        form div {
            margin-bottom: 1rem;
        }
        form label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        form input[type="text"], form input[type="number"], form select {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 8px;
            transition: border-color 0.2s;
        }
        form input:focus, form select:focus {
            border-color: var(--primary);
            outline: none;
        }
        form button {
            background: var(--primary);
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.2s;
        }
        form button:hover {
            background: #0b5ed7;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        .actions a {
            color: var(--primary);
            margin-right: 10px;
        }
        .actions a.delete {
            color: #dc3545;
        }
        .message {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
            color: #fff;
        }
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
    <div class="admin-header">
        <a href="dashboard.php">Dashboard</a> > Gerenciar Tarefas
    </div>

    <?php if ($message): ?>
        <div class="message <?php echo strpos($message, 'sucesso') !== false ? 'success' : 'error'; ?>">
            <?= htmlspecialchars($message); ?>
        </div>
    <?php endif; ?>

    <div class="admin-section">
        <h2><?= $task_to_edit ? 'Editar Tarefa' : 'Adicionar Nova Tarefa'; ?></h2>
        <form action="admin_tasks.php" method="POST">
            <input type="hidden" name="task_id" value="<?= $task_to_edit['id'] ?? ''; ?>">
            <div>
                <label for="title">Título da Tarefa:</label>
                <input type="text" name="title" id="title" value="<?= htmlspecialchars($task_to_edit['title'] ?? ''); ?>" required>
            </div>
            <div>
                <label for="xp_reward">Recompensa de XP:</label>
                <input type="number" name="xp_reward" id="xp_reward" value="<?= $task_to_edit['xp_reward'] ?? ''; ?>" required>
            </div>
            <div>
                <label for="gold_reward">Recompensa de Gold:</label>
                <input type="number" name="gold_reward" id="gold_reward" value="<?= htmlspecialchars($task_to_edit['gold_reward'] ?? '0'); ?>" required>
            </div>
            <div>
                <label for="attribute_id">Atributo:</label>
                <select name="attribute_id" id="attribute_id" required>
                    <option value="">-- Selecione um Atributo --</option>
                    <?php foreach ($attributes as $key => $value): ?>
                        <option value="<?= $key; ?>" <?= (isset($task_to_edit['attribute_id']) && $task_to_edit['attribute_id'] == $key) ? 'selected' : ''; ?>><?= $value; ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div>
                <button type="submit" name="save_task"><?= $task_to_edit ? 'Atualizar Tarefa' : 'Adicionar Tarefa'; ?></button>
                <?php if ($task_to_edit): ?>
                    <a href="admin_tasks.php" style="margin-left: 10px;">Cancelar Edição</a>
                <?php endif; ?>
            </div>
        </form>
    </div>

    <div class="admin-section">
        <h2>Tarefas Existentes</h2>
        <table>
            <thead>
                <tr>
                    <th>Título</th>
                    <th>XP</th>
                    <th>Gold</th>
                    <th>Atributo</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($tasks_list as $task): ?>
                <tr>
                    <td><?= htmlspecialchars($task['title']); ?></td>
                    <td><?= $task['xp_reward']; ?></td>
                    <td><?= $task['gold_reward']; ?></td>
                    <td><?= htmlspecialchars($attributes[$task['attribute_id']] ?? 'N/A'); ?></td>
                    <td class="actions">
                        <a href="admin_tasks.php?edit_task=<?= $task['id']; ?>">Editar</a>
                        <a href="admin_tasks.php?delete_task=<?= $task['id']; ?>" class="delete" onclick="return confirm('Tem certeza que deseja excluir esta tarefa?');">Excluir</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

</div>

</body>
</html>
