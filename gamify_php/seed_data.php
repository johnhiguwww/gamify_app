<?php
require 'db.php';

try {
    $pdo = DB::connect();

    // Pre-defined items
    $items = [
        [
            'name' => 'Foco Profundo',
            'description' => '+10% XP por 24h',
            'effect' => 'xp_boost',
            'duration' => 24, // hours
            'xp_boost' => 1.10,
            'is_system' => 1
        ],
        [
            'name' => 'Disciplina Diária',
            'description' => '+1 missão extra por dia',
            'effect' => 'extra_mission',
            'duration' => null,
            'xp_boost' => null,
            'is_system' => 1
        ],
        [
            'name' => 'Recomeço Consciente',
            'description' => 'Resetar 1 tarefa diária',
            'effect' => 'reset_task',
            'duration' => null,
            'xp_boost' => null,
            'is_system' => 1
        ],
        [
            'name' => 'Clareza Mental',
            'description' => 'Aumenta XP de tarefas intelectuais por 24h',
            'effect' => 'intellectual_xp_boost',
            'duration' => 24, // hours
            'xp_boost' => 1.15,
            'is_system' => 1
        ],
        [
            'name' => 'Energia Física',
            'description' => 'Bônus de XP em tarefas físicas',
            'effect' => 'physical_xp_boost',
            'duration' => null,
            'xp_boost' => 1.15,
            'is_system' => 1
        ]
    ];

    // Pre-defined tasks
    $tasks = [
        [
            'title' => 'Estudar 25 minutos sem distrações',
            'xp_reward' => 20,
            'gold_reward' => 5,
            'attribute_id' => 'inteligencia',
            'is_system' => 1
        ],
        [
            'title' => 'Planejar o dia (5 minutos)',
            'xp_reward' => 10,
            'gold_reward' => 2,
            'attribute_id' => 'autoconsciencia',
            'is_system' => 1
        ],
        [
            'title' => 'Organizar o ambiente',
            'xp_reward' => 10,
            'gold_reward' => 3,
            'attribute_id' => 'percepcao_espacial',
            'is_system' => 1
        ],
        [
            'title' => 'Momento de reflexão / espiritualidade',
            'xp_reward' => 15,
            'gold_reward' => 0,
            'attribute_id' => 'espiritualidade',
            'is_system' => 1
        ],
        [
            'title' => 'Atividade física leve',
            'xp_reward' => 15,
            'gold_reward' => 5,
            'attribute_id' => 'forca',
            'is_system' => 1
        ]
    ];

    // Insert pre-defined items
    $stmt = $pdo->prepare("INSERT INTO items (name, description, effect, duration, xp_boost, is_system) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($items as $item) {
        $stmt->execute(array_values($item));
    }

    // Insert pre-defined tasks
    $stmt = $pdo->prepare("INSERT INTO tasks (title, xp_reward, gold_reward, attribute_id, is_system) VALUES (?, ?, ?, ?, ?)");
    foreach ($tasks as $task) {
        $stmt->execute(array_values($task));
    }

    echo "Pre-defined data seeded successfully.";

} catch (PDOException $e) {
    die("Database error: " . $e->getMessage());
}
