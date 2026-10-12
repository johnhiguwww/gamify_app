<?php
require_once "init.php";
require_once "classes/AttributeManager.php"; // Incluído

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$userId = $_SESSION['user_id'];

// Instancia o AttributeManager
try {
    $attributeManager = new AttributeManager($pdo, $userId);
} catch (Exception $e) {
    die("Erro ao carregar dados do usuário: " . $e->getMessage());
}

// Busca o gold do usuário
$stmt = $pdo->prepare("SELECT gold FROM users WHERE id = ?");
$stmt->execute([$userId]);
$userGold = $stmt->fetchColumn();

// Busca os itens da loja
$shopItems = $pdo->query("SELECT * FROM items WHERE is_system = 1 AND price > 0 ORDER BY name ASC")->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loja - GamifyOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style_shop.css">
    <style>
        .original-price { text-decoration: line-through; color: #aaa; font-size: 0.9rem; }
        .discounted-price { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <!-- Header da Loja -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="text-white">Loja de Itens</h1>
            <div class="d-flex align-items-center">
                 <a href="dashboard.php" class="btn btn-secondary me-3"><i class="fas fa-arrow-left"></i> Voltar</a>
                <span class="badge bg-warning text-dark p-2 me-2"><i class="fas fa-coins"></i> <?= htmlspecialchars($userGold); ?> Gold</span>
                <a href="admin_shop.php" class="btn btn-outline-light btn-sm"><i class="fas fa-cog"></i></a>
            </div>
        </div>

        <!-- Mensagens de Feedback -->
        <?php if (isset($_SESSION['purchase_message'])): ?>
            <div class="alert alert-<?= $_SESSION['purchase_success'] ? 'success' : 'danger'; ?>"><?= $_SESSION['purchase_message']; ?></div>
            <?php unset($_SESSION['purchase_message'], $_SESSION['purchase_success']); ?>
        <?php endif; ?>

        <!-- Itens da Loja -->
        <div class="row g-4">
            <?php foreach ($shopItems as $item): ?>
                <?php
                    $originalPrice = (float)$item['price'];
                    $discountedPrice = $attributeManager->calculateDiscountedPrice($originalPrice);
                    $canAfford = $userGold >= $discountedPrice;
                ?>
                <div class="col-md-4 col-lg-3">
                    <div class="card h-100 bg-dark text-white text-center">
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title"><?= htmlspecialchars($item['name']); ?></h5>
                            <p class="card-text flex-grow-1"><?= htmlspecialchars($item['description']); ?></p>
                            
                            <!-- Preço -->
                            <div class="mb-3">
                                <?php if ($discountedPrice < $originalPrice): ?>
                                    <span class="original-price"><i class="fas fa-coins"></i> <?= number_format($originalPrice, 0); ?></span>
                                    <span class="discounted-price"><i class="fas fa-coins"></i> <?= number_format($discountedPrice, 0); ?></span>
                                <?php else: ?>
                                    <span><i class="fas fa-coins"></i> <?= number_format($originalPrice, 0); ?></span>
                                <?php endif; ?>
                            </div>

                            <!-- Formulário de Compra -->
                            <form action="process_item_activation.php" method="POST">
                                <input type="hidden" name="item_id" value="<?= $item['id']; ?>">
                                <button type="submit" class="btn btn-primary" <?= !$canAfford ? 'disabled' : ''; ?>>
                                    <i class="fas fa-shopping-cart"></i> Comprar
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
