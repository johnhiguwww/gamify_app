import 'package:flutter/material.dart';
import '../models/attribute.dart';
import '../models/task.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_selector.dart';
import '../widgets/form_bits.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController(text: 'Ler 10 páginas');
  final _descController = TextEditingController();
  AttributeOption _attribute = attributeOptions[1]; // default: Inteligência
  TaskFrequency _frequency = TaskFrequency.diaria;
  int _xp = 120;
  int _gold = 30;
  bool _reminder = false;
  bool _saving = false;

  // #f _frequencyToApi — mapeia o enum local pro valor esperado pelo
  // backend Java (UNIQUE, DAILY, WEEKLY, MONTHLY).
  String _frequencyToApi(TaskFrequency f) => switch (f) {
        TaskFrequency.diaria => 'DAILY',
        TaskFrequency.semanal => 'WEEKLY',
        TaskFrequency.mensal => 'MONTHLY',
        TaskFrequency.unica => 'UNIQUE',
      };

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final userId = CurrentUser.userId;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      await GamifyApiService.instance.createTask(
        profileUuid: userId,
        title: _titleController.text.trim(),
        // #!! descrição é opcional na tela, mas obrigatória na API; usamos
        // o título como descrição padrão quando o campo fica em branco.
        description: _descController.text.trim().isEmpty ? _titleController.text.trim() : _descController.text.trim(),
        reward: _gold,
        experience: _xp,
        frequency: _frequencyToApi(_frequency),
        attributes: _attribute.type?.apiKey ?? 'intelligence',
        // #!! ainda não existe seletor de dias da semana na tela; usamos
        // segunda-feira como padrão quando a frequência é semanal.
        daysOfWeek: _frequency == TaskFrequency.semanal ? ['MON'] : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      debugPrint('Erro ao salvar tarefa: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar a tarefa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_titleController, _descController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nova Tarefa', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Crie uma ação que te aproxima da sua evolução.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: (_titleController.text.trim().isEmpty || _saving) ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Text('Salvar', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Título da tarefa'),
                Text('${_titleController.text.length}/60', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            TextField(
              controller: _titleController,
              maxLength: 60,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Ex: Ler 10 páginas'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Atributo', tooltip: 'Qual inteligência esta tarefa desenvolve?'),
            AttributeSelector(selected: _attribute, onSelected: (v) => setState(() => _attribute = v)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Recompensa', tooltip: 'XP e Gold ganhos a cada conclusão'),
                      MetricPill(
                        icon: Icons.bolt,
                        iconColor: AppColors.primaryGreen,
                        label: 'XP',
                        value: '+$_xp',
                        caption: '',
                        showChevron: true,
                        onTap: () => _pickCustomValue(
                          context,
                          title: 'XP',
                          currentValue: _xp,
                          onPick: (v) => setState(() => _xp = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MetricPill(
                        icon: Icons.monetization_on,
                        iconColor: AppColors.gold,
                        label: 'Gold',
                        value: '+$_gold',
                        caption: '',
                        showChevron: true,
                        onTap: () => _pickCustomValue(
                          context,
                          title: 'Gold',
                          currentValue: _gold,
                          onPick: (v) => setState(() => _gold = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Frequência', tooltip: 'De quanto em quanto tempo a tarefa reinicia'),
                      _FrequencyGrid(current: _frequency, onChanged: (f) => setState(() => _frequency = f)),
                    ],
                  ),
                ),
              ],
            ),
            const FormLabel('Lembrete', tooltip: 'Receba uma notificação no horário definido'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Adicionar lembrete', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                  Switch(value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Descrição (opcional)', tooltip: 'Detalhes extras sobre a tarefa'),
                Text('${_descController.text.length}/200', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            TextField(
              controller: _descController,
              maxLength: 200,
              maxLines: 3,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Adicione mais detalhes...'),
            ),
            const SizedBox(height: 18),
            const FormLabel('Prévia da tarefa'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.18), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty ? 'Título da tarefa' : _titleController.text,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          const SizedBox(height: 3),
                          Row(children: [
                            Text(_frequency.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+$_xp XP', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12.5)),
                        Row(children: [
                          const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                          const SizedBox(width: 3),
                          Text('$_gold Gold', style: const TextStyle(color: AppColors.gold, fontSize: 11.5)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // #f _pickCustomValue — abre um diálogo com campo numérico livre para o
  // usuário digitar o valor de XP ou Gold que quiser, sem lista fixa.
  Future<void> _pickCustomValue(
    BuildContext context, {
    required String title,
    required int currentValue,
    required ValueChanged<int> onPick,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    String? errorText;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Definir $title', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Valor de $title',
              errorText: errorText,
            ),
            onSubmitted: (_) {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              } else {
                setDialogState(() => errorText = 'Digite um número inteiro maior que zero');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value != null && value > 0) {
                  Navigator.of(context).pop(value);
                } else {
                  setDialogState(() => errorText = 'Digite um número inteiro maior que zero');
                }
              },
              child: const Text('Confirmar', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    if (result != null) onPick(result);
  }
}

class _FrequencyGrid extends StatelessWidget {
  final TaskFrequency current;
  final ValueChanged<TaskFrequency> onChanged;
  const _FrequencyGrid({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: [
        for (final f in TaskFrequency.values)
          GestureDetector(
            onTap: () => onChanged(f),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: current == f ? AppColors.primaryGreen : AppColors.border, width: current == f ? 1.6 : 1),
              ),
              child: Text(f.label,
                  style: TextStyle(
                    color: current == f ? AppColors.primaryGreen : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  )),
            ),
          ),
      ],
    );
  }
}