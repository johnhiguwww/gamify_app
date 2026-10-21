import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/attribute.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_selector.dart';
import '../widgets/form_bits.dart';

// #$ NewMissionScreen — cria a missão e, se o formulário de tarefa estiver
// ligado, uma tarefa vinculada.
// #!! fluxo (instrução do desenvolvedor da API):
//   1) POST /tasks/newtask com partOfMission = true
//   2) pega o id devolvido no TasksOutPutDTO
//   3) POST /missions/new com esse id em taskId
// ## a missão guarda UMA tarefa só (opcional).
class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});

  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  // #v campos da missão
  final _titleController = TextEditingController();
  final _xpController = TextEditingController();
  final _goldController = TextEditingController();

  // #v campos da tarefa vinculada
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  final _taskXpController = TextEditingController();
  final _taskGoldController = TextEditingController();

  // #v true quando o usuário quer vincular uma tarefa à missão
  bool _linkTask = false;
  AttributeOption _attribute = attributeOptions[1]; // #v default: Inteligência
  TaskFrequency _frequency = TaskFrequency.once;
  // #v dia da semana (só vale quando a frequência é semanal); a API guarda UM dia
  String _day = 'MONDAY';

  // #v true enquanto os POSTs estão em andamento
  bool _saving = false;

  // #v id da tarefa JÁ criada na API; se a missão falhar, o "tentar de novo"
  // reaproveita esse id em vez de criar outra tarefa (não há rota para apagar)
  String? _createdTaskId;

  // #!! limite só visual (contador); a API não foi conferida quanto ao tamanho do título
  static const int _titleMax = 60;

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

  // #f valores digitados como int (null se vazio ou inválido)
  int? get _xp => int.tryParse(_xpController.text.trim());
  int? get _gold => int.tryParse(_goldController.text.trim());
  int get _taskXp => int.tryParse(_taskXpController.text.trim()) ?? 0;
  int get _taskGold => int.tryParse(_taskGoldController.text.trim()) ?? 0;

  // #f _taskValid — tarefa pronta: título, XP >= 1, ouro >= 1 e atributo da API
  // ## a API de tarefa exige reward e experience com mínimo 1
  bool get _taskValid =>
      _taskTitleController.text.trim().isNotEmpty &&
      _taskXp >= 1 &&
      _taskGold >= 1 &&
      _attribute.type != null;

  // #f _canSubmit — missão válida, tarefa válida (se ligada) e sem envio em andamento
  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _xp != null &&
      _gold != null &&
      (!_linkTask || _taskValid) &&
      !_saving;

  @override
  void initState() {
    super.initState();
    // #!! reconstrói ao digitar para habilitar/desabilitar o botão e atualizar a prévia
    for (final c in [
      _titleController,
      _xpController,
      _goldController,
      _taskTitleController,
      _taskDescController,
      _taskXpController,
      _taskGoldController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _xpController.dispose();
    _goldController.dispose();
    _taskTitleController.dispose();
    _taskDescController.dispose();
    _taskXpController.dispose();
    _taskGoldController.dispose();
    super.dispose();
  }

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

  // #f _submit — cria a tarefa (se ligada) e depois a missão
  Future<void> _submit() async {
    // #if não pode enviar: sai sem fazer nada
    if (!_canSubmit) return;
    setState(() => _saving = true);
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');

      // ## passo 1 e 2: cria a tarefa vinculada e guarda o id devolvido
      // #if a tarefa está ligada e ainda NÃO foi criada nesta tela
      if (_linkTask && _createdTaskId == null) {
        final taskTitle = _taskTitleController.text.trim();
        final taskDesc = _taskDescController.text.trim();
        _createdTaskId = await GamifyApiService.instance.createTask(
          profileUuid: userId,
          title: taskTitle,
          // #!! descrição é obrigatória na API; usa o título quando vazia
          description: taskDesc.isEmpty ? taskTitle : taskDesc,
          reward: _taskGold,
          experience: _taskXp,
          attributes: _attributeToApi(_attribute.type!),
          frequency: _frequencyToApi(_frequency),
          daysOfWeek: _frequency == TaskFrequency.weekly ? [_day] : null,
          // #!!! a flag que diz que a tarefa faz parte de uma missão
          partOfMission: true,
        );
      }

      // ## passo 3: cria a missão com o id da tarefa (ou sem taskId)
      await GamifyApiService.instance.createMission(
        userId: userId,
        title: _titleController.text.trim(),
        reward: _gold!,
        experience: _xp!,
        taskId: _linkTask ? _createdTaskId : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        // #if a tarefa já existe na API mas a missão falhou: avisa o usuário
        final extra = _createdTaskId != null
            ? '\nA tarefa já foi criada; ao tentar de novo ela será reaproveitada.'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível criar a missão: $e$extra')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ## só dígitos (sem negativo), até 9 dígitos para caber no Integer da API
  List<TextInputFormatter> get _numberFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ];

  // #f _taskForm — formulário da tarefa vinculada (só aparece quando ligada)
  List<Widget> _taskForm() {
    return [
      const SizedBox(height: 14),
      // ## título da tarefa com contador
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const FormLabel('Título da tarefa'),
          Text('${_taskTitleController.text.length}/60',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
      TextField(
        controller: _taskTitleController,
        maxLength: 60,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
        decoration: const InputDecoration(hintText: 'Ex: Assistir à primeira aula'),
      ),
      const SizedBox(height: 14),
      const FormLabel('Atributo principal'),
      AttributeSelector(selected: _attribute, onSelected: (o) => setState(() => _attribute = o)),
      const SizedBox(height: 14),
      const FormLabel('Recompensa da tarefa',
          tooltip: 'XP vai para o atributo; ouro vai para o perfil (mínimo 1 em cada)'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _taskXpController,
              keyboardType: TextInputType.number,
              inputFormatters: _numberFormatters,
              decoration: const InputDecoration(
                hintText: 'XP (mín. 1)',
                prefixIcon: Icon(Icons.bolt_rounded, color: AppColors.primaryGreen),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _taskGoldController,
              keyboardType: TextInputType.number,
              inputFormatters: _numberFormatters,
              decoration: const InputDecoration(
                hintText: 'Ouro (mín. 1)',
                prefixIcon: Icon(Icons.monetization_on, color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const FormLabel('Frequência', tooltip: 'Rótulo da tarefa (a API não reinicia tarefas sozinha)'),
      // ## chips de frequência
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final f in TaskFrequency.values)
            GestureDetector(
              onTap: () => setState(() => _frequency = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _frequency == f ? AppColors.primaryGreen : AppColors.border,
                      width: _frequency == f ? 1.6 : 1),
                ),
                child: Text(f.label,
                    style: TextStyle(
                      color: _frequency == f ? AppColors.primaryGreen : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    )),
              ),
            ),
        ],
      ),
      // ## seletor de dia: só aparece quando a frequência é semanal
      if (_frequency == TaskFrequency.weekly) ...[
        const SizedBox(height: 14),
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
      const SizedBox(height: 14),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const FormLabel('Descrição (opcional)', tooltip: 'Se ficar vazia, usamos o título'),
          Text('${_taskDescController.text.length}/200',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
      TextField(
        controller: _taskDescController,
        maxLength: 200,
        maxLines: 3,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
        decoration: const InputDecoration(hintText: 'Adicione mais detalhes...'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // #v valores exibidos na prévia (0 enquanto vazio)
    final previewXp = _xp ?? 0;
    final previewGold = _gold ?? 0;
    final previewTitle = _titleController.text.trim().isEmpty
        ? 'Título da missão'
        : _titleController.text.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ## cabeçalho: fechar, título, subtítulo e botão Salvar
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
                        Text('Nova Missão',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text('Defina um objetivo e a recompensa por cumpri-lo.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Text('Salvar',
                          style: TextStyle(
                              color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ## título com contador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Título da missão'),
                Text('${_titleController.text.length}/$_titleMax',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            TextField(
              controller: _titleController,
              maxLength: _titleMax,
              // ## esconde o contador padrão (usamos o nosso acima)
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Ex: Completar tutorial'),
            ),
            const SizedBox(height: 18),

            // ## recompensa: XP e ouro lado a lado
            const FormLabel('Recompensa', tooltip: 'XP e ouro ganhos ao concluir a missão'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('XP',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _xpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: _numberFormatters,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 50',
                          prefixIcon: Icon(Icons.bolt_rounded, color: AppColors.primaryGreen),
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
                      const Text('Ouro',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _goldController,
                        keyboardType: TextInputType.number,
                        inputFormatters: _numberFormatters,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 10',
                          prefixIcon: Icon(Icons.monetization_on, color: AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ## interruptor: liga o formulário da tarefa vinculada
            Card(
              child: SwitchListTile(
                value: _linkTask,
                // #if a tarefa já foi criada na API: não deixa desligar (ela já existe)
                onChanged: (_saving || _createdTaskId != null)
                    ? null
                    : (v) => setState(() => _linkTask = v),
                activeThumbColor: AppColors.primaryGreen,
                title: const Text('Vincular uma tarefa a esta missão',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: Text(
                  _createdTaskId != null
                      ? 'Tarefa já criada: ela será usada ao salvar a missão.'
                      : 'A missão guarda uma tarefa só. Opcional.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ),
            ),
            // ## formulário da tarefa (só quando ligado)
            if (_linkTask) ..._taskForm(),
            const SizedBox(height: 22),

            // ## prévia: mostra como a missão aparece na lista
            const FormLabel('Prévia da missão'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.track_changes_rounded,
                          color: AppColors.danger, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _titleController.text.trim().isEmpty
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // ## toda missão nova nasce ativa (finished = false)
                          Text(_linkTask ? 'Missão · Ativa · com tarefa' : 'Missão · Ativa',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+$previewXp XP',
                            style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5)),
                        Row(children: [
                          const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                          const SizedBox(width: 3),
                          Text('$previewGold Ouro',
                              style: const TextStyle(color: AppColors.gold, fontSize: 11.5)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ## botão principal também embaixo (mais fácil de achar no celular)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                      )
                    : const Text('Criar Missão'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}