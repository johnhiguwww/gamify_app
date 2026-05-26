<?php
require_once "init.php";

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

$userId = $_SESSION['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['new_picture'])) {
    $file = $_FILES['new_picture'];

    // --- File Validation ---
    // Check for upload errors
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $_SESSION['upload_error'] = "Ocorreu um erro no upload. Código: " . $file['error'];
        header('Location: dashboard.php');
        exit;
    }

    // Check file size (e.g., max 2MB)
    if ($file['size'] > 2 * 1024 * 1024) {
        $_SESSION['upload_error'] = "O arquivo é muito grande. O tamanho máximo é de 2MB.";
        header('Location: dashboard.php');
        exit;
    }

    // Check file type
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    $fileInfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($fileInfo, $file['tmp_name']);
    finfo_close($fileInfo);

    if (!in_array($mimeType, $allowedTypes)) {
        $_SESSION['upload_error'] = "Formato de arquivo inválido. Use JPG, PNG ou GIF.";
        header('Location: dashboard.php');
        exit;
    }

    // --- File Processing ---
    // Generate a unique filename to prevent overwriting
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $newFilename = uniqid('user_' . $userId . '_', true) . '.' . $extension;

    // Define the upload directory
    $uploadDir = 'uploads/profile_pictures/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true); // Create directory if it doesn't exist
    }

    $destination = $uploadDir . $newFilename;

    // --- Move the File and Update Database ---
    if (move_uploaded_file($file['tmp_name'], $destination)) {
        // Update the user's profile picture path in the database
        $stmt = $pdo->prepare("UPDATE users SET profile_picture = ? WHERE id = ?");
        if ($stmt->execute([$destination, $userId])) {
            // Success
        } else {
            $_SESSION['upload_error'] = "Erro ao salvar o caminho da imagem no banco de dados.";
        }
    } else {
        $_SESSION['upload_error'] = "Não foi possível mover o arquivo para o destino.";
    }

} else {
    $_SESSION['upload_error'] = "Nenhum arquivo enviado.";
}

header('Location: dashboard.php');
exit;
?>