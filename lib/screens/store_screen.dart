import 'package:flutter/material.dart';
import '../models/store_item.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../services/store_icon_storage.dart';
import '../theme/app_colors.dart';
import 'store_management_screen.dart';

// #$ StoreScreen — aba "Loja": itens cadastrados pelo próprio usuário
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // #v itens vindos da API
  List<StoreItem> _items = [];
  bool _loading = true;
  String? _error;
  // #v true se a API respondeu 404 (perfil ou loja não existem)
  bool _storeMissing = false;
  // #v id do item sendo comprado (trava cliques repetidos)
  String? _buyingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // #f _load — GET /profiles/{uuid}/mystore e aplica os ícones salvos
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

  // #f _buy — PUT /profiles/{id}/purchaseItem/{itemId}
  // #p item: item escolhido; gold: ouro atual do perfil
  Future<void> _buy(StoreItem item, int gold) async {
    // #if já tem uma compra em andamento
    if (_buyingId != null) return;
    // #if ouro insuficiente (a API também recusa com 409)
    if (gold < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gold insuficiente para essa recompensa.')),
      );
      return;
    }
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;
    setState(() => _buyingId = item.id);
    try {
      await GamifyApiService.instance.purchaseStoreItem(userId: userId, itemId: item.id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recompensa resgatada: ${item.title}')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível comprar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _buyingId = null);
    }
  }

  // #f _openManagement — abre o gerenciamento e recarrega ao voltar
  Future<void> _openManagement() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const StoreManagementScreen()));
    if (mounted) _load();
  }

  // #f _fmt — data no formato dd/mm/aaaa
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // #f _body — carregando, erro, loja inexistente, vazio ou a lista
  List<Widget> _body(int gold) {
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
    // #if vazio
    if (_items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Sua loja está vazia. Use "Gerenciar Loja" para cadastrar recompensas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
        ),
      ];
    }
    return [
      for (final item in _items) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                      // #if já foi comprado: mostra a data da última compra
                      if (item.purchasedAt != null) ...[
                        const SizedBox(height: 2),
                        Text('Comprado em ${_fmt(item.purchasedAt!)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      ],
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
                          : Text(item.purchased ? 'Comprar de novo' : 'Comprar',
                              style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    // ## o ouro vem do CurrentUser e atualiza sozinho depois de comprar
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: CurrentUser.notifier,
      builder: (context, profile, _) {
        final gold = profile?.gold ?? 0;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Loja',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        const Icon(Icons.monetization_on, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text('$gold',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                      ]),
                      const Text('Gold', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 16),
                child: Text('Gaste seu ouro com recompensas reais.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recompensas',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                      Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2,
                          width: 70,
                          color: AppColors.primaryGreen),
                    ],
                  ),
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
              ..._body(gold),
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
      },
    );
  }
}