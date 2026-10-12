import 'package:flutter/material.dart';
import '../models/attribute.dart';
import '../theme/app_colors.dart';
import 'gamify_progress_bar.dart';

// #$ AttributeRow — uma linha "Inteligência  Nível 4  [====----] 380/500".
class AttributeRow extends StatelessWidget {
  final AttributeProgress progress;
  final Color color;

  const AttributeRow({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(progress.type.icon, size: 18, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              progress.type.label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GamifyProgressBar(ratio: progress.ratio, color: color, height: 6),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nível ${progress.level}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('${progress.currentXp}/${progress.maxXp}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// #f attributeColor — mapeia AttributeType -> cor fixa da paleta.
Color attributeColor(AttributeType type) => switch (type) {
      AttributeType.inteligencia => AppColors.inteligencia,
      AttributeType.forca => AppColors.forca,
      AttributeType.espiritualidade => AppColors.espiritualidade,
      AttributeType.carisma => AppColors.carisma,
      AttributeType.percepcaoEspacial => AppColors.percepcaoEspacial,
      AttributeType.autoconsciencia => AppColors.autoconsciencia,
      AttributeType.linguagem => AppColors.linguagem,
      AttributeType.raciocinioLogico => AppColors.raciocinioLogico,
      AttributeType.musicalidade => AppColors.musicalidade,
    };

// #f attributeDisplayLabel — #!! nas Figuras 6/"Nova Missão"/"Nova Tarefa" o
// atributo Força aparece rotulado como "Saúde" (ícone de corrida); só no
// dashboard (Figura 3) ele aparece como "Força". Use esta função nas tags de
// missão/tarefa e mission.attribute.label (ou AttributeRow) no dashboard.
String attributeDisplayLabel(AttributeType type) =>
    type == AttributeType.forca ? 'Saúde' : type.label;
