import 'package:flutter/material.dart';
import 'ranks.dart';

// #$ RankStyle — aparência do selo de uma patente (cor, ícone e família)
// #!! REGRA DO APP (não existe na API): a cor e o ícone saem do nome da
// patente / da posição dela na lista kRanks (lib/models/ranks.dart).
// ## ranks.dart é gerado automaticamente; por isso o estilo fica neste arquivo.
class RankStyle {
  // #v nome da família (ex.: "Faixas", "Metais", "Nobreza")
  final String family;
  // #v ícone da família, mostrado no selo
  final IconData icon;
  // #v cor do texto e do ícone
  final Color foreground;
  // #v cor de fundo da pílula
  final Color background;
  // #v cor da borda da pílula
  final Color border;

  const RankStyle({
    required this.family,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  // #f tinted — estilo "padrão": fundo e borda são a própria cor, mais claros
  // #p family: nome da família; icon: ícone; color: cor principal
  // #r RankStyle pronto
  factory RankStyle.tinted(String family, IconData icon, Color color) => RankStyle(
        family: family,
        icon: icon,
        foreground: color,
        background: color.withValues(alpha: 0.16),
        border: color.withValues(alpha: 0.55),
      );
}

// #v ícones de cada família de patentes
const IconData _beltIcon = Icons.sports_martial_arts; // ## Faixas (artes marciais)
const IconData _metalIcon = Icons.shield; // ## Ferro → Diamante
const IconData _diamondIcon = Icons.diamond; // ## Diamante tem ícone próprio
const IconData _eliteIcon = Icons.emoji_events; // ## Mestre → Deus do Jogo (troféu)
const IconData _militaryIcon = Icons.military_tech; // ## Recruta → Senescal (medalha)
const IconData _nobilityIcon = Icons.workspace_premium; // ## Plebeu → Imperador (coroa/selo)
const IconData _legendIcon = Icons.auto_awesome; // ## títulos lendários (o resto da lista)

// #v posições (índices em kRanks) onde cada família COMEÇA
// ## conferido em ranks.dart: 0 Faixa Branca, 9 Ferro IV (faixas e metais
// são reconhecidos pelo nome), 33 Mestre,
// 41 Recruta, 72 Plebeu, 110 em diante = títulos lendários
const int _eliteStart = 33;
const int _militaryStart = 41;
const int _nobilityStart = 72;
const int _legendsStart = 110;

// #f rankStyleFor — devolve a aparência do selo para uma patente
// #p rank: nome da patente (ex.: "Faixa Roxa")
// #r RankStyle com cor, ícone e família
RankStyle rankStyleFor(String rank) {
  // ===================== FAIXAS (cada faixa com a sua cor) =====================
  // #if é uma faixa: a cor é a da própria faixa
  if (rank.startsWith('Faixa')) {
    return switch (rank) {
      // ## branca: texto branco, fundo cinza bem leve
      'Faixa Branca' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFFF5F5F5)),
      'Faixa Cinza' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFF9CA3AF)),
      'Faixa Amarela' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFFFACC15)),
      'Faixa Laranja' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFFF97316)),
      'Faixa Verde' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFF22C55E)),
      'Faixa Azul' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFF3B82F6)),
      'Faixa Roxa' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFFA855F7)),
      'Faixa Marrom' => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFFB45309)),
      // ## preta: fundo preto de verdade com texto e borda brancos
      'Faixa Preta' => const RankStyle(
          family: 'Faixas',
          icon: _beltIcon,
          foreground: Colors.white,
          background: Colors.black,
          border: Colors.white70,
        ),
      // #else faixa desconhecida: cinza
      _ => RankStyle.tinted('Faixas', _beltIcon, const Color(0xFF9CA3AF)),
    };
  }

  // ===================== METAIS (cor do metal) =====================
  // #if Ferro / Bronze / Prata / Ouro / Platina / Diamante
  if (rank.startsWith('Ferro')) return RankStyle.tinted('Metais', _metalIcon, const Color(0xFF94A3B8));
  if (rank.startsWith('Bronze')) return RankStyle.tinted('Metais', _metalIcon, const Color(0xFFCD7F32));
  if (rank.startsWith('Prata')) return RankStyle.tinted('Metais', _metalIcon, const Color(0xFFD1D5DB));
  if (rank.startsWith('Ouro')) return RankStyle.tinted('Metais', _metalIcon, const Color(0xFFFBBF24));
  if (rank.startsWith('Platina')) return RankStyle.tinted('Metais', _metalIcon, const Color(0xFF5EEAD4));
  if (rank.startsWith('Diamante')) return RankStyle.tinted('Metais', _diamondIcon, const Color(0xFF7DD3FC));

  // ===================== DEMAIS FAMÍLIAS (pela posição na lista) =====================
  // #v posição da patente na lista (−1 se o nome não estiver na lista)
  // #!! "Imperador" aparece duas vezes na lista: indexOf pega a primeira (nobreza)
  final index = kRanks.indexOf(rank);

  // #if patente de elite (Mestre → Deus do Jogo): troféu roxo-avermelhado
  if (index >= _eliteStart && index < _militaryStart) {
    return RankStyle.tinted('Elite', _eliteIcon, const Color(0xFFF43F5E));
  }
  // #elseif militar (Recruta → Senescal): medalha verde-oliva
  if (index >= _militaryStart && index < _nobilityStart) {
    return RankStyle.tinted('Militar', _militaryIcon, const Color(0xFF84CC16));
  }
  // #elseif nobreza (Plebeu → Imperador): selo dourado
  if (index >= _nobilityStart && index < _legendsStart) {
    return RankStyle.tinted('Nobreza', _nobilityIcon, const Color(0xFFEAB308));
  }
  // #elseif títulos lendários (o fim da lista): brilho laranja
  if (index >= _legendsStart) {
    return RankStyle.tinted('Lendas', _legendIcon, const Color(0xFFFB923C));
  }
  // #else nome desconhecido: cinza neutro
  return RankStyle.tinted('Patente', Icons.eco, const Color(0xFF9CA3AF));
}

// #f nextRankFor — nome da próxima patente
// #p level: nível global atual (começa em 1; a patente do nível N é kRanks[N-1])
// #r nome da próxima patente, ou null se já está na última
String? nextRankFor(int level) {
  // #if o próximo nível ainda existe na lista: devolve o nome dele
  if (level >= 1 && level < kRanks.length) return kRanks[level];
  // #else já está na última patente (ou nível inválido)
  return null;
}
