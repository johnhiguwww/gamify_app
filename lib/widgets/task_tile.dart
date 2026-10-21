import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

<<<<<<< Updated upstream
// #$ TaskTile — linha com ícone, título, progresso "2/3" e check de conclusão.
=======
// #$ TaskTile — linha com ícone, título, frequência, recompensa, botão de editar
// (opcional) e check de conclusão.
>>>>>>> Stashed changes
class TaskTile extends StatelessWidget {
  final GamifyTask task;
  final ValueChanged<bool>? onToggle;
  // #p onEdit: se informado, mostra o lápis de editar (PUT /tasks/update)
  final VoidCallback? onEdit;
  // #p onTap: se informado, tocar no corpo da tarefa (ícone + textos) chama
  // esta função (ex.: abrir a edição no dashboard). O check continua separado.
  final VoidCallback? onTap;
  // #p onDelete: se informado, troca o lápis por um menu "⋮" com as opções
  // Editar (se onEdit existir) e Excluir (DELETE /tasks/delete)
  final VoidCallback? onDelete;

  const TaskTile({super.key, required this.task, this.onToggle, this.onEdit, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    // #v texto de renovação (ex.: "Renova em 5 h"); null se não se aplica
    final renew = task.renewLabel;

    // #v corpo da tarefa: ícone + título + detalhes (é a área "tocável")
    final body = Row(
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
                  // #if recorrente concluída no período: mostra quando renova
                  if (renew != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, color: AppColors.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(renew,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
<<<<<<< Updated upstream
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: task.iconColor.withOpacity(0.18), shape: BoxShape.circle),
            child: Icon(task.icon, color: task.iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('${task.currentQuantity}/${task.goalQuantity}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('+${task.xpReward} XP',
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                    const SizedBox(width: 2),
                    Text('${task.goldReward}', style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
=======
          // #if a tela passou onTap: o corpo vira um botão (InkWell)
          Expanded(
            child: onTap == null
                ? body
                : InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: body,
                  ),
          ),
          // #if a tela passou onDelete: mostra o menu "⋮" com Editar e Excluir
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: 'Opções da tarefa',
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 140),
              color: AppColors.surface,
              // ## cada opção devolve um texto; aqui decidimos o que chamar
              onSelected: (value) {
                // #if escolheu editar
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'delete') {
                  // #elseif escolheu excluir
                  onDelete?.call();
                }
              },
              itemBuilder: (_) => [
                // #if a tarefa pode ser editada: mostra "Editar"
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Editar', style: TextStyle(color: AppColors.textPrimary)),
                    ]),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: AppColors.danger)),
                  ]),
                ),
              ],
            ),
          ]
          // #elseif só onEdit: mostra o lápis de editar
          else if (onEdit != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Editar tarefa',
              icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 17),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
          const SizedBox(width: 8),
>>>>>>> Stashed changes
          GestureDetector(
            onTap: () => onToggle?.call(!task.isDone),
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
<<<<<<< Updated upstream
=======

// #f confirmTaskDelete — pergunta "tem certeza?" antes de excluir uma tarefa
// ## usado pela aba Tarefas e pela tela de edição
// #p context: contexto da tela que pediu
// #p task: tarefa que será excluída (o título aparece na pergunta)
// #r true se o usuário confirmou; false se cancelou ou fechou a caixa
Future<bool> confirmTaskDelete(BuildContext context, GamifyTask task) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Excluir tarefa?', style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        // #if vinculada a missão: avisa que a API pode recusar
        task.partOfMission
            ? '"${task.title}" faz parte de uma missão. A exclusão pode ser recusada pela API.\n\nIsso não pode ser desfeito.'
            : '"${task.title}" será apagada de vez. Isso não pode ser desfeito.',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Excluir',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  // ## fechar a caixa tocando fora devolve null: tratamos como "não"
  return ok == true;
}
>>>>>>> Stashed changes
