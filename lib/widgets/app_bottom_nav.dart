import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.track_changes_rounded, label: 'Missões'),
    (icon: Icons.checklist_rounded, label: 'Tarefas'),
    (icon: Icons.storefront_rounded, label: 'Loja'),
    (icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final selected = i == currentIndex;
            final color = selected ? AppColors.primaryGreen : AppColors.textSecondary;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_items[i].icon, color: color, size: 24),
                  const SizedBox(height: 3),
                  Text(_items[i].label, style: TextStyle(color: color, fontSize: 11)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
