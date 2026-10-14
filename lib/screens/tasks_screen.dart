import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/task_tile.dart';
import 'new_task_screen.dart';

// #!! Tela não fazia parte dos 6 prints recebidos — construída seguindo o
// mesmo padrão visual das outras telas pra fechar a navegação (aba "Tarefas").
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<GamifyTask> _tasks = List.of(MockData.tasksToday);

  void _toggle(GamifyTask task) {
    setState(() {
      _tasks = [
        for (final t in _tasks)
          if (t.id == task.id) t.copyWith(currentQuantity: t.isDone ? 0 : t.goalQuantity) else t,
      ];
    });
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
            ],
          ),
          const SizedBox(height: 4),
          const Text('Suas ações do dia a dia rumo à evolução.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < _tasks.length; i++) ...[
                    TaskTile(task: _tasks[i], onToggle: (_) => _toggle(_tasks[i])),
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
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewTaskScreen())),
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
