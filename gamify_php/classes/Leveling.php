<?php
//# Sistema de níveis/XP
class Leveling {
    private const XP_PER_LEVEL = 100;

    public static function getLevel(int $xp): int {
        return intdiv($xp, self::XP_PER_LEVEL) + 1;
    }

    public static function getXpToNext(int $xp): int {
        return self::XP_PER_LEVEL - ($xp % self::XP_PER_LEVEL);
    }
}
