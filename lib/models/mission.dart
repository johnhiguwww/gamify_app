import 'package:flutter/material.dart';
import 'attribute.dart';

// #$ Mission: ao concluir credita xpReward ao XP_Total do usuário (não ao
// atributo) e goldReward ao saldo de Gold. progress é a % mostrada na barra.
class Mission {
  final String id;
  final String title;
  final AttributeType attribute;
  final double progress; // #v 0..1
  final int xpReward;
  final int goldReward;
  final int daysLeft;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  const Mission({
    required this.id,
    required this.title,
    required this.attribute,
    required this.progress,
    required this.xpReward,
    required this.goldReward,
    required this.daysLeft,
    this.description,
    this.startDate,
    this.endDate,
  });
}