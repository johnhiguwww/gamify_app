import 'package:flutter/material.dart';
import '../models/api_task.dart';
import '../theme/app_colors.dart';

// #$ ApiTaskTile — versão do TaskTile que exibe uma ApiTask vinda da API real.
// Exibe título, frequência, XP e gold. O check togla completedInCurrentCycle
// localmente (sem chamada à API por enquanto, pois não há endpoint PATCH).
class ApiTaskTile extends StatelessWidget {
  final ApiTask task;
  final VoidCallback? onToggle;

  const ApiTaskTile({super.key, required this.task, this.onToggle});

  // #f _iconForFrequency — ícone genérico baseado na frequência da tarefa,
  // já que a API não armazena ícone customizado.
  IconData get _icon => switch (task.frequency) {
        'DIARIO' => Icons.today_rounded,
        'SEMANAL' => Icons.date_range_rounded,
        'MENSAL' => Icons.calendar_month_rounded,
        _ => Icons.check_circle_outline_rounded,
      };

  Color get _iconColor => task.partOfMission ? AppColors.danger : AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: _iconColor.withOpacity(0.18), shape: BoxShape.circle),
            child: Icon(_icon, color: _iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      task.frequencyLabel,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${task.experience} XP',
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                    const SizedBox(width: 2),
                    Text('${task.reward}', style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(color: task.isDone ? AppColors.primaryGreen : AppColors.border, width: 1.5),
              ),
              child: task.isDone ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
          ),
        ],
      ),
    );
  }
}
