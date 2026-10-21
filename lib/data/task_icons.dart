import 'package:flutter/material.dart';

// #$ TaskIconOption — um ícone que o usuário pode escolher para uma tarefa
// ## mesmo modelo dos ícones da loja (StoreIconOption)
class TaskIconOption {
  // #v chave estável salva no navegador (nunca mude depois de publicar)
  final String key;
  // #v nome mostrado no tooltip
  final String label;
  // #v desenho do ícone
  final IconData icon;
  // #v cor do ícone (o fundo usa a mesma cor, mais clara)
  final Color color;

  const TaskIconOption(this.key, this.label, this.icon, this.color);
}

// #v lista de ícones disponíveis para tarefas; o primeiro é o padrão
// #!! a API NÃO guarda ícone de tarefa: isto vive só no app (TaskIconStorage)
const List<TaskIconOption> taskIconOptions = [
  TaskIconOption('check', 'Tarefa', Icons.checklist_rounded, Color(0xFF22C55E)),
  TaskIconOption('pray', 'Oração', Icons.volunteer_activism, Color(0xFFFBBF24)),
  TaskIconOption('church', 'Igreja', Icons.church, Color(0xFFA855F7)),
  TaskIconOption('meditate', 'Meditar', Icons.self_improvement, Color(0xFF14B8A6)),
  TaskIconOption('book', 'Leitura', Icons.menu_book, Color(0xFF3B82F6)),
  TaskIconOption('study', 'Estudo', Icons.school, Color(0xFF6366F1)),
  TaskIconOption('language', 'Idioma', Icons.translate, Color(0xFF06B6D4)),
  TaskIconOption('code', 'Programar', Icons.code, Color(0xFF22C55E)),
  TaskIconOption('work', 'Trabalho', Icons.work, Color(0xFFB45309)),
  TaskIconOption('gym', 'Treino', Icons.fitness_center, Color(0xFFEF4444)),
  TaskIconOption('run', 'Corrida', Icons.directions_run, Color(0xFFF97316)),
  TaskIconOption('walk', 'Caminhada', Icons.directions_walk, Color(0xFF84CC16)),
  TaskIconOption('water', 'Água', Icons.water_drop, Color(0xFF3B82F6)),
  TaskIconOption('food', 'Alimentação', Icons.restaurant, Color(0xFFF59E0B)),
  TaskIconOption('sleep', 'Sono', Icons.bedtime, Color(0xFF8B5CF6)),
  TaskIconOption('music', 'Música', Icons.music_note, Color(0xFFEC4899)),
  TaskIconOption('piano', 'Instrumento', Icons.piano, Color(0xFFDB2777)),
  TaskIconOption('art', 'Arte', Icons.brush, Color(0xFFF472B6)),
  TaskIconOption('heart', 'Coração', Icons.favorite, Color(0xFFEF4444)),
  TaskIconOption('people', 'Pessoas', Icons.groups, Color(0xFF0EA5E9)),
  TaskIconOption('home', 'Casa', Icons.cleaning_services, Color(0xFF14B8A6)),
  TaskIconOption('money', 'Finanças', Icons.savings, Color(0xFFEAB308)),
  TaskIconOption('sun', 'Manhã', Icons.wb_sunny, Color(0xFFFBBF24)),
  TaskIconOption('nature', 'Natureza', Icons.park, Color(0xFF16A34A)),
];

// #f taskIconByKey — acha o ícone pela chave
// #p key: chave salva (pode ser null)
// #r o ícone; se a chave for nula ou desconhecida, devolve o padrão
TaskIconOption taskIconByKey(String? key) {
  // #if achou a chave: devolve o ícone correspondente
  for (final o in taskIconOptions) {
    if (o.key == key) return o;
  }
  // #else não achou: ícone padrão (o primeiro da lista)
  return taskIconOptions.first;
}
