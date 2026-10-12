<?php
require_once 'init.php';
require_once 'classes/AttributeManager.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$userId = $_SESSION['user_id'];
$itemId = $_POST['item_id'] ?? null;

if (!$itemId) {
    $_SESSION['purchase_message'] = "ID do item inválido.";
    $_SESSION['purchase_success'] = false;
    header("Location: shop.php");
    exit;
}

$pdo->beginTransaction();

try {
    // Etapa 1: Obter dados do item e do usuário (com lock para segurança)
    $stmt = $pdo->prepare("SELECT gold FROM users WHERE id = ? FOR UPDATE");
    $stmt->execute([$userId]);
    $userGold = $stmt->fetchColumn();

    $stmt = $pdo->prepare("SELECT * FROM items WHERE id = ?");
    $stmt->execute([$itemId]);
    $item = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$item || $item['price'] <= 0) {
        throw new Exception("Item inválido ou não está à venda.");
    }

    // Etapa 2: Calcular preço com desconto de Carisma
    $attributeManager = new AttributeManager($pdo, $userId);
    $finalPrice = $attributeManager->calculateDiscountedPrice((float)$item['price']);
    $finalPrice = round($finalPrice, 2);

    // Etapa 3: Verificar se o usuário pode pagar
    if ($userGold < $finalPrice) {
        throw new Exception("Gold insuficiente para comprar o item \"" . htmlspecialchars($item['name']) . "\".");
    }

    // Etapa 4: Debitar o Gold
    $stmt = $pdo->prepare("UPDATE users SET gold = gold - ? WHERE id = ?");
    $stmt->execute([$finalPrice, $userId]);

    // Etapa 5: Adicionar o item/efeito ao usuário
    if (in_array($item['effect'], ['reset_task', 'extra_mission'])) {
        $stmt = $pdo->prepare("SELECT quantity FROM user_items WHERE user_id = ? AND item_id = ?");
        $stmt->execute([$userId, $itemId]);
        if ($stmt->fetch()) {
            $stmt = $pdo->prepare("UPDATE user_items SET quantity = quantity + 1 WHERE user_id = ? AND item_id = ?");
        } else {
            $stmt = $pdo->prepare("INSERT INTO user_items (user_id, item_id, quantity) VALUES (?, ?, 1)");
        }
        $stmt->execute([$userId, $itemId]);
        $_SESSION['purchase_message'] = "'" . htmlspecialchars($item['name']) . "' adicionado ao inventário!";

    } elseif (isset($item['duration']) && $item['duration'] > 0) {
        $expiresAt = (new DateTime())->add(new DateInterval('PT' . $item['duration'] . 'H'))->format('Y-m-d H:i:s');
        $stmt = $pdo->prepare("INSERT INTO user_effects (user_id, item_id, expires_at) VALUES (?, ?, ?)");
        $stmt->execute([$userId, $itemId, $expiresAt]);
        $_SESSION['purchase_message'] = "'" . htmlspecialchars($item['name']) . "' ativado com sucesso!";

    } else {
        throw new Exception("O item '" . htmlspecialchars($item['name']) . "' não tem um efeito comprável definido.");
    }
    
    $pdo->commit();
    $_SESSION['purchase_success'] = true;

} catch (Exception $e) {
    $pdo->rollBack();
    $_SESSION['purchase_message'] = "Erro na compra: " . $e->getMessage();
    $_SESSION['purchase_success'] = false;
}

header("Location: shop.php");
exit;
