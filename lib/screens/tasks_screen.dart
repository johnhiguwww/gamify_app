import 'package:flutter/material.dart';
import '../models/api_task.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/api_task_tile.dart';
import 'new_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<ApiTask> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final userId = CurrentUser.userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final tasks = await GamifyApiService.instance.fetchTasks(userId);
      if (mounted) setState(() { _tasks = tasks; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              const Text('Tarefas', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (_loading)
                const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2),
                ),
              if (!_loading)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                  onPressed: () { setState(() => _loading = true); _loadTasks(); },
                  tooltip: 'Atualizar',
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Suas ações do dia a dia rumo à evolução.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          else if (_tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Nenhuma tarefa ainda.\nCrie uma nova clicando abaixo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < _tasks.length; i++) ...[
                      ApiTaskTile(task: _tasks[i]),
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
                  .then((_) { setState(() => _loading = true); _loadTasks(); }),
              icon: const Icon(Icons.add, color: AppColors.primaryGreen),
              label: const Text('Nova Tarefa', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
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
