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

  // #f cycleLength — quanto tempo a tarefa fica "concluída" antes de renovar
  // #!! REGRA DO APP (não existe na API; citar no TCC): Diária = 24 h,
  // Semanal = 7 dias, Mensal = 30 dias. Única não renova (null).
  // #r Duration do ciclo, ou null para tarefa única
  Duration? get cycleLength => switch (this) {
        // ## diária: volta 24 horas depois da última conclusão
        TaskFrequency.daily => const Duration(hours: 24),
        // ## semanal: volta 7 dias depois
        TaskFrequency.weekly => const Duration(days: 7),
        // ## mensal: volta 30 dias depois (mês "fixo" de 30 dias)
        TaskFrequency.monthly => const Duration(days: 30),
        // ## única: conclui uma vez só, para sempre
        TaskFrequency.once => null,
      };
}

// #$ GamifyTask — modelo da tarefa, montado a partir do TasksDTO da API
class GamifyTask {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  // #v chave do ícone escolhido pelo usuário (TaskIconOption.key)
  // ## guardada só no navegador (TaskIconStorage); null = ícone padrão
  final String? iconKey;
  // #!! o TasksDTO NÃO traz o atributo da tarefa: o valor vem do navegador
  // (TaskIconStorage), salvo quando a tarefa é criada/editada neste app.
  // null = desconhecido (tarefa antiga ou outro navegador)
  final AttributeType? attribute;
  // #v a API só diz se a tarefa faz parte de uma missão, não de qual
  final bool partOfMission;
  final TaskFrequency frequency;
  final int xpReward;
  final int goldReward;
  // #v API: completedInCurrentCycle
  // #! a API atual nunca muda esse campo para true (nem no complete-cycle);
  // fica aqui só por segurança, caso o desenvolvedor passe a usá-lo
  final bool completedInCurrentCycle;
  // #v API: finished ("PENDING" ou "COMPLETED" no TasksDTO)
  // ## true = encerrada para sempre (POST /tasks/complete)
  final bool finished;
  // #v API: lastCompletedAt — data/hora da última conclusão de ciclo
  // (PUT /tasks/complete-cycle). null = nunca concluída por ciclo.
  // #!! a API grava com a hora do computador onde ela roda (LocalDateTime,
  // sem fuso); o app lê como hora local
  final DateTime? lastCompletedAt;
  final String? description;
  // #v API: daysOfWeek (lista; a API guarda UM dia, nome por extenso: MONDAY..SUNDAY)
  // ## usado para preencher o formulário de edição
  final List<String> daysOfWeek;

  const GamifyTask({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.iconKey,
    this.attribute,
    this.partOfMission = false,
    this.frequency = TaskFrequency.daily,
    required this.xpReward,
    required this.goldReward,
    this.completedInCurrentCycle = false,
    this.finished = false,
    this.lastCompletedAt,
    this.description,
    this.daysOfWeek = const [],
  });

  // #f isRecurring — tarefa que renova (Diária, Semanal ou Mensal)
  // #r true se a frequência não for Única
  bool get isRecurring => frequency.cycleLength != null;

  // #f availableAgainAt — quando a tarefa recorrente volta a ficar pendente
  // #r data/hora da renovação, ou null (única, ou nunca concluída)
  DateTime? get availableAgainAt {
    // #v duração do ciclo da frequência (null = única)
    final cycle = frequency.cycleLength;
    // #if única ou nunca concluída por ciclo: não há renovação a calcular
    if (cycle == null || lastCompletedAt == null) return null;
    // ## última conclusão + duração do ciclo
    return lastCompletedAt!.add(cycle);
  }

  // #f doneInCycle — recorrente concluída e ainda dentro do período
  // #r true enquanto não chegar a hora de renovar
  bool get doneInCycle {
    // #v momento da renovação
    final again = availableAgainAt;
    // #if sem renovação calculada: não está concluída no ciclo
    if (again == null) return false;
    // ## concluída enquanto "agora" ainda for antes da renovação
    return DateTime.now().isBefore(again);
  }

  // #f isDone — o que a tela mostra como "concluída"
  // ## encerrada para sempre (finished) OU concluída no ciclo atual
  bool get isDone => finished || completedInCurrentCycle || doneInCycle;

  // #f renewLabel — texto curto de quando a tarefa volta (ex.: "Renova em 5 h")
  // #r texto, ou null se não estiver esperando renovação
  String? get renewLabel {
    // #if não está concluída no ciclo: não há o que mostrar
    if (!doneInCycle) return null;
    // #v quanto falta até renovar
    final left = availableAgainAt!.difference(DateTime.now());
    // #if falta 1 dia ou mais: mostra em dias
    if (left.inDays >= 1) return 'Renova em ${left.inDays} d';
    // #elseif falta 1 hora ou mais: mostra em horas
    if (left.inHours >= 1) return 'Renova em ${left.inHours} h';
    // #else menos de 1 hora: mostra em minutos (mínimo 1)
    final minutes = left.inMinutes < 1 ? 1 : left.inMinutes;
    return 'Renova em $minutes min';
  }

  // #f fromJson: converte o TasksDTO da API em GamifyTask
  // #p json: mapa vindo do jsonDecode
  // #r GamifyTask pronta para as telas
  // ## campos usados (todos do TasksDTO): id, title, description, reward,
  // experience, finished, partOfMission, frequency, completedInCurrentCycle,
  // lastCompletedAt, daysOfWeek
  factory GamifyTask.fromJson(Map<String, dynamic> json) {
    // #v daysOfWeek chega como lista (ou null); vira lista de String
    final rawDays = json['daysOfWeek'];
    final days = rawDays is List ? [for (final d in rawDays) d.toString()] : <String>[];
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
      // ## confirmado em Task.toDTO(): "COMPLETED" se finished, senão "PENDING"
      finished: _finishedFromApi(json['finished']),
      // ## "2026-10-20T22:20:49.123" (sem fuso) -> DateTime local; null se vazio
      lastCompletedAt: _dateFromApi(json['lastCompletedAt']),
      description: json['description']?.toString(),
      daysOfWeek: days,
    );
  }

  // #f copyWith — cópia da tarefa trocando só os campos informados
  // ## usado pelo TaskIconStorage para aplicar ícone/cor/atributo salvos
  GamifyTask copyWith({
    bool? completedInCurrentCycle,
    DateTime? lastCompletedAt,
    IconData? icon,
    Color? iconColor,
    String? iconKey,
    AttributeType? attribute,
  }) =>
      GamifyTask(
        id: id,
        title: title,
        icon: icon ?? this.icon,
        iconColor: iconColor ?? this.iconColor,
        iconKey: iconKey ?? this.iconKey,
        attribute: attribute ?? this.attribute,
        partOfMission: partOfMission,
        frequency: frequency,
        xpReward: xpReward,
        goldReward: goldReward,
        completedInCurrentCycle: completedInCurrentCycle ?? this.completedInCurrentCycle,
        finished: finished,
        lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
        description: description,
        daysOfWeek: daysOfWeek,
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
// ## confirmado no Task.java: "COMPLETED" ou "PENDING"
bool _finishedFromApi(dynamic value) {
  if (value is bool) return value;
  final v = value?.toString().toUpperCase();
  return v == 'COMPLETED';
}

// #f _dateFromApi: converte o texto de data da API em DateTime
// #p value: texto ISO sem fuso (LocalDateTime do Java) ou null
// #r DateTime local, ou null se vier vazio/inválido
DateTime? _dateFromApi(dynamic value) {
  // #if não veio nada: sem data
  if (value == null) return null;
  // ## tryParse devolve null se o texto não for uma data válida
  return DateTime.tryParse(value.toString());
}
