import 'package:flutter/material.dart';
import '../models/store_item.dart';
import '../theme/app_colors.dart';
import '../widgets/form_bits.dart';

<<<<<<< Updated upstream
=======
// #$ StoreManagementScreen — cadastrar e editar itens da loja.
// #!! decisão do projeto: NÃO existe ação de apagar item (itens comprados
// ficam como registro). A lista mostra só itens NÃO comprados.
// ## a API só aceita nome e valor (>= 1). O ícone é escolhido aqui e fica
// guardado só no navegador (StoreIconStorage).
>>>>>>> Stashed changes
class StoreManagementScreen extends StatefulWidget {
  final List<StoreItem> items;
  const StoreManagementScreen({super.key, required this.items});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
<<<<<<< Updated upstream
  late List<StoreItem> _items = List.of(widget.items);
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController(text: '0');
  bool _newItemActive = true;
  bool _showToUser = true;
=======
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
>>>>>>> Stashed changes

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _toggleActive(String id, bool value) {
    setState(() {
      _items = [for (final i in _items) if (i.id == id) i.copyWith(active: value) else i];
    });
  }

  void _remove(String id) {
    setState(() => _items.removeWhere((i) => i.id == id));
  }

<<<<<<< Updated upstream
  void _addItem() {
    if (_nameController.text.trim().isEmpty) return;
    final cost = int.tryParse(_costController.text) ?? 0;
    setState(() {
      _items.add(StoreItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        cost: cost,
        icon: Icons.card_giftcard,
        iconColor: AppColors.primaryGreen,
        active: _newItemActive,
      ));
=======
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
>>>>>>> Stashed changes
      _nameController.clear();
      _descController.clear();
      _costController.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_items);
      },
<<<<<<< Updated upstream
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(_items),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.settings, color: AppColors.textPrimary, size: 18),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('Gerenciar Loja', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  Row(children: [
                    const Icon(Icons.monetization_on, color: AppColors.gold, size: 16),
                    const SizedBox(width: 4),
                    const Text('120', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                  ]),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 44, top: 2, bottom: 16),
                child: Text('Adicione, edite ou remova itens da loja.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Itens da loja', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                    label: const Text('Adicionar item', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12.5)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final item in _items) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator, color: AppColors.textMuted, size: 16),
                        const SizedBox(width: 6),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: item.iconColor.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                          child: Icon(item.icon, color: item.iconColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Row(children: [
                          const Icon(Icons.monetization_on, color: AppColors.gold, size: 13),
                          const SizedBox(width: 3),
                          Text('${item.cost}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12.5)),
                        ]),
                        const SizedBox(width: 8),
                        Switch(value: item.active, onChanged: (v) => _toggleActive(item.id, v)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 17),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => _remove(item.id),
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
=======
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
>>>>>>> Stashed changes
                  ),
                ),
<<<<<<< Updated upstream
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              const Text('Adicionar item', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), color: AppColors.surfaceAlt),
                        child: const Icon(Icons.add, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      const Text('Ícone', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Nome do item'),
                        TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Ex: Comprar um café')),
                      ],
                    ),
                  ),
                ],
=======
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
>>>>>>> Stashed changes
              ),
              const SizedBox(height: 14),
              const FormLabel('Descrição'),
              TextField(controller: _descController, maxLines: 2, decoration: const InputDecoration(hintText: 'Descreva o item e seu benefício')),
              const SizedBox(height: 14),
              const FormLabel('Custo (Gold)'),
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.monetization_on, color: AppColors.gold, size: 18)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ativo', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Item disponível na loja', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Switch(value: _newItemActive, onChanged: (v) => setState(() => _newItemActive = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _addItem, child: const Text('Salvar item')),
              ),
              const SizedBox(height: 20),
              Row(children: const [
                Icon(Icons.tips_and_updates_outlined, color: AppColors.primaryGreen, size: 16),
                SizedBox(width: 6),
                Text('Dicas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              const SizedBox(height: 8),
              const _TipLine('Itens bem escolhidos aumentam sua motivação.'),
              const _TipLine('Mantenha sua loja equilibrada e significativa.'),
              const SizedBox(height: 20),
              const Text('Configurações da loja', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              _SettingsRow(
                icon: Icons.visibility_outlined,
                title: 'Exibir loja para o usuário',
                subtitle: 'Permite que os itens da loja fiquem visíveis no app.',
                trailing: Switch(value: _showToUser, onChanged: (v) => setState(() => _showToUser = v)),
              ),
              const SizedBox(height: 10),
              _SettingsRow(
                icon: Icons.swap_vert,
                title: 'Ordenação dos itens',
                subtitle: 'Define a ordem em que os itens aparecem na loja.',
                trailing: const Text('Personalizada', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.danger.withOpacity(0.4))),
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever_outlined, color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Limpar loja', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13)),
                          const Text('Remove todos os itens da loja.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _items.clear()),
                      child: const Text('Limpar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  final String text;
  const _TipLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SettingsRow({required this.icon, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
