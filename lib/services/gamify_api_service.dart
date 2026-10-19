import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/mission.dart';
import '../models/task.dart';
import 'auth_service.dart';
import 'current_user.dart';

// #$ GamifyApiService — encapsula as chamadas HTTP pra sua API Java
// (Spring Boot). #!! troque baseUrl pela URL onde a API estiver hospedada.
// Enquanto estiver testando local, use http://localhost:8080.
class GamifyApiService {
  GamifyApiService._();
  static final GamifyApiService instance = GamifyApiService._();

  // #!! sem "/" no final: as rotas abaixo já começam com "/"
  static const String baseUrl = 'http://localhost:8080';

  // #f fetchProfile — GET /profiles/by-user-uuid/{uuid}; null se 404
  Future<UserProfile?> fetchProfile(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/by-user-uuid/$userId');
    final response = await http.get(uri);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar perfil (${response.statusCode}): ${response.body}');
    }
    return UserProfile.fromApi(jsonDecode(response.body));
  }

  // #f _refreshCurrentProfile — recarrega o perfil e atualiza o CurrentUser
  Future<void> _refreshCurrentProfile() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;
      final profile = await fetchProfile(userId);
      if (profile != null) CurrentUser.profile = profile;
    } catch (_) {
      // ## falhar ao atualizar o cabeçalho não pode atrapalhar a conclusão
    }
  }

  // #f createOrGetProfile — POST /profiles/new (chamado após o login)
  Future<UserProfile> createOrGetProfile({
    required String userId,
    required String email,
    required String name,
    String avatarUrl = '',
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/new');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao criar perfil (${response.statusCode}): ${response.body}');
    }
    return UserProfile.fromApi(jsonDecode(response.body));
  }

  // #f createTask — POST /tasks/newtask (TasksInputDTO)
  // frequency: UNIQUE, DAILY, WEEKLY ou MONTHLY; attributes: snake_case
  Future<void> createTask({
    required String profileUuid,
    required String title,
    required String description,
    required int reward,
    required int experience,
    required String attributes,
    required String frequency,
    List<String>? daysOfWeek,
  }) async {
    final uri = Uri.parse('$baseUrl/tasks/newtask');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'profileUuid': profileUuid,
        'title': title,
        'description': description,
        'reward': reward,
        'experience': experience,
        'attributes': attributes,
        'frequency': frequency,
        if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
        'partOfMission': false,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao criar tarefa (${response.statusCode}): ${response.body}');
    }
  }

  // #f fetchTasks — GET /profiles/{uuid}/my_tasks (lista de TasksDTO)
  Future<List<GamifyTask>> fetchTasks(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_tasks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao listar tarefas (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return [for (final e in list) GamifyTask.fromJson(e as Map<String, dynamic>)];
  }

  // #f completeTask — POST /tasks/complete (corpo {"taskId"})
  // #!! a API marca a tarefa como finished para sempre (mesmo as recorrentes);
  // uma segunda chamada na mesma tarefa dá erro de "já concluída".
  // ## o ProfileDTO devolvido atualiza o CurrentUser (ouro, atributos)
  // #r mapa do ProfileDTO atualizado
  Future<Map<String, dynamic>> completeTask(String taskId) async {
    final uri = Uri.parse('$baseUrl/tasks/complete');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'taskId': taskId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao concluir tarefa (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    CurrentUser.profile = UserProfile.fromApi(data);
    return data;
  }

  // #f createMission — POST /missions/new
  Future<void> createMission({
    required String userId,
    required String title,
    required int reward,
    required int experience,
  }) async {
    final uri = Uri.parse('$baseUrl/missions/new');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'reward': reward,
        'experience': experience,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar missão (${response.statusCode}): ${response.body}');
    }
  }

  // #f fetchMissions — GET /profiles/{uuid}/my_missions
  Future<List<Mission>> fetchMissions(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_missions');
    final response = await http.get(uri);
    // #if a API não devolveu 200: avisa com o código e o corpo
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar missões (${response.statusCode}): ${response.body}');
    }
    // ## utf8.decode(bodyBytes): sem isso os acentos podem quebrar
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((item) => Mission.fromJson(item as Map<String, dynamic>)).toList();
  }

  // #f completeMission — PUT /missions/complete/{missionId}
  // ## depois de concluir, recarrega o perfil (XP e ouro do cabeçalho)
  Future<void> completeMission(String missionId) async {
    final uri = Uri.parse('$baseUrl/missions/complete/$missionId');
    final response = await http.put(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao concluir missão (${response.statusCode}): ${response.body}');
    }
    await _refreshCurrentProfile();
  }
}