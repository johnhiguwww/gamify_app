import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// #$ StoreItem — recompensa real cadastrada pelo próprio usuário (Figuras 7 e 8).
class StoreItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final Color iconColor;
  final bool active;

  const StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.iconColor,
    this.active = true,
  });

  StoreItem copyWith({bool? active}) => StoreItem(
        id: id,
        title: title,
        description: description,
        cost: cost,
        icon: icon,
        iconColor: iconColor,
        active: active ?? this.active,
      );

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? (json['name'] as String?) ?? '';
    final value = (json['value'] as num?)?.toInt() ?? (json['cost'] as num?)?.toInt() ?? 0;
    final purchaseAt = json['purchase_at'] ?? json['purchaseAt'];
    return StoreItem(
      id: json['id']?.toString() ?? '',
      title: title,
      description: 'Recompensa da loja',
      cost: value,
      icon: Icons.card_giftcard,
      iconColor: AppColors.primaryGreen,
      active: purchaseAt == null,
    );
  }
}
