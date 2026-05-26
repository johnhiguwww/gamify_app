<?php
require_once "init.php";

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header("Location: shop.php");
    exit;
}

$userId = $_SESSION['user_id'];
$itemId = (int)($_POST['item_id'] ?? 0);

if ($itemId <= 0) {
    $_SESSION['purchase_message'] = "Item inválido.";
    $_SESSION['purchase_success'] = false;
    header("Location: shop.php");
    exit;
}

$pdo->beginTransaction();

try {
    // 1. Busca os detalhes do item e o gold do usuário.
    // A cláusula "FOR UPDATE" foi removida para compatibilidade com SQLite.
    $stmt = $pdo->prepare("SELECT gold FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $userGold = $stmt->fetchColumn();

    $stmt = $pdo->prepare("SELECT * FROM shop_items WHERE id = ?");
    $stmt->execute([$itemId]);
    $item = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. Verifica se o item existe e se o usuário tem gold suficiente
    if (!$item) {
        throw new Exception("Este item não existe mais na loja.");
    }

    if ($userGold < $item['price']) {
        throw new Exception("Você não tem Gold suficiente para comprar \"" . htmlspecialchars($item['name']) . "\".");
    }

    // 3. Deduz o gold do usuário
    $newGold = $userGold - $item['price'];
    $stmt = $pdo->prepare("UPDATE users SET gold = ? WHERE id = ?");
    $stmt->execute([$newGold, $userId]);

    // 4. Adiciona o item ao inventário do usuário
    $stmt = $pdo->prepare("INSERT INTO user_items (user_id, item_id, item_name, effect) VALUES (?, ?, ?, ?)");
    $stmt->execute([$userId, $item['id'], $item['name'], $item['effect']]);

    $pdo->commit();

    $_SESSION['purchase_message'] = "Você comprou \"" . htmlspecialchars($item['name']) . "\" com sucesso!";
    $_SESSION['purchase_success'] = true;

} catch (Exception $e) {
    $pdo->rollBack();

    $_SESSION['purchase_message'] = "Erro na compra: " . $e->getMessage();
    $_SESSION['purchase_success'] = false;
}

header("Location: shop.php");
exit;
?>