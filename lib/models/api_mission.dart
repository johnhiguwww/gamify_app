// #$ ApiMission — espelho do MissionOutPutDTO da API Java Spring Boot.
// Usado nas telas que consomem dados reais (Dashboard, Missões).
class ApiMission {
  final String id;
  final String title;
  final int experience; // xp
  final int reward;     // gold
  final bool finished;

  const ApiMission({
    required this.id,
    required this.title,
    required this.experience,
    required this.reward,
    required this.finished,
  });

  // #f fromJson — constrói ApiMission a partir do JSON do endpoint
  // GET /profiles/{uuid}/my_missions.
  factory ApiMission.fromJson(Map<String, dynamic> json) {
    return ApiMission(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      finished: (json['finished'] as bool?) ?? false,
    );
  }
}
