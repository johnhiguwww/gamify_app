import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'attribute.dart';

enum TaskFrequency { daily, weekly, monthly, once }

// #$ Extensão que adiciona o getter `label` ao enum TaskFrequency
extension TaskFrequencyX on TaskFrequency {
  // #f Devolve o texto em português mostrado na tela para cada frequência
  // #r String com o rótulo
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

// #$ GamifyTask — modelo da tarefa, montado a partir do TasksDTO da API
class GamifyTask {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  // #!! o TasksDTO NÃO traz o atributo da tarefa, então aqui fica sempre null
  final AttributeType? attribute;
  // #v a API só diz se a tarefa faz parte de uma missão, não de qual
  final bool partOfMission;
  final TaskFrequency frequency;
  final int xpReward;
  final int goldReward;
  // #v API: completedInCurrentCycle
  final bool completedInCurrentCycle;
  // #v API: finished (String no TasksDTO)
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
    this.finished = false,
    this.description,
  });

  bool get isDone => finished || completedInCurrentCycle;

  // #f fromJson: converte o TasksDTO da API em GamifyTask
  // #p json: mapa vindo do jsonDecode
  // #r GamifyTask pronta para as telas
  // ## campos usados (todos do TasksDTO): id, title, description, reward,
  // experience, finished, partOfMission, frequency, completedInCurrentCycle
  factory GamifyTask.fromJson(Map<String, dynamic> json) {
    return GamifyTask(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      // #t ícone e cor provisórios: a API não manda o atributo
      icon: Icons.checklist_rounded,
      iconColor: AppColors.primaryGreen,
      partOfMission: json['partOfMission'] == true,
      frequency: _frequencyFromApi(json['frequency']?.toString()),
      xpReward: (json['experience'] as num?)?.toInt() ?? 0,
      goldReward: (json['reward'] as num?)?.toInt() ?? 0,
      completedInCurrentCycle: json['completedInCurrentCycle'] == true,
      // #!! os valores possíveis de "finished" NÃO estão confirmados no Java
      // (o exemplo do DTO diz "PENDING"; "COMPLETED" vem do comentário antigo).
      finished: _finishedFromApi(json['finished']),
      description: json['description']?.toString(),
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
        finished: finished,
        description: description,
      );
}

// #f _frequencyFromApi: texto do TaskFrequencyEnum (UNIQUE, DAILY, WEEKLY, MONTHLY) -> enum do app
TaskFrequency _frequencyFromApi(String? value) => switch (value) {
      'DAILY' => TaskFrequency.daily,
      'WEEKLY' => TaskFrequency.weekly,
      'MONTHLY' => TaskFrequency.monthly,
      _ => TaskFrequency.once,
    };

// #f _finishedFromApi: o campo "finished" chega como String
// #!! provisório até eu ver a entidade Tasks.java
bool _finishedFromApi(dynamic value) {
  if (value is bool) return value;
  final v = value?.toString().toUpperCase();
  return v == 'COMPLETED' || v == 'TRUE' || v == 'FINISHED';
}