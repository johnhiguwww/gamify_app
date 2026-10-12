import 'package:flutter/material.dart';
import 'attribute.dart';

enum MissionStatus { ativa, pendente, concluida }

enum MissionDifficulty { facil, media, alta }

enum MissionKind { individual, compartilhada }

// #$ Mission — ao concluir credita xpReward ao XP_Total do usuário (não ao
// atributo) e goldReward ao saldo de Gold. progress é a % mostrada na barra.
class Mission {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final AttributeType attribute;
  final MissionDifficulty difficulty;
  final MissionStatus status;
  final MissionKind kind;
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
    required this.icon,
    required this.iconColor,
    required this.attribute,
    required this.difficulty,
    required this.status,
    this.kind = MissionKind.individual,
    required this.progress,
    required this.xpReward,
    required this.goldReward,
    required this.daysLeft,
    this.description,
    this.startDate,
    this.endDate,
  });
}

extension MissionDifficultyX on MissionDifficulty {
  String get label => switch (this) {
        MissionDifficulty.facil => 'Fácil',
        MissionDifficulty.media => 'Média',
        MissionDifficulty.alta => 'Alta',
      };
}
