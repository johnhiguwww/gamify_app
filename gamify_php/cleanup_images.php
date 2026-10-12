<?php
require_once 'init.php';

// --- CONFIGURAÇÃO ---
$uploadDir = 'uploads/profile_pictures/';

// --- INÍCIO DO SCRIPT ---
echo "<pre>"; // Para formatar a saída de forma legível
echo "Iniciando script de limpeza de imagens de perfil...\n";

// 1. Buscar todas as imagens de perfil em uso no banco de dados
try {
    $stmt = $pdo->query("SELECT profile_picture FROM users WHERE profile_picture IS NOT NULL AND profile_picture != ''");
    $dbImages = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);

    // Normaliza os caminhos (remove o caminho do diretório, deixando apenas o nome do arquivo)
    $dbImageFiles = array_map('basename', $dbImages);

    echo "Encontradas " . count($dbImageFiles) . " imagens em uso no banco de dados.\n";
} catch (PDOException $e) {
    die("Erro ao consultar o banco de dados: " . $e->getMessage());
}

// 2. Listar todos os arquivos de imagem no diretório de upload
if (!is_dir($uploadDir)) {
    die("Erro: O diretório de uploads '{$uploadDir}' não foi encontrado.\n");
}

$diskImageFiles = scandir($uploadDir);
// Remove os diretórios `.` e `..` da lista
$diskImageFiles = array_diff($diskImageFiles, ['.', '..']);

echo "Encontrados " . count($diskImageFiles) . " arquivos de imagem no disco.\n";

// 3. Comparar as listas e apagar os arquivos órfãos
$deletedCount = 0;
$notFoundCount = 0;

echo "\nComparando e procurando por arquivos órfãos...\n";

foreach ($diskImageFiles as $diskFile) {
    if (!in_array($diskFile, $dbImageFiles)) {
        $filePath = $uploadDir . $diskFile;
        if (file_exists($filePath)) {
            // Tenta apagar o arquivo
            if (unlink($filePath)) {
                echo " - [APAGADO] O arquivo '{$diskFile}' era órfão e foi excluído.\n";
                $deletedCount++;
            } else {
                echo " - [ERRO] Falha ao tentar apagar o arquivo '{$diskFile}'. Verifique as permissões.\n";
            }
        } else {
             $notFoundCount++; // Conta arquivos que já não existem mais, caso ocorra
        }
    }
}

// --- RELATÓRIO FINAL ---
echo "\n--- Limpeza Concluída ---\n";
echo "Total de arquivos órfãos encontrados e excluídos: {$deletedCount}\n";

if (count($diskImageFiles) - $deletedCount === count($dbImageFiles)) {
    echo "O sistema de arquivos agora está sincronizado com o banco de dados.\n";
} else {
    echo "A verificação terminou, mas pode haver inconsistências residuais.\n";
}

echo "</pre>";

?>
