<?php
// 1. Start the Session (MUST be the very first thing)
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// 2. Configure Error Reporting & Display
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 3. Connect to the Database
$pdo = require "db.php";

// --- The rest of the initialization logic ---

// Define the array of tables for ensuring creation order.
$tables = [];

// Users Table
$tables['users'] = "
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    global_xp INTEGER NOT NULL DEFAULT 0,
    gold INTEGER NOT NULL DEFAULT 0,
    profile_picture TEXT,
    inteligencia INTEGER NOT NULL DEFAULT 0,
    forca INTEGER NOT NULL DEFAULT 0,
    espiritualidade INTEGER NOT NULL DEFAULT 0,
    carisma INTEGER NOT NULL DEFAULT 0,
    percepcao_espacial INTEGER NOT NULL DEFAULT 0,
    autoconsciencia INTEGER NOT NULL DEFAULT 0,
    linguagem INTEGER NOT NULL DEFAULT 0,
    raciocinio_logico INTEGER NOT NULL DEFAULT 0,
    musicalidade INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
";

// Missions Table
$tables['missions'] = "
CREATE TABLE IF NOT EXISTS missions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    gold_reward INTEGER NOT NULL DEFAULT 0,
    image_url TEXT
);
";

// Tasks Table
$tables['tasks'] = "
CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    gold_reward INTEGER NOT NULL DEFAULT 0,
    attribute_id TEXT NOT NULL
);
";

// User Missions Table
$tables['user_missions'] = "
CREATE TABLE IF NOT EXISTS user_missions (
    user_id INTEGER NOT NULL,
    mission_id INTEGER NOT NULL,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, mission_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE
);
";

// User Tasks Table
$tables['user_tasks'] = "
CREATE TABLE IF NOT EXISTS user_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);
";

try {
    // Execute table creation.
    foreach ($tables as $sql) {
        $pdo->exec($sql);
    }

    // Safely add new columns if they don't exist.
    function columnExists($pdo, $tableName, $columnName) {
        $stmt = $pdo->prepare("PRAGMA table_info('{$tableName}');");
        $stmt->execute();
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN, 1);
        return in_array($columnName, $columns);
    }

    if (!columnExists($pdo, 'users', 'global_xp')) {
        $pdo->exec("ALTER TABLE users ADD COLUMN global_xp INTEGER NOT NULL DEFAULT 0");
    }

    $all_attributes = ['inteligencia', 'forca', 'espiritualidade', 'carisma', 'percepcao_espacial', 'autoconsciencia', 'linguagem', 'raciocinio_logico', 'musicalidade'];
    foreach($all_attributes as $attr) {
        if (!columnExists($pdo, 'users', $attr)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN {$attr} INTEGER NOT NULL DEFAULT 0");
        }
    }

    if (!columnExists($pdo, 'missions', 'gold_reward')) {
        $pdo->exec("ALTER TABLE missions ADD COLUMN gold_reward INTEGER NOT NULL DEFAULT 0");
    }

    if (!columnExists($pdo, 'missions', 'image_url')) {
        $pdo->exec("ALTER TABLE missions ADD COLUMN image_url TEXT");
    }

    if (!columnExists($pdo, 'tasks', 'attribute_id')) {
        $pdo->exec("ALTER TABLE tasks ADD COLUMN attribute_id TEXT NOT NULL DEFAULT ''");
    }

} catch (PDOException $e) {
    error_log("Database initialization error: " . $e->getMessage());
    die("A database error occurred. Please try again later.");
}

?>