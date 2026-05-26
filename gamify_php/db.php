<?php

class DB {
    // Removida a tipagem para máxima compatibilidade
    private static $conn = null;

    public static function connect() {
        if (self::$conn === null) {
            try {
                // O objeto PDO será criado da mesma forma
                self::$conn = new PDO('sqlite:game.db');
                self::$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            } catch (PDOException $e) {
                // Este bloco de erro continua sendo uma salvaguarda importante
                die("Erro na conexão com o banco de dados: " . $e->getMessage());
            }
        }
        return self::$conn;
    }
}

return DB::connect();
