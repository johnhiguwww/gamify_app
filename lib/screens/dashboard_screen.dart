import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/api_mission.dart';
import '../models/api_task.dart';
import '../models/user_profile.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/api_task_tile.dart';
import '../widgets/attribute_row.dart';
import '../widgets/gamify_progress_bar.dart';
import '../widgets/mission_card.dart';
import '../widgets/section_card.dart';
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
  List<ApiTask> _tasks = [];
  List<ApiMission> _missions = [];
  bool _loadingTasks = true;
  bool _loadingMissions = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = CurrentUser.profile == null ? null : _resolveUserId();
    if (userId == null) {
      if (mounted) setState(() { _loadingTasks = false; _loadingMissions = false; });
      return;
    }
    _fetchTasks(userId);
    _fetchMissions(userId);
  }

  // #f _resolveUserId — recupera o userId da sessão atual armazenado em
  // CurrentUser. Como CurrentUser.profile é populado pelo AuthGate com o
  // UUID do Supabase, precisamos lê-lo de lá; o profile em si não guarda o
  // userId, então buscamos via AuthService diretamente.
  String? _resolveUserId() {
    // importar AuthService aqui seria um ciclo; em vez disso usamos o userId
    // que o AuthGate já colocou no CurrentUser via fetchProfile.
    // A forma mais simples: reutilizar a chave que o AuthGate passou ao
    // criar o perfil. Como não armazenamos userId no UserProfile por ora,
    // precisamos buscar via Supabase — mas evitamos importar aqui.
    // Solução pragmática: CurrentUser expõe userId separado.
    return CurrentUser.userId;
  }

  Future<void> _fetchTasks(String userId) async {
    try {
      final tasks = await GamifyApiService.instance.fetchTasks(userId);
      if (mounted) setState(() { _tasks = tasks; _loadingTasks = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  Future<void> _fetchMissions(String userId) async {
    try {
      final missions = await GamifyApiService.instance.fetchMissions(userId);
      if (mounted) setState(() { _missions = missions; _loadingMissions = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMissions = false);
    }
  }

  // #f _reloadAfterCreate — chamado quando volta da tela de criação pra
  // recarregar lista sem precisar de state management externo.
  Future<void> _reloadAfterCreate() async {
    final userId = _resolveUserId();
    if (userId == null) return;
    setState(() { _loadingTasks = true; _loadingMissions = true; });
    _fetchTasks(userId);
    _fetchMissions(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.profile ?? MockData.user;
    final attributes = user.attributes ?? MockData.attributes;

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
              // ── Missões ──────────────────────────────────────────────
              Expanded(
                child: SectionCard(
                  icon: Icons.track_changes_rounded,
                  iconColor: AppColors.danger,
                  title: 'Missões Ativas',
                  onSeeAll: widget.onSeeAllMissions,
                  child: _loadingMissions
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)),
                        )
                      : Column(
                          children: [
                            if (_missions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Nenhuma missão ativa.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              )
                            else
                              for (final m in _missions.take(3))
                                _ApiMissionCard(mission: m),
                            const SizedBox(height: 4),
                            _AddLink(
                              label: '+ Nova Missão',
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const NewMissionScreen()))
                                  .then((_) => _reloadAfterCreate()),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // ── Tarefas ───────────────────────────────────────────────
              Expanded(
                child: SectionCard(
                  icon: Icons.checklist_rounded,
                  iconColor: AppColors.primaryGreen,
                  title: 'Tarefas do Dia',
                  onSeeAll: widget.onSeeAllTasks,
                  child: _loadingTasks
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)),
                        )
                      : Column(
                          children: [
                            if (_tasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Nenhuma tarefa ainda.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              )
                            else
                              for (final t in _tasks)
                                ApiTaskTile(task: t),
                            const SizedBox(height: 4),
                            _AddLink(
                              label: '+ Nova Tarefa',
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const NewTaskScreen()))
                                  .then((_) => _reloadAfterCreate()),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Atributos ─────────────────────────────────────────────────
          SectionCard(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.inteligencia,
            title: 'Atributos',
            onSeeAll: () {},
            child: Column(
              children: [
                for (final a in attributes)
                  AttributeRow(progress: a, color: attributeColor(a.type)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _ApiMissionCard extends StatelessWidget {
  final ApiMission mission;
  const _ApiMissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded, color: AppColors.danger, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    color: mission.finished ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: mission.finished ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Text('+${mission.experience} XP',
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                  const SizedBox(width: 2),
                  Text('${mission.reward}', style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                ]),
              ],
            ),
          ),
          if (mission.finished)
            const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
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
              const Text('Nível Global', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
