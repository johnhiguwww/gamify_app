import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

// #$ TaskTile — linha com ícone, título, frequência, recompensa e check de conclusão.
class TaskTile extends StatelessWidget {
  // #v tarefa exibida
  final GamifyTask task;
  // #p onToggle: chamado ao tocar no check
  final ValueChanged<bool>? onToggle;

  const TaskTile({super.key, required this.task, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: task.iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(task.icon, color: task.iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                // #!! Wrap em vez de Row: em cartões estreitos (dashboard, ~120 px)
                // o que não cabe desce para a linha de baixo, sem estourar.
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(task.frequency.label,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('+${task.xpReward} XP',
                        style: const TextStyle(
                            color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                    // ## ícone + número ficam juntos, para nunca se separarem
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                        const SizedBox(width: 2),
                        Text('${task.goldReward}',
                            style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onToggle?.call(!task.isDone),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                    color: task.isDone ? AppColors.primaryGreen : AppColors.border, width: 1.5),
              ),
              child: task.isDone ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
          ),
        ],
      ),
    );
  }
}