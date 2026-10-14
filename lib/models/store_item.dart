import 'package:flutter/material.dart';

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
}
