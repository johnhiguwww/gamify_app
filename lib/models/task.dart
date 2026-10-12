import 'package:flutter/material.dart';
import 'attribute.dart';

enum TaskFrequency { diaria, semanal, mensal, unica }

extension TaskFrequencyX on TaskFrequency {
  String get label => switch (this) {
        TaskFrequency.diaria => 'Diária',
        TaskFrequency.semanal => 'Semanal',
        TaskFrequency.mensal => 'Mensal',
        TaskFrequency.unica => 'Única',
      };
}

// #$ GamifyTask — #!! duas naturezas possíveis:
// - vinculada a uma missão (missionId != null): contribui pro progresso % da
//   missão e NÃO credita XP de atributo próprio.
// - "comum" (attribute != null, missionId == null): credita XP direto ao
//   atributo a cada conclusão do ciclo (frequency).
class GamifyTask {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final AttributeType? attribute;
  final String? missionId;
  final TaskFrequency frequency;
  final int xpReward;
  final int goldReward;
  final int goalQuantity;
  final String goalUnit;
  final int currentQuantity; // #v progresso do ciclo atual (ex: 2/3)
  final bool reminderEnabled;
  final String? description;

  const GamifyTask({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.attribute,
    this.missionId,
    this.frequency = TaskFrequency.diaria,
    required this.xpReward,
    required this.goldReward,
    this.goalQuantity = 1,
    this.goalUnit = 'vez',
    this.currentQuantity = 0,
    this.reminderEnabled = false,
    this.description,
  });

  bool get isDone => currentQuantity >= goalQuantity;

  GamifyTask copyWith({int? currentQuantity}) => GamifyTask(
        id: id,
        title: title,
        icon: icon,
        iconColor: iconColor,
        attribute: attribute,
        missionId: missionId,
        frequency: frequency,
        xpReward: xpReward,
        goldReward: goldReward,
        goalQuantity: goalQuantity,
        goalUnit: goalUnit,
        currentQuantity: currentQuantity ?? this.currentQuantity,
        reminderEnabled: reminderEnabled,
        description: description,
      );
}
