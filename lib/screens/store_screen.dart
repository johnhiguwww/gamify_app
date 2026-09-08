import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/store_item.dart';
import '../theme/app_colors.dart';
import 'store_management_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late List<StoreItem> _items = List.of(MockData.storeItems.where((i) => i.active));
  int _gold = MockData.user.gold;

  void _buy(StoreItem item) {
    if (_gold < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gold insuficiente para essa recompensa.')),
      );
      return;
    }
    setState(() => _gold -= item.cost);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recompensa resgatada: ${item.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
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
