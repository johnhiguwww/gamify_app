<?php
class User {
    private $pdo;
    private $all_attributes = [
        'inteligencia', 'forca', 'espiritualidade', 'carisma', 
        'percepcao_espacial', 'autoconsciencia', 'linguagem', 
        'raciocinio_logico', 'musicalidade'
    ];

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }

    public function getUserById($id) {
        $stmt = $this->pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public static function login($pdo, $email, $password) {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($password, $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            return true;
        }
        return false;
    }

    public static function register($pdo, $name, $email, $password) {
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            return false; // Email already exists
        }

        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
        return $stmt->execute([$name, $email, $hashedPassword]);
    }

    public function addXpAndGold($userId, $xp, $gold, $attribute = null) {
        $userDataBefore = $this->getUserById($userId);
        if (!$userDataBefore) return ['level_up' => false];
        
        $old_global_level = (int)$userDataBefore['level'];

        $update_parts = [];
        $params = [];
        $global_xp_to_add = 0;

        if ($attribute && in_array($attribute, $this->all_attributes)) {
            $old_xp = (int)$userDataBefore[$attribute];
            $new_xp = $old_xp + $xp;
            
            $old_level = floor($old_xp / 100);
            $new_level = floor($new_xp / 100);

            $update_parts[] = "{$attribute} = ?";
            $params[] = $new_xp;
            
            if ($new_level > $old_level) {
                $levels_gained = $new_level - $old_level;
                $global_xp_to_add += $levels_gained * 10; 
            }
        } else {
            $global_xp_to_add += $xp;
        }

        if ($global_xp_to_add > 0) {
            $update_parts[] = "global_xp = COALESCE(global_xp, 0) + ?";
            $params[] = $global_xp_to_add;
        }

        if ($gold > 0) {
            $update_parts[] = "gold = COALESCE(gold, 0) + ?";
            $params[] = $gold;
        }

        if (empty($update_parts)) {
            return ['level_up' => false];
        }

        $params[] = $userId;

        $sql = "UPDATE users SET " . implode(', ', $update_parts) . " WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $this->updateLevel($userId);

        $userDataAfter = $this->getUserById($userId);
        $new_global_level = (int)$userDataAfter['level'];

        return [
            'level_up' => $new_global_level > $old_global_level
        ];
    }

    public function updateLevel($userId) {
        $userData = $this->getUserById($userId);
        if (!$userData) return false;

        $newLevel = floor((int)$userData['global_xp'] / 100);
        $newLevel = $newLevel < 1 ? 1 : $newLevel;

        $stmt = $this->pdo->prepare("UPDATE users SET level = ? WHERE id = ?");
        return $stmt->execute([$newLevel, $userId]);
    }

    public function updateProfilePicture($userId, $newPath) {
        $stmt = $this->pdo->prepare("UPDATE users SET profile_picture = ? WHERE id = ?");
        return $stmt->execute([$newPath, $userId]);
    }
}
?>