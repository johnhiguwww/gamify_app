import '../models/attribute.dart';

// #$ UserProfile — dados do cabeçalho do dashboard (Figura 3).
class UserProfile {
  final String name;
  final String rank; // #v ex: "Faixa Verde"
  final int globalLevel;
  final int currentXp;
  final int maxXp;
  final int gold;
  final String avatarUrl;
  // #v atributos vindos da API; null = não carregados ainda (usa mock)
  final List<AttributeProgress>? attributes;

  const UserProfile({
    required this.name,
    required this.rank,
    required this.globalLevel,
    required this.currentXp,
    required this.maxXp,
    required this.gold,
    required this.avatarUrl,
    this.attributes,
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
      attributes: _parseAttributes(json['atributes'] as Map<String, dynamic>?),
    );
  }

  // #f _parseAttributes — converte o campo `atributes` do JSON da API nos
  // 9 AttributeProgress usados pelo Dashboard. Valores zerados = nível 1 com
  // XP 0, pois a API armazena só os pontos brutos, sem nível por atributo.
  static List<AttributeProgress>? _parseAttributes(Map<String, dynamic>? a) {
    if (a == null) return null;
    int toInt(String key) => (a[key] as num?)?.toInt() ?? 0;

    return [
      _attr(AttributeType.inteligencia, toInt('intelligence')),
      _attr(AttributeType.forca, toInt('strength')),
      _attr(AttributeType.espiritualidade, toInt('spirituality')),
      _attr(AttributeType.carisma, toInt('charisma')),
      _attr(AttributeType.percepcaoEspacial, toInt('spatialPerception')),
      _attr(AttributeType.autoconsciencia, toInt('selfAwareness')),
      _attr(AttributeType.linguagem, toInt('language')),
      _attr(AttributeType.raciocinioLogico, toInt('logicalReasoning')),
      _attr(AttributeType.musicalidade, toInt('musicality')),
    ];
  }

  // #f _attr — monta um AttributeProgress a partir dos pontos brutos.
  // Fórmula: nível = pontos ÷ 100 (mín 1); maxXp do nível = 100*(nível).
  static AttributeProgress _attr(AttributeType type, int points) {
    final level = (points ~/ 100).clamp(1, 99);
    final maxXp = level * 100;
    final currentXp = points - (level - 1) * 100;
    return AttributeProgress(type: type, level: level, currentXp: currentXp, maxXp: maxXp);
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
