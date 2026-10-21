import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/task_tile.dart';
import 'new_task_screen.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';

// #$ _TaskTab — as duas abas da tela: Ativas e Concluídas
// ## mesmo modelo visual da tela de Missões
enum _TaskTab { ativas, concluidas }

// #$ TasksScreen — aba "Tarefas"
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // #v aba selecionada (começa em Ativas)
  _TaskTab _tab = _TaskTab.ativas;
  // #v todas as tarefas vindas da API (o filtro da aba é feito no app)
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
    // #if sem usuário logado: mostra o aviso e para
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Sessão expirada, faça login novamente.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await GamifyApiService.instance.fetchTasks(userId);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
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

  // #f _filtered — tarefas da aba selecionada
  // ## Ativas = pendentes (podem ser concluídas agora)
  // ## Concluídas = encerradas de vez (Única) OU recorrentes esperando renovar
  // (essas voltam sozinhas para Ativas depois de 24 h / 7 dias / 30 dias)
  List<GamifyTask> get _filtered => _tasks
      .where((t) => _tab == _TaskTab.ativas ? !t.isDone : t.isDone)
      .toList();

  // #f _showMessage — mostra um aviso curto na parte de baixo da tela
  // #p text: mensagem
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // #f _complete — conclui a tarefa pela rota certa da frequência
  // ## Única: POST /tasks/complete (encerra). Recorrente: PUT /tasks/complete-cycle
  // (volta a ficar pendente depois de 24 h / 7 dias / 30 dias — regra do app)
  Future<void> _complete(GamifyTask task) async {
    // #if outra conclusão em andamento: não faz nada
    if (_completingId != null) return;
    // #if já concluída: só explica por que não dá para concluir de novo
    if (task.isDone) {
      // #v texto de renovação (só existe para recorrente no período)
      final renew = task.renewLabel;
      // #if recorrente esperando o período: diz quando renova
      if (renew != null) {
        _showMessage('Já concluída neste período. $renew.');
      } else {
        // #else encerrada de vez (única, ou concluída pelo modo antigo)
        _showMessage('Esta tarefa já foi encerrada e não renova.');
      }
      return;
    }
    setState(() => _completingId = task.id);
    try {
      await GamifyApiService.instance.concludeTask(task);
      await _load();
      if (!mounted) return;
      _showMessage('Tarefa concluída! +${task.xpReward} XP no atributo e +${task.goldReward} de ouro');
    } catch (e) {
      if (mounted) _showMessage('Não foi possível concluir a tarefa: $e');
    } finally {
      if (mounted) setState(() => _completingId = null);
    }
  }

  // #f _edit — abre o formulário em modo edição e recarrega a lista ao voltar
  // #p task: tarefa escolhida (só as não encerradas chegam aqui)
  Future<void> _edit(GamifyTask task) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => NewTaskScreen(task: task)));
    if (mounted) _load();
  }

  // #f _delete — pergunta, chama DELETE /tasks/delete e recarrega a lista
  // #p task: tarefa escolhida (só as não encerradas chegam aqui; a API
  // recusa apagar tarefa encerrada)
  Future<void> _delete(GamifyTask task) async {
    // #if o usuário não confirmou: não faz nada
    if (!await confirmTaskDelete(context, task)) return;
    try {
      await GamifyApiService.instance.deleteTask(task.id);
      await _load();
      if (mounted) _showMessage('Tarefa "${task.title}" excluída.');
    } catch (e) {
      if (mounted) _showMessage('Não foi possível excluir: $e');
    }
  }

  // #f _listBody — carregando, erro, vazio ou a lista da aba
  Widget _listBody() {
    // #if carregando
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // #if erro: mostra a mensagem e o botão de tentar de novo
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(_error!,
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Tentar de novo')),
          ],
        ),
      );
    }
    // #v lista já filtrada pela aba
    final list = _filtered;
    // #if aba vazia
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
              _tab == _TaskTab.ativas ? 'Nenhuma tarefa ativa.' : 'Nenhuma tarefa concluída ainda.',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++) ...[
              TaskTile(
                task: list[i],
                onToggle: (_) => _complete(list[i]),
                // ## tarefa encerrada de vez (finished) não é editável;
                // recorrente esperando renovar continua editável
                onEdit: list[i].finished ? null : () => _edit(list[i]),
                onTap: list[i].finished ? null : () => _edit(list[i]),
                // ## menu "⋮" com Editar/Excluir; tarefa encerrada não é
                // apagável na API (400), então fica sem menu
                onDelete: list[i].finished ? null : () => _delete(list[i]),
              ),
              if (i != list.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.checklist_rounded, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Text('Tarefas',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Suas ações do dia a dia rumo à evolução.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 12),
          // ## seletor Ativas / Concluídas (igual ao das Missões)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TaskTabs(current: _tab, onChanged: (t) => setState(() => _tab = t)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // ## título da aba + contador
                Row(
                  children: [
                    Text('Tarefas ${_tab == _TaskTab.ativas ? 'Ativas' : 'Concluídas'}',
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration:
                          BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                      child: Text('${_loading ? 0 : _filtered.length}',
                          style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _listBody(),
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
          ),
        ],
      ),
    );
  }
}

// #$ _TaskTabs — seletor "Ativas | Concluídas" (cópia do visual das Missões)
class _TaskTabs extends StatelessWidget {
  // #p current: aba selecionada
  final _TaskTab current;
  // #p onChanged: chamado ao tocar numa aba
  final ValueChanged<_TaskTab> onChanged;
  const _TaskTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // #v as duas abas, com o texto mostrado na tela
    const tabs = [
      (tab: _TaskTab.ativas, label: 'Ativas'),
      (tab: _TaskTab.concluidas, label: 'Concluídas'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final t in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t.tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == t.tab ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: current == t.tab ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      color: current == t.tab ? AppColors.primaryGreen : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
