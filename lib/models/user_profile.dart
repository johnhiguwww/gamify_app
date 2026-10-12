// #$ UserProfile — dados do cabeçalho do dashboard (Figura 3).
class UserProfile {
  final String name;
  final String rank; // #v ex: "Faixa Verde"
  final int globalLevel;
  final int currentXp;
  final int maxXp;
  final int gold;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.rank,
    required this.globalLevel,
    required this.currentXp,
    required this.maxXp,
    required this.gold,
    required this.avatarUrl,
  });

  int get xpToNextLevel => maxXp - currentXp;
  double get ratio => maxXp == 0 ? 0 : (currentXp / maxXp).clamp(0, 1);

  // #f fromApi — monta o UserProfile a partir do JSON devolvido pela API
  // Java (campos: userId, email, name, avatarUrl, level, experience, gold,
  // atributes). A API não guarda "rank" nem "maxXp" prontos, então
  // calculamos aqui a partir do nível.
  factory UserProfile.fromApi(Map<String, dynamic> json) {
    final level = (json['level'] as num?)?.toInt() ?? 1;
    final experience = (json['experience'] as num?)?.toInt() ?? 0;
    return UserProfile(
      name: (json['name'] as String?) ?? 'Jogador',
      rank: _rankForLevel(level),
      globalLevel: level,
      currentXp: experience,
      maxXp: _maxXpForLevel(level),
      gold: (json['gold'] as num?)?.toInt() ?? 0,
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
    );
  }

  // #f _maxXpForLevel — fórmula simples de XP necessário por nível
  // (ajuste livremente conforme o balanceamento do jogo).
  static int _maxXpForLevel(int level) => 100 + (level - 1) * 50;

  // #f _rankForLevel — nome de "faixa" exibido conforme o nível.
  static String _rankForLevel(int level) {
    if (level >= 20) return 'Mestre';
    if (level >= 10) return 'Aventureiro';
    if (level >= 5) return 'Aprendiz';
    return 'Iniciante';
  }
}
