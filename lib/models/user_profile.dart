import './ranks.dart';
import './attribute.dart';

// #$ UserProfile — dados do cabeçalho do dashboard (Figura 3).
class UserProfile {
  final String name;
  //## Esse "rank" se refere as patentes
  final String rank; // #v ex: "Faixa Verde"
  final int globalLevel;
  // #v XP dentro do nível atual (ex: 76 de 150)
  final int currentXp;
  // #v XP necessário para completar o nível atual
  final int maxXp;
  final int gold;
  final String avatarUrl;
  final List<AttributeProgress> attributes;

  const UserProfile({
    required this.name,
    required this.rank,
    required this.globalLevel,
    required this.currentXp,
    required this.maxXp,
    required this.gold,
    required this.avatarUrl,
    this.attributes = const [],
  });

  int get xpToNextLevel => maxXp - currentXp;
  double get ratio => maxXp == 0 ? 0 : (currentXp / maxXp).clamp(0, 1);

  // #f fromApi — monta o UserProfile a partir do JSON devolvido pela API
  // Java (campos: userId, email, name, avatarUrl, level, experience, gold,
  // atributes).
  // #!! a API NÃO sobe o "level" (fica sempre 1) e "experience" é o XP TOTAL
  // acumulado (só de missões). Por isso o nível é calculado AQUI, a partir
  // do XP total. Regra do app, não da API (citar no TCC).
  factory UserProfile.fromApi(Map<String, dynamic> json) {
    final totalXp = (json['experience'] as num?)?.toInt() ?? 0;
    // #v nível e XP dentro do nível, calculados a partir do XP total
    final calc = _levelFromTotalXp(totalXp);

    // #v atributo do app -> chave dentro de json['atributes'] (grafia da API)
    const keys = {
      AttributeType.inteligencia: 'intelligence',
      AttributeType.forca: 'strength',
      AttributeType.espiritualidade: 'spirituality',
      AttributeType.carisma: 'charisma',
      AttributeType.percepcaoEspacial: 'spatialPerception',
      AttributeType.autoconsciencia: 'selfAwareness',
      AttributeType.linguagem: 'language',
      AttributeType.raciocinioLogico: 'logicalReasoning',
      AttributeType.musicalidade: 'musicality',
    };
    final attrs = (json['atributes'] as Map<String, dynamic>?) ?? {};
    final progress = [
      for (final t in AttributeType.values)
        AttributeProgress(type: t, total: (attrs[keys[t]] as num?)?.toInt() ?? 0),
    ];
    return UserProfile(
      name: (json['name'] as String?) ?? 'Jogador',
      rank: _rankForLevel(calc.level),
      globalLevel: calc.level,
      currentXp: calc.xpInLevel,
      maxXp: _maxXpForLevel(calc.level),
      gold: (json['gold'] as num?)?.toInt() ?? 0,
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
      attributes: progress,
    );
  }

  // #f _maxXpForLevel — XP necessário para completar um nível
  // ## nível 1 = 100, nível 2 = 110, nível 3 = 120 (de 10 em 10)
  // #p level: nível (começa em 1)
  // #r int com o XP necessário naquele nível
  static int _maxXpForLevel(int level) => 100 + (level - 1) * 10;

  // #f _levelFromTotalXp — converte o XP total em nível + XP dentro do nível
  // #p totalXp: XP total acumulado (campo experience da API)
  // #r registro com o nível e o XP que sobrou dentro dele
  static ({int level, int xpInLevel}) _levelFromTotalXp(int totalXp) {
    // #v começa no nível 1 com todo o XP ainda para distribuir
    int level = 1;
    int remaining = totalXp < 0 ? 0 : totalXp;
    // #wh enquanto o XP restante completa o nível atual, sobe de nível
    while (remaining >= _maxXpForLevel(level)) {
      remaining -= _maxXpForLevel(level);
      level++;
    }
    return (level: level, xpInLevel: remaining);
  }

  // #f _rankForLevel — nome da patente exibida conforme o nível.
  // #p level: nível atual do usuário (int)
  // #r String com o nome da patente
  // ## um rank por nível: nível 1 = Faixa Branca, nível 2 = Faixa Cinza,
  // nível 3 = Faixa Amarela... (posição = nível - 1 na lista kRanks)
  static String _rankForLevel(int level) {
    // #v index: nível 1 cai na posição 0, nível 2 na posição 1
    final int index = level - 1;

    // #if nível baixo demais (ou inválido): trava na primeira patente
    if (index < 0) return kRanks.first;

    // #if nível acima do fim da lista: trava na última patente
    if (index >= kRanks.length) return kRanks.last;

    // ## Caso normal: o índice é válido, basta consultar a lista
    return kRanks[index];
  }
}