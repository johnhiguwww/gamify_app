import 'package:flutter/material.dart';

// #$ AttributeType — as 9 inteligências de Gardner mapeadas no Gamify.
// #!! a ordem aqui é a mesma exibida no dashboard (Figura 3); não reordenar
// sem atualizar o mock, senão o ícone/cor sai da linha errada.
enum AttributeType {
  inteligencia,
  forca,
  espiritualidade,
  carisma,
  percepcaoEspacial,
  autoconsciencia,
  linguagem,
  raciocinioLogico,
  musicalidade,
}

extension AttributeTypeX on AttributeType {
  String get label => switch (this) {
        AttributeType.inteligencia => 'Inteligência',
        AttributeType.forca => 'Força',
        AttributeType.espiritualidade => 'Espiritualidade',
        AttributeType.carisma => 'Carisma',
        AttributeType.percepcaoEspacial => 'Percepção Espacial',
        AttributeType.autoconsciencia => 'Autoconsciência',
        AttributeType.linguagem => 'Linguagem',
        AttributeType.raciocinioLogico => 'Raciocínio Lógico',
        AttributeType.musicalidade => 'Musicalidade',
      };

  IconData get icon => switch (this) {
        AttributeType.inteligencia => Icons.psychology,
        AttributeType.forca => Icons.fitness_center,
        AttributeType.espiritualidade => Icons.self_improvement,
        AttributeType.carisma => Icons.emoji_emotions,
        AttributeType.percepcaoEspacial => Icons.blur_on,
        AttributeType.autoconsciencia => Icons.edit,
        AttributeType.linguagem => Icons.translate,
        AttributeType.raciocinioLogico => Icons.route,
        AttributeType.musicalidade => Icons.music_note,
      };
}

// #$ AttributeProgress — estado atual de um atributo pro usuário logado.
class AttributeProgress {
  final AttributeType type;
  final int level;
  final int currentXp;
  final int maxXp; // #v teto do nível atual (regra: 100 + 10*(nível-1))

  const AttributeProgress({
    required this.type,
    required this.level,
    required this.currentXp,
    required this.maxXp,
  });

  double get ratio => maxXp == 0 ? 0 : (currentXp / maxXp).clamp(0, 1);
}
