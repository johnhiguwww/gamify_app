import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../theme/app_colors.dart';
import 'attribute_row.dart';
import 'gamify_progress_bar.dart';

// #$ MissionCard — detailed=false é a versão mini usada no dashboard
// (Figura 3); detailed=true é a linha completa da tela Missões (Figura 6).
class MissionCard extends StatelessWidget {
  final Mission mission;
  final bool detailed;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const MissionCard({
    super.key,
    required this.mission,
    this.detailed = false,
    this.onTap,
    this.onMenuTap,
  });

  Color get _difficultyColor => switch (mission.difficulty) {
        MissionDifficulty.facil => AppColors.facil,
        MissionDifficulty.media => AppColors.media,
        MissionDifficulty.alta => AppColors.alta,
      };

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: detailed ? 12 : 8, horizontal: detailed ? 4 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: mission.iconColor.withOpacity(0.18), shape: BoxShape.circle),
            child: Icon(mission.icon, color: mission.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(mission.title,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ),
                    if (detailed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+${mission.xpReward} XP',
                              style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                          Row(children: [
                            const Icon(Icons.monetization_on, color: AppColors.gold, size: 13),
                            const SizedBox(width: 3),
                            Text('${mission.goldReward}', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                          ]),
                        ],
                      )
                    else if (onMenuTap != null)
                      IconButton(
                        onPressed: onMenuTap,
                        icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                if (detailed) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(attributeDisplayLabel(mission.attribute),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: _difficultyColor, shape: BoxShape.circle)),
                      Text(mission.difficulty.label, style: TextStyle(color: _difficultyColor, fontSize: 11.5)),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                GamifyProgressBar(ratio: mission.progress, height: 6),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(mission.progress * 100).round()}%',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    if (detailed)
                      Text('${mission.daysLeft} dias restantes',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))
                    else
                      Row(children: [
                        Text('+${mission.xpReward} XP',
                            style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                        const SizedBox(width: 2),
                        Text('${mission.goldReward}', style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                      ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!detailed) return content;
    return InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: content);
  }
}
