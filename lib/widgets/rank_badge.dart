import 'package:flutter/material.dart';
import '../models/rank_style.dart';
import '../theme/app_colors.dart';

// #$ RankBadge — selo da patente em formato de pílula + linha da próxima patente
// ## (1) cor da própria patente, (2) ícone da família, (3) pílula,
// (4) "Próxima: X · faltam N XP"
// #!! tudo regra do app: a API não tem patente (ver rank_style.dart)
class RankBadge extends StatelessWidget {
  // #p rank: patente atual (ex.: "Faixa Roxa")
  final String rank;
  // #p level: nível global atual (usado para achar a próxima patente)
  final int level;
  // #p xpToNext: XP que falta para o próximo nível (= próxima patente)
  final int xpToNext;
  // #p center: true centraliza o selo e a linha de baixo (tela de Perfil)
  final bool center;

  const RankBadge({
    super.key,
    required this.rank,
    required this.level,
    required this.xpToNext,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    // #v cor, ícone e família da patente atual
    final style = rankStyleFor(rank);
    // #v nome da próxima patente (null = já está na última)
    final next = nextRankFor(level);

    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ## (3) pílula com fundo, borda e texto na cor da patente
        Tooltip(
          message: 'Família: ${style.family}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ## (2) ícone da família da patente
                Icon(style.icon, color: style.foreground, size: 13),
                const SizedBox(width: 4),
                // ## (1) nome na cor da patente; nomes longos cortam com "..."
                Flexible(
                  child: Text(
                    rank,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: style.foreground, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 3),
        // ## (4) próxima patente e quanto XP falta (ou aviso de última patente)
        Text(
          next == null ? 'Patente máxima alcançada' : 'Próxima: $next · faltam $xpToNext XP',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
      ],
    );
  }
}
