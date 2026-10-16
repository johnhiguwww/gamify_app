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

// #$ AttributeProgress — progresso de um atributo do usuário logado.
// #v currentXp vem direto de `atributes.<campo>` da API; o teto é sempre 100
// #$ AttributeProgress — progresso de um atributo do usuário logado.
// #v total vem direto de `atributes.<campo>` da API (acumulado); o teto é sempre 100
class AttributeProgress {
  final AttributeType type;
  final int total;

  const AttributeProgress({
    required this.type,
    required this.total,
  });

  // #v teto fixo de todo atributo (só o nível sobe, o teto não)
  int get maxXp => 100;

  // #v nível do atributo: 1 até 99, 2 de 100 a 199, e assim por diante
  int get level => (total < 0 ? 0 : total) ~/ maxXp + 1;

  // #v XP dentro do nível atual (0 a 99)
  int get currentXp => (total < 0 ? 0 : total) % maxXp;

  // #v proporção de 0 a 1 usada pela barra de progresso
  double get ratio => currentXp / maxXp;
}
