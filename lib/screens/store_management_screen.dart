import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/store_icons.dart';
import '../models/store_item.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../services/store_icon_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/form_bits.dart';
import '../widgets/store_icon_picker.dart';

// #$ StoreManagementScreen — cadastrar e editar itens da loja.
// #!! decisão do projeto: NÃO existe ação de apagar item (itens comprados
// ficam como registro). A lista mostra só itens NÃO comprados.
// ## a API só aceita nome e valor (>= 1). O ícone é escolhido aqui e fica
// guardado só no navegador (StoreIconStorage).
class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  // #!! lista COMPLETA vinda da API (comprados e não comprados): o _add usa
  // ela para descobrir qual item é novo; a tela filtra só na hora de exibir
  List<StoreItem> _items = [];
  bool _loading = true;
  String? _error;
  // #v true se a API respondeu 404 (perfil ou loja não existem)
  bool _storeMissing = false;
  // #v true enquanto uma operação (adicionar/editar) está em andamento
  bool _busy = false;
  // #v ícone escolhido para o NOVO item (começa no padrão)
  String _newIconKey = storeIconOptions.first.key;

  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  // #v valor digitado (null se vazio); a API exige >= 1
  int? get _cost => int.tryParse(_costController.text.trim());

  // #v itens que aparecem na tela: só os NÃO comprados
  List<StoreItem> get _visibleItems => _items.where((i) => !i.purchased).toList();

  // #f _canAdd — nome preenchido, valor >= 1 e nenhuma operação em andamento
  bool get _canAdd =>
      _nameController.text.trim().isNotEmpty && (_cost ?? 0) >= 1 && !_busy && !_storeMissing;

  @override
  void initState() {
    super.initState();
    // ## reconstrói ao digitar para habilitar/desabilitar o botão
    _nameController.addListener(() => setState(() {}));
    _costController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // #f _load — GET /profiles/{uuid}/mystore e aplica os ícones salvos
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
      final items = await GamifyApiService.instance.fetchStore(userId);
      final withIcons = items == null ? null : await StoreIconStorage.applyIcons(items);
      if (!mounted) return;
      setState(() {
        _storeMissing = withIcons == null;
        _items = withIcons ?? [];
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar a loja: $e';
        _loading = false;
      });
    }
  }

  // #f _run — executa uma operação da API, trava a tela e recarrega a lista
  // #p action: operação a executar; okMessage: aviso de sucesso
  Future<void> _run(Future<void> Function(String userId) action, String okMessage) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null || _busy) return;
    setState(() => _busy = true);
    try {
      await action(userId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(okMessage)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // #f _add — POST /profiles/{uuid}/addItem e guarda o ícone do item novo
  Future<void> _add() async {
    // #if não pode adicionar: sai sem fazer nada
    if (!_canAdd) return;
    final name = _nameController.text.trim();
    final value = _cost!;
    final iconKey = _newIconKey;
    await _run(
      (userId) async {
        // #v ids que já existiam (lista completa), para achar o item novo depois
        final before = {for (final i in _items) i.id};
        await GamifyApiService.instance.addStoreItem(userId: userId, name: name, value: value);
        // ## o addStoreItem não devolve o id: buscamos a loja e vemos qual item é novo
        final after = await GamifyApiService.instance.fetchStore(userId);
        final created = (after ?? []).where((i) => !before.contains(i.id)).toList();
        // #if achou exatamente um item novo: guarda o ícone escolhido
        if (created.length == 1) {
          await StoreIconStorage.save(created.first.id, iconKey);
        }
      },
      'Item adicionado: $name',
    );
    if (mounted) {
      _nameController.clear();
      _costController.clear();
      setState(() => _newIconKey = storeIconOptions.first.key);
    }
  }

  // #f _edit — abre o diálogo, chama PUT /updateItem e guarda o ícone
  Future<void> _edit(StoreItem item) async {
    final result = await showDialog<({String name, int value, String iconKey})>(
      context: context,
      builder: (_) => _ItemDialog(item: item),
    );
    // #if cancelou o diálogo
    if (result == null) return;
    await _run(
      (userId) async {
        await GamifyApiService.instance
            .updateStoreItem(userId: userId, itemId: item.id, name: result.name, value: result.value);
        await StoreIconStorage.save(item.id, result.iconKey);
      },
      'Item atualizado',
    );
  }

  // #f _list — carregando, erro, loja inexistente, vazio ou a lista de itens
  List<Widget> _list() {
    // #if carregando
    if (_loading) {
      return const [Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))];
    }
    // #if erro
    if (_error != null) {
      return [
        Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Tentar de novo')),
      ];
    }
    // #if 404
    if (_storeMissing) {
      return const [
        Text('A API respondeu 404: perfil ou loja não encontrados para este usuário.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
      ];
    }
    // #v só os itens ainda não comprados
    final visible = _visibleItems;
    // #if vazio (nenhum item, ou todos já comprados)
    if (visible.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Nenhum item disponível.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        ),
      ];
    }
    return [
      for (final item in visible) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                Row(children: [
                  const Icon(Icons.monetization_on, color: AppColors.gold, size: 13),
                  const SizedBox(width: 3),
                  Text('${item.cost}',
                      style: const TextStyle(
                          color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12.5)),
                ]),
                const SizedBox(width: 8),
                // ## só editar: não existe botão de apagar (decisão do projeto)
                IconButton(
                  onPressed: _busy ? null : () => _edit(item),
                  icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 17),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.settings, color: AppColors.textPrimary, size: 18),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('Gerenciar Loja',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 44, top: 2, bottom: 16),
              child: Text('Adicione ou edite itens da loja.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
            const Text('Itens da loja',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            ..._list(),
            const SizedBox(height: 8),
            const Text('Adicionar item',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            const FormLabel('Nome do item'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Ex: Comprar um café'),
            ),
            const SizedBox(height: 14),
            const FormLabel('Custo (Gold)'),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              // ## só dígitos, até 9 (cabe no int da API); a API exige >= 1
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
              decoration: const InputDecoration(
                hintText: 'Ex: 30',
                prefixIcon: Icon(Icons.monetization_on, color: AppColors.gold, size: 18),
              ),
            ),
            const SizedBox(height: 14),
            const FormLabel('Ícone', tooltip: 'Guardado só neste navegador'),
            StoreIconPicker(
              selectedKey: _newIconKey,
              onChanged: (k) => setState(() => _newIconKey = k),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canAdd ? _add : null,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                      )
                    : const Text('Salvar item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// #$ _ItemDialog — diálogo de edição (nome, valor e ícone)
class _ItemDialog extends StatefulWidget {
  final StoreItem item;
  const _ItemDialog({required this.item});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final _name = TextEditingController(text: widget.item.title);
  late final _value = TextEditingController(text: '${widget.item.cost}');
  // #v ícone escolhido (começa no que o item já usa)
  late String _iconKey = widget.item.iconKey ?? storeIconOptions.first.key;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  // #f _save — valida (nome preenchido, valor >= 1) e fecha devolvendo o resultado
  void _save() {
    final name = _name.text.trim();
    final value = int.tryParse(_value.text.trim()) ?? 0;
    // #if inválido: não fecha
    if (name.isEmpty || value < 1) return;
    Navigator.of(context).pop((name: name, value: value, iconKey: _iconKey));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar item'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
              TextField(
                controller: _value,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                decoration: const InputDecoration(labelText: 'Custo (Gold, mínimo 1)'),
              ),
              const SizedBox(height: 16),
              const Text('Ícone', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              StoreIconPicker(selectedKey: _iconKey, onChanged: (k) => setState(() => _iconKey = k)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}