import 'package:flutter/material.dart';
import '../models/store_item.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import 'store_management_screen.dart';
import '../data/mock_data.dart';

<<<<<<< Updated upstream
=======
// #$ StoreScreen — aba "Loja": itens cadastrados pelo próprio usuário
// #!! decisão do projeto: itens comprados NUNCA são apagados (ficam como
// registro). A aba "Recompensas" mostra só os NÃO comprados (purchase_at nulo)
// e a aba "Histórico" mostra os já comprados, do mais recente ao mais antigo.
>>>>>>> Stashed changes
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
<<<<<<< Updated upstream
  List<StoreItem> _items = [];
  int _gold = 0;
  bool _loading = true;
=======
  // #v TODOS os itens vindos da API (comprados e não comprados)
  List<StoreItem> _all = [];
  bool _loading = true;
  String? _error;
  // #v true se a API respondeu 404 (perfil ou loja não existem)
  bool _storeMissing = false;
  // #v id do item sendo comprado (trava cliques repetidos)
  String? _buyingId;
  // #v false = aba "Recompensas"; true = aba "Histórico" (já comprados)
  bool _showHistory = false;

  // #v itens à venda: os que ainda NÃO foram comprados
  List<StoreItem> get _available => _all.where((i) => !i.purchased).toList();

  // #v itens comprados, do mais recente para o mais antigo
  List<StoreItem> get _purchased {
    final list = _all.where((i) => i.purchased).toList();
    // ## purchasedAt nunca é null aqui (o filtro acima garante)
    list.sort((a, b) => b.purchasedAt!.compareTo(a.purchasedAt!));
    return list;
  }

  // #v total de ouro já gasto na loja (soma dos itens comprados)
  int get _totalSpent => _purchased.fold(0, (sum, i) => sum + i.cost);
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

<<<<<<< Updated upstream
  Future<void> _loadStore() async {
    final userId = CurrentUser.userId;
    if (userId == null) return;
    try {
      final profile = await GamifyApiService.instance.fetchProfile(userId);
      final items = await GamifyApiService.instance.fetchStoreItems(userId);
      if (mounted) {
        setState(() {
          _gold = profile?.gold ?? 0;
          _items = items.where((i) => i.active).toList();
          _loading = false;
        });
      }
=======
  // #f _load — GET /profiles/{uuid}/mystore e aplica os ícones salvos
  // ## guarda TODOS os itens; cada aba filtra o que mostra
  Future<void> _load() async {
    final userId = AuthService.instance.currentUser?.id;
    // #if sem sessão: avisa e para
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Sessão expirada, faça login novamente.';
      });
      return;
    }
    try {
      final items = await GamifyApiService.instance.fetchStore(userId);
      // ## põe em cada item o ícone que o usuário escolheu (guardado no navegador)
      final withIcons = items == null ? null : await StoreIconStorage.applyIcons(items);
      if (!mounted) return;
      setState(() {
        _storeMissing = withIcons == null;
        _all = withIcons ?? [];
        _error = null;
        _loading = false;
      });
>>>>>>> Stashed changes
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

<<<<<<< Updated upstream
  Future<void> _buy(StoreItem item) async {
    final userId = CurrentUser.userId;
    if (userId == null) return;
    if (_gold < item.cost) {
=======
  // #f _buy — PUT /profiles/{id}/purchaseItem/{itemId}
  // ## depois de comprar, recarrega: o item sai de "Recompensas" e vai para "Histórico"
  // #p item: item escolhido; gold: ouro atual do perfil
  Future<void> _buy(StoreItem item, int gold) async {
    // #if já tem uma compra em andamento
    if (_buyingId != null) return;
    // #if ouro insuficiente (a API também recusa com 409)
    if (gold < item.cost) {
>>>>>>> Stashed changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gold insuficiente para essa recompensa.')),
      );
      return;
    }
    try {
      await GamifyApiService.instance.purchaseStoreItem(userId: userId, itemId: item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recompensa resgatada: ${item.title}. Ela está no Histórico.')),
      );
      await _loadStore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao comprar recompensa: $e')),
        );
      }
    }
  }

<<<<<<< Updated upstream
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
=======
  // #f _openManagement — abre o gerenciamento e recarrega ao voltar
  Future<void> _openManagement() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const StoreManagementScreen()));
    if (mounted) _load();
  }

  // #f _formatDate — data da compra no formato dd/mm/aaaa às hh:mm
  // #p d: data/hora da compra (hora do computador onde a API roda)
  // #r texto pronto para a tela
  String _formatDate(DateTime d) {
    // #f dois dígitos (ex.: 5 -> "05")
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} às ${two(d.hour)}:${two(d.minute)}';
  }

  // #f _itemIcon — quadradinho colorido com o ícone do item
  // #p item: item da loja
  Widget _itemIcon(StoreItem item) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: item.iconColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 22),
      );

  // #f _statusBody — carregando, erro ou loja inexistente (vale para as duas abas)
  // #r lista de widgets, ou null se está tudo certo para mostrar a aba
  List<Widget>? _statusBody() {
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
    // #else tudo certo: a aba decide o que mostrar
    return null;
  }

  // #f _availableBody — aba "Recompensas": itens à venda com botão Comprar
  // #p gold: ouro atual do perfil
  List<Widget> _availableBody(int gold) {
    final items = _available;
    // #if vazio (nenhum item, ou todos já comprados)
    if (items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Nenhuma recompensa disponível. Use "Gerenciar Loja" para cadastrar novas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
        ),
      ];
    }
    return [
      for (final item in items) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _itemIcon(item),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.monetization_on, color: AppColors.gold, size: 14),
                      const SizedBox(width: 3),
                      Text('${item.cost}',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: _buyingId == null ? () => _buy(item, gold) : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _buyingId == item.id
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                            )
                          : const Text('Comprar',
                              style: TextStyle(
                                  color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  // #f _historyBody — aba "Histórico": registro do que já foi comprado
  // ## só leitura: não tem comprar, editar nem apagar (fica como registro)
  List<Widget> _historyBody() {
    final items = _purchased;
    // #if nada comprado ainda
    if (items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Você ainda não comprou nenhuma recompensa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
        ),
      ];
    }
    return [
      // ## resumo: quantas compras e quanto ouro já foi gasto
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Text('${items.length} ${items.length == 1 ? 'compra' : 'compras'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const Spacer(),
            const Text('Total gasto: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const Icon(Icons.monetization_on, color: AppColors.gold, size: 13),
            const SizedBox(width: 3),
            Text('$_totalSpent',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12.5)),
          ],
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      _itemIcon(items[i]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[i].title,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text('Comprado em ${_formatDate(items[i].purchasedAt!)}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(children: [
                        const Icon(Icons.monetization_on, color: AppColors.gold, size: 14),
                        const SizedBox(width: 3),
                        Text('-${items[i].cost}',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                      ]),
                    ],
                  ),
                ),
                if (i != items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  // #f _tab — título de aba com sublinhado verde quando selecionada
  // #p label: texto da aba; selected: se é a aba atual; onTap: troca de aba
  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 70,
            // ## só a aba selecionada mostra o sublinhado verde
            color: selected ? AppColors.primaryGreen : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ## o ouro vem do CurrentUser e atualiza sozinho depois de comprar
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: CurrentUser.notifier,
      builder: (context, profile, _) {
        final gold = profile?.gold ?? 0;
        // #v carregando/erro/404 (null = pode mostrar a aba)
        final status = _statusBody();
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
>>>>>>> Stashed changes
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Loja', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    const Icon(Icons.monetization_on, color: AppColors.gold, size: 16),
                    const SizedBox(width: 4),
                    Text('$_gold', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                  ]),
                  const Text('Gold', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
<<<<<<< Updated upstream
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            child: Text('Gaste seu ouro com recompensas reais.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recompensas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  Container(margin: const EdgeInsets.only(top: 4), height: 2, width: 70, color: AppColors.primaryGreen),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.of(context).push<List<StoreItem>>(
                    MaterialPageRoute(builder: (_) => StoreManagementScreen(items: List.of(MockData.storeItems))),
                  );
                  if (updated != null) setState(() => _items = updated.where((i) => i.active).toList());
                },
                icon: const Icon(Icons.settings, size: 15, color: AppColors.primaryGreen),
                label: const Text('Gerenciar Loja', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
=======
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 16),
                child: Text('Gaste seu ouro com recompensas reais.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ),
              Row(
                children: [
                  // ## abas: Recompensas (à venda) | Histórico (já comprados)
                  _tab('Recompensas', !_showHistory, () => setState(() => _showHistory = false)),
                  const SizedBox(width: 18),
                  _tab('Histórico', _showHistory, () => setState(() => _showHistory = true)),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _openManagement,
                    icon: const Icon(Icons.settings, size: 15, color: AppColors.primaryGreen),
                    label: const Text('Gerenciar Loja',
                        style: TextStyle(
                            color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // #if carregando/erro/404: mostra isso; senão, o conteúdo da aba
              ...(status ?? (_showHistory ? _historyBody() : _availableBody(gold))),
              const SizedBox(height: 12),
              const Center(child: Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 18)),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Recompensas são combustíveis para\na disciplina. Escolha com propósito.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
>>>>>>> Stashed changes
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in _items) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: item.iconColor.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                      child: Icon(item.icon, color: item.iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(Icons.monetization_on, color: AppColors.gold, size: 14),
                          const SizedBox(width: 3),
                          Text('${item.cost}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () => _buy(item),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Comprar', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          const Center(child: Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 18)),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Recompensas são combustíveis para\na disciplina. Escolha com propósito.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
