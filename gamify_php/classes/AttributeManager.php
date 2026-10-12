<?php
/**
 * Lida com todos os cálculos e lógicas relacionadas aos atributos dos usuários.
 */
class AttributeManager
{
    private PDO $pdo;
    private array $userData;

    // Definições de bônus para fácil configuração
    private const XP_BONUS_PER_POINT = 0.01; // +1% por ponto
    private const CHARISMA_DISCOUNT_PER_POINT = 0.01; // -1% por ponto
    private const MAX_CHARISMA_DISCOUNT = 0.20; // 20%
    private const SPIRITUALITY_GOLD_PER_DAY = 1; // 1 Ouro por dia
    private const SPIRITUALITY_POINTS_FOR_BONUS = 10; // A cada 10 pontos

    public function __construct(PDO $pdo, int $userId)
    {
        $this->pdo = $pdo;
        $stmt = $this->pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$userData) {
            throw new Exception("Usuário não encontrado ao instanciar AttributeManager.");
        }
        $this->userData = $userData;
    }

    /**
     * Calcula o XP final para uma tarefa, aplicando bônus de Inteligência ou Força.
     *
     * @param integer $baseXp O XP base da tarefa.
     * @param string|null $taskAttribute O atributo associado à tarefa (ex: 'inteligencia', 'forca').
     * @return integer O XP final, arredondado para o inteiro mais próximo.
     */
    public function calculateXpWithBonus(int $baseXp, ?string $taskAttribute): int
    {
        $bonusRate = 0;
        if ($taskAttribute === 'inteligencia') {
            $bonusRate = (int)$this->userData['inteligencia'] * self::XP_BONUS_PER_POINT;
        } elseif ($taskAttribute === 'forca') {
            $bonusRate = (int)$this->userData['forca'] * self::XP_BONUS_PER_POINT;
        }

        $finalXp = $baseXp * (1 + $bonusRate);
        return (int)round($finalXp);
    }

    /**
     * Calcula o preço final de um item com o desconto de Carisma.
     *
     * @param float $basePrice O preço original do item.
     * @return float O preço com desconto.
     */
    public function calculateDiscountedPrice(float $basePrice): float
    {
        $discountRate = (int)$this->userData['carisma'] * self::CHARISMA_DISCOUNT_PER_POINT;
        $discountRate = min($discountRate, self::MAX_CHARISMA_DISCOUNT); // Aplica o teto máximo de desconto

        $finalPrice = $basePrice * (1 - $discountRate);
        return $finalPrice;
    }

    /**
     * Concede um bônus diário de ouro com base na Espiritualidade.
     * A função verifica se o bônus já foi concedido hoje antes de aplicá-lo.
     *
     * @return array|null Retorna um array com os detalhes do bônus se concedido, caso contrário, null.
     */
    public function applyDailySpiritualityBonus(): ?array
    {
        $today = date('Y-m-d');
        $lastBonusDate = $this->userData['last_spirituality_bonus_at'] ?? null;

        if ($lastBonusDate === $today) {
            return null; // Bônus já concedido hoje
        }

        $spiritualityPoints = (int)$this->userData['espiritualidade'];
        if ($spiritualityPoints < self::SPIRITUALITY_POINTS_FOR_BONUS) {
            return null; // Pontos insuficientes
        }
        
        $goldBonus = floor($spiritualityPoints / self::SPIRITUALITY_POINTS_FOR_BONUS) * self::SPIRITUALITY_GOLD_PER_DAY;

        if ($goldBonus > 0) {
            $this->pdo->beginTransaction();
            try {
                // Adiciona o ouro
                $stmt = $this->pdo->prepare("UPDATE users SET gold = gold + ? WHERE id = ?");
                $stmt->execute([$goldBonus, $this->userData['id']]);

                // Atualiza a data do último bônus
                $stmt = $this->pdo->prepare("UPDATE users SET last_spirituality_bonus_at = ? WHERE id = ?");
                $stmt->execute([$today, $this->userData['id']]);
                
                $this->pdo->commit();

                return ['type' => 'gold', 'amount' => $goldBonus];
            } catch (Exception $e) {
                $this->pdo->rollBack();
                // Log do erro seria ideal aqui
                return null;
            }
        }
        
        return null;
    }

    /**
     * Verifica se o usuário pode usar o reset diário gratuito de Autoconsciência.
     *
     * @return boolean
     */
    public function canUseFreeReset(): bool
    {
        $selfAwarenessPoints = (int)$this->userData['autoconsciencia'];
        if ($selfAwarenessPoints <= 0) {
            return false;
        }

        $today = date('Y-m-d');
        $lastResetDate = $this->userData['last_free_reset_at'] ?? null;
        
        return $lastResetDate !== $today;
    }

    /**
     * Registra o uso do reset diário gratuito.
     */
    public function recordFreeResetUsage(): void
    {
        $today = date('Y-m-d');
        $stmt = $this->pdo->prepare("UPDATE users SET last_free_reset_at = ? WHERE id = ?");
        $stmt->execute([$today, $this->userData['id']]);
    }
}
