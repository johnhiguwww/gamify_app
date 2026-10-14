import 'package:flutter/material.dart';
import 'attribute.dart';

enum TaskFrequency { daily, weekly, monthly, once }

// #$ Extensão que adiciona o getter `label` ao enum TaskFrequency
extension TaskFrequencyX on TaskFrequency {
  // #f Devolve o texto em português mostrado na tela para cada frequência
  // #r String com o rótulo (continua em português, como pedido)
  String get label => switch (this) {
        // ## diaria -> daily
        TaskFrequency.daily => 'Diária',
        // ## semanal -> weekly
        TaskFrequency.weekly => 'Semanal',
        // ## mensal -> monthly
        TaskFrequency.monthly => 'Mensal',
        // ## unica -> once
        TaskFrequency.once => 'Única',
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
  final AttributeType? attribute;
  final String? missionId;
  final TaskFrequency frequency;
  final int xpReward;
  final int goldReward;
  final int goalQuantity;
  final String goalUnit;
  final int currentQuantity; // #v progresso do ciclo atual (ex: 2/3)
  final String? description;

  const GamifyTask({
    required this.id,
    required this.title,
    this.attribute,
    this.missionId,
    this.frequency = TaskFrequency.daily,
    required this.xpReward,
    required this.goldReward,
    this.goalQuantity = 1,
    this.goalUnit = 'vez',
    this.currentQuantity = 0,
    this.description,
  });

  bool get isDone => currentQuantity >= goalQuantity;

  GamifyTask copyWith({int? currentQuantity}) => GamifyTask(
        id: id,
        title: title,
        attribute: attribute,
        missionId: missionId,
        frequency: frequency,
        xpReward: xpReward,
        goldReward: goldReward,
        goalQuantity: goalQuantity,
        goalUnit: goalUnit,
        currentQuantity: currentQuantity ?? this.currentQuantity,
        description: description,
      );
}
