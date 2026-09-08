import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/current_user.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_row.dart';
import '../widgets/gamify_progress_bar.dart';
import '../widgets/mission_card.dart';
import '../widgets/section_card.dart';
import '../widgets/task_tile.dart';
import 'new_mission_screen.dart';
import 'new_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAllMissions;
  final VoidCallback? onSeeAllTasks;

  const DashboardScreen({super.key, this.onSeeAllMissions, this.onSeeAllTasks});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // #v cópia local só pra permitir marcar tarefa como feita na demo;
  // #t trocar por state management real (Provider/Riverpod) na integração.
  List<GamifyTask> _tasks = List.of(MockData.tasksToday);

  // #f _toggleTask — alterna a tarefa entre 0 e a meta (concluída/pendente).
  void _toggleTask(GamifyTask task) {
    setState(() {
      _tasks = [
        for (final t in _tasks)
          if (t.id == task.id)
            t.copyWith(currentQuantity: t.isDone ? 0 : t.goalQuantity)
          else
            t,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.profile ?? MockData.user;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Header(user: user),
          const SizedBox(height: 16),
          _XpCard(user: user),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionCard(
                  icon: Icons.track_changes_rounded,
                  iconColor: AppColors.danger,
                  title: 'Missões Ativas',
                  onSeeAll: widget.onSeeAllMissions,
                  child: Column(
                    children: [
                      for (final m in MockData.missions.take(3))
                        MissionCard(mission: m),
                      const SizedBox(height: 4),
                      _AddLink(
                        label: '+ Nova Missão',
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const NewMissionScreen())),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionCard(
                  icon: Icons.checklist_rounded,
                  iconColor: AppColors.primaryGreen,
                  title: 'Tarefas do Dia',
                  onSeeAll: widget.onSeeAllTasks,
                  child: Column(
                    children: [
                      for (final t in _tasks)
                        TaskTile(task: t, onToggle: (_) => _toggleTask(t)),
                      const SizedBox(height: 4),
                      _AddLink(
                        label: '+ Nova Tarefa',
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const NewTaskScreen())),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SectionCard(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.inteligencia,
            title: 'Atributos',
            onSeeAll: () {},
            child: Column(
              children: [
                for (final a in MockData.attributes)
                  AttributeRow(progress: a, color: attributeColor(a.type)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProfile user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.surfaceAlt,
          child: Text(user.name.substring(0, 1), style: const TextStyle(fontSize: 22, color: AppColors.primaryGreen)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              Row(children: [
                const Icon(Icons.eco, color: AppColors.primaryGreen, size: 13),
                const SizedBox(width: 4),
                Text(user.rank, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
              ]),
              Text('Nível Global', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        _LevelBadge(level: user.globalLevel),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(children: [
              const Icon(Icons.monetization_on, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text('${user.gold}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
            ]),
            const Text('Gold', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: Text('$level', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800)),
    );
  }
}

class _XpCard extends StatelessWidget {
  final UserProfile user;
  const _XpCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${user.currentXp} / ${user.maxXp} XP',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                      Text('Faltam ${user.xpToNextLevel} XP',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GamifyProgressBar(ratio: user.ratio, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.emoji_events, color: AppColors.gold, size: 30),
          ],
        ),
      ),
    );
  }
}

class _AddLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12.5)),
      ),
    );
  }
}
