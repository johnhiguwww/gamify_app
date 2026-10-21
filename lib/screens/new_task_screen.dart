import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/attribute.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../data/task_icons.dart';
import '../services/task_icon_storage.dart';
import '../widgets/attribute_selector.dart';
import '../widgets/form_bits.dart';
import '../widgets/task_icon_picker.dart';
import '../widgets/task_tile.dart';

// #$ NewTaskScreen — cria (POST /tasks/newtask) ou edita (PUT /tasks/update)
// uma tarefa; é o mesmo formulário (TaskInputDTO). No modo edição também
// permite EXCLUIR (DELETE /tasks/delete).
// ## o ícone escolhido e o atributo ficam salvos só no navegador
// (TaskIconStorage), porque a API não guarda ícone nem devolve o atributo.
// #p task: se informado, a tela entra em MODO EDIÇÃO com os campos preenchidos
class NewTaskScreen extends StatefulWidget {
  final GamifyTask? task;
  const NewTaskScreen({super.key, this.task});

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
  // #v true enquanto a exclusão está em andamento (trava os botões)
  bool _deleting = false;
  // #v chave do ícone escolhido (TaskIconOption.key); começa no padrão
  String _iconKey = taskIconOptions.first.key;
  // #v true quando o usuário já escolheu o atributo nesta tela de EDIÇÃO
  // #!! a API não devolve o atributo da tarefa, então na edição ele precisa
  // ser escolhido de novo antes de salvar
  bool _attributeChosen = false;

  // #v true quando estamos editando uma tarefa existente
  bool get _isEdit => widget.task != null;

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

  // #v na edição de tarefa antiga (atributo desconhecido) exige escolher o
  // atributo antes de salvar
  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _xp >= 1 &&
      _gold >= 1 &&
      _attribute.type != null &&
      (!_isEdit || _attributeChosen) &&
      !_saving &&
      !_deleting;

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

  // #f _submit — envia a tarefa para a API (cria ou edita, conforme o modo)
  Future<void> _submit() async {
    // #if não pode salvar: sai sem fazer nada
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      final title = _titleController.text.trim();
      // #!! descrição é opcional na tela, mas obrigatória na API; usamos
      // o título como descrição padrão quando o campo fica em branco.
      final description = _descController.text.trim().isEmpty ? title : _descController.text.trim();
      // ## a API guarda UM dia, com o nome por extenso (MONDAY..SUNDAY)
      final days = _frequency == TaskFrequency.weekly ? [_day] : null;

      // #if modo edição: PUT /tasks/update?taskId=...
      // #v id da tarefa salva (usado para guardar o ícone no navegador)
      final String taskId;
      if (_isEdit) {
        taskId = widget.task!.id;
        await GamifyApiService.instance.updateTask(
          taskId: widget.task!.id,
          profileUuid: userId,
          title: title,
          description: description,
          reward: _gold,
          experience: _xp,
          attributes: _attributeToApi(_attribute.type!),
          frequency: _frequencyToApi(_frequency),
          daysOfWeek: days,
          // ## mantém a flag que a tarefa já tinha
          partOfMission: widget.task!.partOfMission,
        );
      } else {
        // #else modo criação: POST /tasks/newtask (devolve o id criado)
        taskId = await GamifyApiService.instance.createTask(
          profileUuid: userId,
          title: title,
          description: description,
          reward: _gold,
          experience: _xp,
          attributes: _attributeToApi(_attribute.type!),
          frequency: _frequencyToApi(_frequency),
          daysOfWeek: days,
        );
      }
      // ## guarda o ícone e o atributo escolhidos (só no navegador)
      await TaskIconStorage.save(taskId, _iconKey, _attribute.type);
      if (mounted) {
        // ## o messenger fica no app inteiro: o aviso aparece depois de fechar a tela
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        if (_isEdit) messenger.showSnackBar(const SnackBar(content: Text('Tarefa atualizada')));
      }
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

  // #f _delete — pergunta e exclui a tarefa (DELETE /tasks/delete?taskId=)
  // ## só existe no modo edição; ao terminar, fecha a tela e avisa
  Future<void> _delete() async {
    // #v tarefa sendo editada
    final task = widget.task;
    // #if não é edição, ou já está salvando/excluindo: não faz nada
    if (task == null || _saving || _deleting) return;
    // #if o usuário não confirmou: não faz nada
    if (!await confirmTaskDelete(context, task)) return;
    setState(() => _deleting = true);
    try {
      await GamifyApiService.instance.deleteTask(task.id);
      if (mounted) {
        // ## o messenger fica no app inteiro: o aviso aparece depois de fechar
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text('Tarefa "${task.title}" excluída.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível excluir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // #if modo edição: preenche os campos com a tarefa escolhida
    final t = widget.task;
    if (t != null) {
      _titleController.text = t.title;
      // ## quando a descrição é igual ao título, foi o padrão do app: deixa vazio
      final d = t.description ?? '';
      _descController.text = d == t.title ? '' : d;
      _xpController.text = '${t.xpReward}';
      _goldController.text = '${t.goldReward}';
      _frequency = t.frequency;
      // #if a API mandou um dia válido: usa; senão fica em segunda
      if (t.daysOfWeek.isNotEmpty && _days.any((d) => d.key == t.daysOfWeek.first)) {
        _day = t.daysOfWeek.first;
      }
      // ## ícone: o que estava salvo no navegador (ou o padrão)
      _iconKey = taskIconByKey(t.iconKey).key;
      // #if o navegador lembra o atributo desta tarefa: já vem escolhido
      if (t.attribute != null) {
        _attribute = attributeOptions.firstWhere((o) => o.type == t.attribute,
            orElse: () => attributeOptions[1]);
        _attributeChosen = true;
      } else {
        // #else atributo desconhecido (tarefa antiga): nenhum fica marcado até
        // o usuário escolher (_attributeChosen continua false)
        _attribute = attributeOptions[1];
      }
    }
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isEdit ? 'Editar Tarefa' : 'Nova Tarefa',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                            _isEdit
                                ? 'Altere os dados da tarefa pendente.'
                                : 'Crie uma ação que te aproxima da sua evolução.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
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
            const FormLabel('Ícone da tarefa', tooltip: 'Fica salvo só neste navegador'),
            TaskIconPicker(selectedKey: _iconKey, onChanged: (k) => setState(() => _iconKey = k)),
            const SizedBox(height: 16),
            const FormLabel('Atributo principal'),
            AttributeSelector(
              // ## edição sem atributo conhecido: nenhum aparece marcado
              selected: (_isEdit && !_attributeChosen) ? null : _attribute,
              onSelected: (o) => setState(() {
                _attribute = o;
                _attributeChosen = true;
              }),
            ),
            // #if edição e ainda sem atributo escolhido: explica por quê
            if (_isEdit && !_attributeChosen)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('A API não devolve o atributo da tarefa: escolha o atributo de novo para salvar.',
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
                      // ## a prévia usa o ícone escolhido (o mesmo da lista)
                      decoration: BoxDecoration(
                          color: taskIconByKey(_iconKey).color.withValues(alpha: 0.18), shape: BoxShape.circle),
                      child: Icon(taskIconByKey(_iconKey).icon, color: taskIconByKey(_iconKey).color, size: 18),
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
                            // #if edição sem atributo escolhido: pede para escolher
                            (_isEdit && !_attributeChosen)
                                ? const Text('Escolha o atributo',
                                    style: TextStyle(color: AppColors.danger, fontSize: 11.5))
                                : Text(_attribute.label,
                                    style: TextStyle(color: _attribute.color, fontSize: 11.5)),
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
            // #if modo edição: botão de excluir no fim do formulário
            if (_isEdit) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: (_saving || _deleting) ? null : _delete,
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
                        )
                      : const Icon(Icons.delete_outline, color: AppColors.danger),
                  label: const Text('Excluir tarefa',
                      style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
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
