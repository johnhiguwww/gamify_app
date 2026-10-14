import './ranks.dart';

// #$ UserProfile — dados do cabeçalho do dashboard (Figura 3).
class UserProfile {
  final String name;
  //## Esse "rank" se refere as patentes
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
  //TODO - Se por acaso a API não fizer esse calculo colocar
  static int _maxXpForLevel(int level) => 100 + (level - 1) * 10;

  // #P _rankForLevel — nome de "faixa" exibido conforme o nível.
  // #f Devolve a patente correspondente ao nível informado
  // #p level: nível atual do usuário (int)
  // #r String com o nome da patente
  static String _rankForLevel(int level) {
    // #v index: 110 cai no 0 e 111 no 1
    final int index = (level - 101) ~/ 10;

    // #if nível baixo demais (ou inválido): trava na primeira patente
    if (index < 0) return kRanks.first;

    // #if nível acima do último teto (4110): trava na última patente
    if (index >= kRanks.length) return kRanks.last;

    // ## Caso normal: o índice é válido, basta consultar a lista
    return kRanks[index];
  }
}
