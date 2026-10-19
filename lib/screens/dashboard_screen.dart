import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/mission.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_row.dart';
import '../widgets/gamify_progress_bar.dart';
import '../widgets/mission_card.dart';
import '../widgets/section_card.dart';
import '../widgets/task_tile.dart';
import 'new_mission_screen.dart';
import 'new_task_screen.dart';

// #$ DashboardScreen — tela inicial
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAllMissions;
  final VoidCallback? onSeeAllTasks;

  const DashboardScreen({super.key, this.onSeeAllMissions, this.onSeeAllTasks});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // #v missões ativas vindas da API (máx. 3)
  List<Mission> _missions = [];
  bool _loadingMissions = true;
  String? _missionsError;

  // #v tarefas pendentes vindas da API (máx. 4)
  List<GamifyTask> _tasks = [];
  bool _loadingTasks = true;
  String? _tasksError;
  // #v id da tarefa sendo concluída (trava cliques repetidos)
  String? _completingTaskId;

  @override
  void initState() {
    super.initState();
    _loadMissions();
    _loadTasks();
  }

  // #f _loadMissions — GET /profiles/{userUuid}/my_missions, só as não concluídas
  Future<void> _loadMissions() async {
    setState(() {
      _loadingMissions = true;
      _missionsError = null;
    });
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      final all = await GamifyApiService.instance.fetchMissions(userId);
      // ## "ativa" = finished false na API
      final active = all.where((m) => m.status == MissionStatus.ativa).take(3).toList();
      if (mounted) setState(() => _missions = active);
    } catch (e) {
      if (mounted) setState(() => _missionsError = 'Erro ao carregar missões');
    } finally {
      if (mounted) setState(() => _loadingMissions = false);
    }
  }

  // #f _loadTasks — GET /profiles/{uuid}/my_tasks, só as pendentes
  Future<void> _loadTasks() async {
    setState(() {
      _loadingTasks = true;
      _tasksError = null;
    });
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      final all = await GamifyApiService.instance.fetchTasks(userId);
      // ## pendente = finished "PENDING" e completedInCurrentCycle false
      final pending = all.where((t) => !t.isDone).take(4).toList();
      if (mounted) setState(() => _tasks = pending);
    } catch (e) {
      if (mounted) setState(() => _tasksError = 'Erro ao carregar tarefas');
    } finally {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  // #f _completeTask — POST /tasks/complete e recarrega a lista
  // #!! a API encerra a tarefa de vez; o cabeçalho atualiza pelo CurrentUser
  Future<void> _completeTask(GamifyTask task) async {
    // #if já tem uma conclusão em andamento: não faz nada
    if (_completingTaskId != null) return;
    setState(() => _completingTaskId = task.id);
    try {
      await GamifyApiService.instance.completeTask(task.id);
      await _loadTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarefa concluída! +${task.xpReward} XP e +${task.goldReward} de ouro')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível concluir a tarefa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _completingTaskId = null);
    }
  }

  // #f _openNewMission — abre a Nova Missão e recarrega a lista ao voltar
  Future<void> _openNewMission() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NewMissionScreen()));
    if (mounted) _loadMissions();
  }

  // #f _openNewTask — abre a Nova Tarefa e recarrega a lista ao voltar
  Future<void> _openNewTask() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NewTaskScreen()));
    if (mounted) _loadTasks();
  }

  // #f _missionsBody — carregando, erro, vazio ou a lista
  Widget _missionsBody() {
    // #if carregando
    if (_loadingMissions) return const _Loading();
    // #if erro
    if (_missionsError != null) return _EmptyHint(text: _missionsError!);
    // #if vazio
    if (_missions.isEmpty) return const _EmptyHint(text: 'Nenhuma missão');
    return Column(children: [for (final m in _missions) MissionCard(mission: m)]);
  }

  // #f _tasksBody — carregando, erro, vazio ou a lista
  Widget _tasksBody() {
    // #if carregando
    if (_loadingTasks) return const _Loading();
    // #if erro
    if (_tasksError != null) return _EmptyHint(text: _tasksError!);
    // #if vazio
    if (_tasks.isEmpty) return const _EmptyHint(text: 'Nenhuma tarefa');
    return Column(
      children: [
        for (final t in _tasks) TaskTile(task: t, onToggle: (_) => _completeTask(t)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ## redesenha sozinho quando o CurrentUser.profile muda (XP, ouro, nível)
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: CurrentUser.notifier,
      builder: (context, profile, _) {
        final user = profile ?? MockData.user;

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
                          _missionsBody(),
                          const SizedBox(height: 4),
                          _AddLink(label: '+ Nova Missão', onTap: _openNewMission),
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
                          _tasksBody(),
                          const SizedBox(height: 4),
                          _AddLink(label: '+ Nova Tarefa', onTap: _openNewTask),
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
                    // ## atributos reais do perfil (campo `atributes` da API)
                    for (final a in user.attributes)
                      AttributeRow(progress: a, color: attributeColor(a.type)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// #$ _Loading — indicador pequeno para os cartões
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}

// #$ _EmptyHint — texto discreto para estados vazios
class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
          child: Text(user.name.substring(0, 1),
              style: const TextStyle(fontSize: 22, color: AppColors.primaryGreen)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              Row(children: [
                const Icon(Icons.eco, color: AppColors.primaryGreen, size: 13),
                const SizedBox(width: 4),
                Text(user.rank,
                    style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
              ]),
              const Text('Nível Global',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
              Text('${user.gold}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
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
      child: Text('$level',
          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800)),
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
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
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
        child: Text(label,
            style: const TextStyle(
                color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12.5)),
      ),
    );
  }
}