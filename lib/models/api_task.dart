// #$ ApiTask — espelho do TasksDTO da API Java Spring Boot.
// Usado nas telas que consomem dados reais (Dashboard, Tarefas).
class ApiTask {
  final String id;
  final String title;
  final String description;
  final int reward;   // gold
  final int experience; // xp
  final String finished; // "PENDING" | "COMPLETED"
  final bool partOfMission;
  final String frequency; // "UNICA" | "DIARIO" | "SEMANAL" | "MENSAL"
  final bool completedInCurrentCycle;

  const ApiTask({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.experience,
    required this.finished,
    required this.partOfMission,
    required this.frequency,
    required this.completedInCurrentCycle,
  });

  bool get isDone => completedInCurrentCycle || finished == 'COMPLETED';

  // #f fromJson — constrói ApiTask a partir do JSON do endpoint
  // GET /profiles/{uuid}/my_tasks.
  factory ApiTask.fromJson(Map<String, dynamic> json) {
    return ApiTask(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      finished: (json['finished'] as String?) ?? 'PENDING',
      partOfMission: (json['partOfMission'] as bool?) ?? false,
      frequency: (json['frequency'] as String?) ?? 'UNICA',
      completedInCurrentCycle: (json['completedInCurrentCycle'] as bool?) ?? false,
    );
  }

  String get frequencyLabel => switch (frequency) {
        'DIARIO' => 'Diária',
        'SEMANAL' => 'Semanal',
        'MENSAL' => 'Mensal',
        _ => 'Única',
      };
}
