import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/task_tile.dart';
import 'new_task_screen.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';

// #$ TasksScreen — aba "Tarefas"
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<GamifyTask> _tasks = [];
  bool _loading = true;
  String? _error;
  // #v id da tarefa sendo concluída (trava cliques repetidos)
  String? _completingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // #f _load — busca as tarefas do usuário logado na API
  Future<void> _load() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Sessão expirada, faça login novamente.';
      });
      return;
    }
    try {
      final tasks = await GamifyApiService.instance.fetchTasks(userId);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar as tarefas: $e';
        _loading = false;
      });
    }
  }

  // #f _complete — POST /tasks/complete (a única rota de concluir tarefa)
  // #!! a API encerra a tarefa de vez; o perfil devolvido atualiza o cabeçalho
  Future<void> _complete(GamifyTask task) async {
    // #if já concluída ou outra conclusão em andamento: não faz nada
    if (task.isDone || _completingId != null) return;
    setState(() => _completingId = task.id);
    try {
      await GamifyApiService.instance.completeTask(task.id);
      await _load();
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
      if (mounted) setState(() => _completingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('Tarefas',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Suas ações do dia a dia rumo à evolução.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5))
          else if (_tasks.isEmpty)
            const Text('Nenhuma tarefa ainda.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5))
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < _tasks.length; i++) ...[
                      TaskTile(task: _tasks[i], onToggle: (_) => _complete(_tasks[i])),
                      if (i != _tasks.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NewTaskScreen()))
                  .then((_) => _load()),
              icon: const Icon(Icons.add, color: AppColors.primaryGreen),
              label: const Text('Nova Tarefa',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}