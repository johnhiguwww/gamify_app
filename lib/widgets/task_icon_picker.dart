import 'package:flutter/material.dart';
import '../data/task_icons.dart';
import '../theme/app_colors.dart';

// #$ TaskIconPicker — grade de ícones para escolher o ícone de uma tarefa
// ## mesmo visual do StoreIconPicker (loja)
class TaskIconPicker extends StatelessWidget {
  // #p selectedKey: chave do ícone escolhido
  final String selectedKey;
  // #p onChanged: chamado com a chave do ícone tocado
  final ValueChanged<String> onChanged;

  const TaskIconPicker({super.key, required this.selectedKey, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // #wh (for) um quadradinho para cada ícone disponível
        for (final o in taskIconOptions)
          GestureDetector(
            onTap: () => onChanged(o.key),
            child: Tooltip(
              message: o.label,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: o.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    // ## o ícone escolhido ganha borda verde mais grossa
                    color: o.key == selectedKey ? AppColors.primaryGreen : AppColors.border,
                    width: o.key == selectedKey ? 2 : 1,
                  ),
                ),
                child: Icon(o.icon, color: o.color, size: 20),
              ),
            ),
          ),
      ],
    );
  }
}
