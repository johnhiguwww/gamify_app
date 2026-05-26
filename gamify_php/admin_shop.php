<?php
require_once 'init.php';

// Proteção: Apenas usuários logados podem acessar
if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$message = '';
$item_to_edit = null;

// --- LÓGICA DE GERENCIAMENTO ---

// 1. Excluir Item
if (isset($_GET['delete_item']) && filter_input(INPUT_GET, 'delete_item', FILTER_VALIDATE_INT)) {
    $item_id_to_delete = $_GET['delete_item'];
    try {
        $stmt = $pdo->prepare("DELETE FROM shop_items WHERE id = ?");
        $stmt->execute([$item_id_to_delete]);
        $message = "<div class='alert alert-success'>Item excluído com sucesso!</div>";
    } catch (PDOException $e) {
        $message = "<div class='alert alert-danger'>Erro ao excluir o item.</div>";
    }
}

// 2. Adicionar ou Atualizar Item (via POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $itemId = filter_input(INPUT_POST, 'item_id', FILTER_VALIDATE_INT);
    $name = $_POST['name'] ?? '';
    $description = $_POST['description'] ?? '';
    $price = filter_input(INPUT_POST, 'price', FILTER_VALIDATE_INT);
    $imageUrl = filter_input(INPUT_POST, 'image_url', FILTER_VALIDATE_URL);
    $effect = $_POST['effect'] ?? '';

    if ($name && $price !== false && $price > 0 && $imageUrl !== false) {
        try {
            if ($itemId) {
                // Atualizar item existente
                $stmt = $pdo->prepare("UPDATE shop_items SET name = ?, description = ?, price = ?, image_url = ?, effect = ? WHERE id = ?");
                $stmt->execute([$name, $description, $price, $imageUrl, $effect, $itemId]);
                $message = "<div class='alert alert-success'>Item atualizado com sucesso!</div>";
            } else {
                // Inserir novo item
                $stmt = $pdo->prepare("INSERT INTO shop_items (name, description, price, image_url, effect) VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([$name, $description, $price, $imageUrl, $effect]);
                $message = "<div class='alert alert-success'>Item adicionado com sucesso!</div>";
            }
        } catch (PDOException $e) {
            $message = "<div class='alert alert-danger'>Erro ao salvar o item: " . $e->getMessage() . "</div>";
        }
    } else {
        $message = "<div class='alert alert-danger'>Por favor, preencha todos os campos corretamente.</div>";
    }
}

// 3. Buscar Item para Edição (via GET)
if (isset($_GET['edit_item']) && filter_input(INPUT_GET, 'edit_item', FILTER_VALIDATE_INT)) {
    $item_id_to_edit = $_GET['edit_item'];
    $stmt = $pdo->prepare("SELECT * FROM shop_items WHERE id = ?");
    $stmt->execute([$item_id_to_edit]);
    $item_to_edit = $stmt->fetch(PDO::FETCH_ASSOC);
}

// 4. Buscar todos os itens para listar
$shop_items = $pdo->query("SELECT * FROM shop_items ORDER BY id DESC")->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Admin - Gerenciar Loja</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style_shop.css">
</head>
<body class="bg-dark text-white">
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Gerenciar Loja</h1>
        <div>
            <a href="dashboard.php" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Voltar para o Dashboard</a>
            <a href="shop.php" class="btn btn-info"><i class="fas fa-store"></i> Ver Loja</a>
        </div>
    </div>

    <?php echo $message; ?>

    <!-- Formulário de Adição/Edição -->
    <div class="card bg-secondary text-white mb-5">
        <div class="card-header">
            <h3><?= $item_to_edit ? 'Editar Item' : 'Adicionar Novo Item'; ?></h3>
        </div>
        <div class="card-body">
            <form action="admin_shop.php" method="POST">
                <input type="hidden" name="item_id" value="<?= $item_to_edit['id'] ?? ''; ?>">
                
                <div class="mb-3">
                    <label for="name" class="form-label">Nome do Item</label>
                    <input type="text" class="form-control" id="name" name="name" value="<?= htmlspecialchars($item_to_edit['name'] ?? ''); ?>" required>
                </div>
                <div class="mb-3">
                    <label for="description" class="form-label">Descrição</label>
                    <textarea class="form-control" id="description" name="description" rows="2"><?= htmlspecialchars($item_to_edit['description'] ?? ''); ?></textarea>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="price" class="form-label">Preço (em Gold)</label>
                        <input type="number" class="form-control" id="price" name="price" value="<?= $item_to_edit['price'] ?? ''; ?>" required min="1">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="effect" class="form-label">Efeito (ex: global_xp+50)</label>
                        <input type="text" class="form-control" id="effect" name="effect" value="<?= htmlspecialchars($item_to_edit['effect'] ?? ''); ?>">
                    </div>
                </div>
                <div class="mb-3">
                    <label for="image_url" class="form-label">URL da Imagem</label>
                    <input type="url" class="form-control" id="image_url" name="image_url" value="<?= htmlspecialchars($item_to_edit['image_url'] ?? ''); ?>" required>
                </div>

                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> <?= $item_to_edit ? 'Salvar Alterações' : 'Adicionar Item'; ?></button>
                <?php if ($item_to_edit): ?>
                    <a href="admin_shop.php" class="btn btn-secondary">Cancelar Edição</a>
                <?php endif; ?>
            </form>
        </div>
    </div>

    <!-- Tabela de Itens Existentes -->
    <div class="card bg-secondary text-white">
        <div class="card-header">
            <h3>Itens Atuais na Loja</h3>
        </div>
        <div class="card-body">
            <table class="table table-dark table-striped">
                <thead>
                    <tr>
                        <th>Imagem</th>
                        <th>Nome</th>
                        <th>Preço</th>
                        <th>Efeito</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($shop_items as $item): ?>
                    <tr>
                        <td><img src="<?= htmlspecialchars($item['image_url']); ?>" alt="<?= htmlspecialchars($item['name']); ?>" style="width: 50px; height: 50px; object-fit: cover;"></td>
                        <td><?= htmlspecialchars($item['name']); ?></td>
                        <td><i class="fas fa-coins"></i> <?= $item['price']; ?></td>
                        <td><?= htmlspecialchars($item['effect']); ?></td>
                        <td>
                            <a href="admin_shop.php?edit_item=<?= $item['id']; ?>" class="btn btn-sm btn-warning"><i class="fas fa-edit"></i> Editar</a>
                            <a href="admin_shop.php?delete_item=<?= $item['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Tem certeza que deseja excluir este item?');"><i class="fas fa-trash"></i> Excluir</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
