import 'package:flutter/material.dart';
import 'attribute.dart';

enum TaskFrequency { daily, weekly, monthly, once };

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
};

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
  // #v a API só diz se a tarefa faz parte de uma missão, não de qual
  final bool partOfMission;
  final TaskFrequency frequency;
  final int xpReward;
  final int goldReward;
  // #v API: completedInCurrentCycle
  final bool completedInCurrentCycle;
  // #v API: finished vem como "COMPLETED" ou "PENDING"
  final bool finished;
  final String? description;

  const GamifyTask({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.attribute,
    this.partOfMission = false,
    this.frequency = TaskFrequency.daily,
    required this.xpReward,
    required this.goldReward,
    this.completedInCurrentCycle = false,
    this.description,
  });

  bool get isDone => finished || completedInCurrentCycle;

  // #f fromJson: converte o TasksOutPutDTO da API em GamifyTask
  // #p json: mapa vindo do jsonDecode
  // #r GamifyTask pronta para as telas
      GamifyTask copyWith({bool? completedInCurrentCycle}) => GamifyTask(
          id: id,
          title: title,
          icon: icon,
          iconColor: iconColor,
          attribute: attribute,
          partOfMission: partOfMission,
          frequency: frequency,
          xpReward: xpReward,
          goldReward: goldReward,
          completedInCurrentCycle: completedInCurrentCycle ?? this.completedInCurrentCycle,
          finished: finished,
          description: description,
        );
  }

    GamifyTask copyWith({bool? completedInCurrentCycle}) => GamifyTask(
        id: id,
        title: title,
        icon: icon,
        iconColor: iconColor,
        attribute: attribute,
        partOfMission: partOfMission,
        frequency: frequency,
        xpReward: xpReward,
        goldReward: goldReward,
        completedInCurrentCycle: completedInCurrentCycle ?? this.completedInCurrentCycle,
        description: description,
      );


// #f _frequencyFromApi: texto do TaskFrequencyEnum -> enum do app
TaskFrequency _frequencyFromApi(String? value) => switch (value) {
      'DAILY' => TaskFrequency.daily,
      'WEEKLY' => TaskFrequency.weekly,
      'MONTHLY' => TaskFrequency.monthly,
      _ => TaskFrequency.once,
};