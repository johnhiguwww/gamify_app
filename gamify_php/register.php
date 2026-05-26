<?php
require_once "init.php";
require_once "classes/User.php";

$error = null;

// Apenas processa o formulário se for um método POST
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $name = isset($_POST["name"]) ? trim($_POST["name"]) : '';
    $email = isset($_POST["email"]) ? trim($_POST["email"]) : '';
    $password = isset($_POST["password"]) ? $_POST["password"] : '';

    // Validação básica para garantir que os campos não estão vazios
    if (empty($name) || empty($email) || empty($password)) {
        $error = "Todos os campos são obrigatórios.";
    } else {
        if (User::register($pdo, $name, $email, $password)) {
            // Redireciona para a página de login (index.php) com sucesso
            header("Location: index.php?success=1");
            exit;
        } else {
            $error = "Erro ao registrar. Este e-mail já pode estar em uso.";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Registrar - GamifyOS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>Registrar</h2>
        <?php if ($error): ?>
            <p class="error"><?= htmlspecialchars($error) ?></p>
        <?php endif; ?>
        <form method="post" action="register.php">
            <div class="form-group">
                <label>Nome:</label>
                <input type="text" name="name" required>
            </div>
            <div class="form-group">
                <label>Email:</label>
                <input type="email" name="email" required>
            </div>
            <div class="form-group">
                <label>Senha:</label>
                <input type="password" name="password" required>
            </div>
            <button type="submit">Registrar</button>
        </form>
        <p>Já tem conta? <a href="index.php">Faça login</a></p>
    </div>
</body>
</html>
