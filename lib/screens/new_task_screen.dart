import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/attribute.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_selector.dart';
import '../widgets/form_bits.dart';

// #$ NewTaskScreen — POST /tasks/newtask (TasksInputDTO)
class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  // #v XP e Gold são digitados pelo usuário (começam vazios, sem valor fixo)
  final _xpController = TextEditingController();
  final _goldController = TextEditingController();

  AttributeOption _attribute = attributeOptions[1]; // #v default: Inteligência
  TaskFrequency _frequency = TaskFrequency.daily;
  // #v dia da semana (só vale quando a frequência é semanal); a API guarda UM dia
  String _day = 'MONDAY';
  bool _saving = false;

  // #v dias aceitos pelo TaskFrequencyDaysOfWeekEnum (confirmado no Java)
  static const _days = [
    (key: 'MONDAY', label: 'Seg'),
    (key: 'TUESDAY', label: 'Ter'),
    (key: 'WEDNESDAY', label: 'Qua'),
    (key: 'THURSDAY', label: 'Qui'),
    (key: 'FRIDAY', label: 'Sex'),
    (key: 'SATURDAY', label: 'Sáb'),
    (key: 'SUNDAY', label: 'Dom'),
  ];

  // #v valores digitados; a API exige mínimo 1 em reward e experience
  int get _xp => int.tryParse(_xpController.text) ?? 0;
  int get _gold => int.tryParse(_goldController.text) ?? 0;

  // #v "Outro" (type == null) não tem atributo na API, então não salva
  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && _xp >= 1 && _gold >= 1 && _attribute.type != null && !_saving;

  // #f _frequencyToApi — enum local -> TaskFrequencyEnum do Java
  String _frequencyToApi(TaskFrequency f) => switch (f) {
        TaskFrequency.daily => 'DAILY',
        TaskFrequency.weekly => 'WEEKLY',
        TaskFrequency.monthly => 'MONTHLY',
        TaskFrequency.once => 'UNIQUE',
      };

  // #f _attributeToApi — AttributeType -> AttributesLebels do Java (snake_case)
  String _attributeToApi(AttributeType t) => switch (t) {
        AttributeType.inteligencia => 'intelligence',
        AttributeType.forca => 'strength',
        AttributeType.espiritualidade => 'spirituality',
        AttributeType.carisma => 'charisma',
        AttributeType.percepcaoEspacial => 'spatial_perception',
        AttributeType.autoconsciencia => 'self_awareness',
        AttributeType.linguagem => 'language',
        AttributeType.raciocinioLogico => 'logical_reasoning',
        AttributeType.musicalidade => 'musicality',
      };

  // #f _submit — envia a tarefa para a API
  Future<void> _submit() async {
    // #if não pode salvar: sai sem fazer nada
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      await GamifyApiService.instance.createTask(
        profileUuid: userId,
        title: _titleController.text.trim(),
        // #!! descrição é opcional na tela, mas obrigatória na API; usamos
        // o título como descrição padrão quando o campo fica em branco.
        description: _descController.text.trim().isEmpty ? _titleController.text.trim() : _descController.text.trim(),
        reward: _gold,
        experience: _xp,
        attributes: _attributeToApi(_attribute.type!),
        frequency: _frequencyToApi(_frequency),
        // ## a API guarda UM dia, com o nome por extenso (MONDAY..SUNDAY)
        daysOfWeek: _frequency == TaskFrequency.weekly ? [_day] : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
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
    for (final c in [_titleController, _descController, _xpController, _goldController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _xpController.dispose();
    _goldController.dispose();
    super.dispose();
  }

  // #f _dayLabel — rótulo curto do dia escolhido (para a prévia)
  String get _dayLabel => _days.firstWhere((d) => d.key == _day).label;

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
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nova Tarefa',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Crie uma ação que te aproxima da sua evolução.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _canSave ? _submit : null,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Text('Salvar',
                          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Título da tarefa'),
                Text('${_titleController.text.length}/60',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            TextField(
              controller: _titleController,
              maxLength: 60,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Ex: Ler 10 páginas'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Atributo principal'),
            AttributeSelector(selected: _attribute, onSelected: (o) => setState(() => _attribute = o)),
            // #if "Outro" não existe na API: explica por que o Salvar fica desabilitado
            if (_attribute.type == null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('A API exige um dos atributos da lista. Escolha outro para salvar.',
                    style: TextStyle(color: AppColors.danger, fontSize: 11.5)),
              ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Recompensa', tooltip: 'XP vai para o atributo; ouro vai para o perfil'),
                      const Text('XP', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _xpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                        decoration: const InputDecoration(isDense: true, hintText: 'Ex: 120'),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gold', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _goldController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                        decoration: const InputDecoration(isDense: true, hintText: 'Ex: 30'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Frequência', tooltip: 'Rótulo da tarefa (a API não reinicia tarefas sozinha)'),
                      _FrequencyGrid(current: _frequency, onChanged: (f) => setState(() => _frequency = f)),
                    ],
                  ),
                ),
              ],
            ),
            // ## seletor de dia: só aparece quando a frequência é semanal
            if (_frequency == TaskFrequency.weekly) ...[
              const SizedBox(height: 16),
              const FormLabel('Dia da semana', tooltip: 'A API guarda um único dia'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _days)
                    GestureDetector(
                      onTap: () => setState(() => _day = d.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _day == d.key ? AppColors.primaryGreen : AppColors.border,
                              width: _day == d.key ? 1.6 : 1),
                        ),
                        child: Text(d.label,
                            style: TextStyle(
                              color: _day == d.key ? AppColors.primaryGreen : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Descrição (opcional)', tooltip: 'Se ficar vazia, usamos o título'),
                Text('${_descController.text.length}/200',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
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
                      decoration: BoxDecoration(
                          color: _attribute.color.withValues(alpha: 0.18), shape: BoxShape.circle),
                      child: Icon(_attribute.icon, color: _attribute.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty ? 'Título da tarefa' : _titleController.text,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          const SizedBox(height: 3),
                          Row(children: [
                            Text(_attribute.label, style: TextStyle(color: _attribute.color, fontSize: 11.5)),
                            const SizedBox(width: 6),
                            Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                                _frequency == TaskFrequency.weekly
                                    ? '${_frequency.label} · $_dayLabel'
                                    : _frequency.label,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+$_xp XP',
                            style: const TextStyle(
                                color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12.5)),
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
                border: Border.all(
                    color: current == f ? AppColors.primaryGreen : AppColors.border,
                    width: current == f ? 1.6 : 1),
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