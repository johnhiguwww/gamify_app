import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/mission.dart';
import '../models/task.dart'

// #$ GamifyApiService — encapsula as chamadas HTTP pra sua API Java
// (Spring Boot). #!! troque baseUrl pela URL onde a API estiver hospedada
// (ex: https://gamify-api.onrender.com). Enquanto estiver testando local,
// use http://localhost:8080 — mas lembre que isso só funciona se o Flutter
// também estiver rodando local (Chrome), nunca a partir do site publicado.
class GamifyApiService {
  GamifyApiService._();
  static final GamifyApiService instance = GamifyApiService._();

  //# CloudFire - API conectada com o Flutter
  static const String baseUrl = 'http://localhost:8080/';
//https://jelsoft-benefit-season-solomon.trycloudflare.com
  // #f fetchProfile — busca o perfil pelo UUID do usuário (o mesmo id do
  // Supabase Auth). Devolve null se o perfil ainda não existe (404).
  Future<UserProfile?> fetchProfile(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/by-user-uuid/$userId');
    final response = await http.get(uri);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar perfil (${response.statusCode}): ${response.body}');
    }
    return UserProfile.fromApi(jsonDecode(response.body));
  }

  // #f createOrGetProfile — chamado logo após o primeiro login com Google.
  // Se o perfil já existir na API, ela mesma devolve o existente (sem
  // duplicar); senão, cria um novo com nível 1.
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

  // #f fetchTasks — lista as tarefas do perfil logado.
  Future<List<dynamic>> fetchTasks(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_tasks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar tarefas (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  // #f createTask — cria uma tarefa nova pro perfil informado, chamado
  // pela tela "Nova Tarefa". frequency deve ser um dos valores aceitos
  // pelo backend: UNICA, DIARIO, SEMANAL, MENSAL.
   // #f createTask — POST /tasks/newtask (TasksInputDTO)
  // #r void; a API responde 201 com a tarefa criada
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
  // #p userId: id do usuário (igual ao id do perfil no banco)
  Future<List<GamifyTask>> fetchTasks(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_tasks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao listar tarefas (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return [for (final e in list) GamifyTask.fromJson(e as Map<String, dynamic>)];
  }

  // #f completeTask — POST /tasks/complete (tarefa única)
  // #r mapa do ProfileDTO atualizado; a API responde 200, 404 ou 409
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
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  // #f completeTaskCycle — PUT /tasks/complete-cycle/{taskId} (tarefa recorrente)
  // #r void; a API responde 200, 404 ou 409
  Future<void> completeTaskCycle(String taskId) async {
    final uri = Uri.parse('$baseUrl/tasks/complete-cycle/$taskId');
    final response = await http.put(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao concluir ciclo (${response.statusCode}): ${response.body}');
    }
  }

  // #f createMission — cria uma missão nova pro usuário informado,
  // chamado pela tela "Nova Missão".
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

  // #f: fetchMissions — lista as missões do perfil (GET /profiles/{uuid}/my_missions).
  // #p: userId: UUID do usuário (o mesmo id do Supabase Auth)
  // #r: lista de Mission; lança Exception se a API não responder 200
  Future<List<Mission>> fetchMissions(String userId) async {
    // ## monta a URL com o prefixo /profiles
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_missions');
    final response = await http.get(uri);

    // #if: a API não devolveu 200: avisa com o código e o corpo
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar missões (${response.statusCode}): ${response.body}');
    }

    // ##: utf8.decode(bodyBytes): sem isso os acentos podem quebrar
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

    // ##: cada item do JSON vira uma Mission (usa o fromJson da Parte 1)
    return data
        .map((item) => Mission.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // #f completeMission — PUT /missions/complete?missionId=...
  // #r void; a API responde 200 (concluída), 404 (não encontrada) ou 409 (já concluída)
  Future<void> completeMission(String missionId) async {
    final uri = Uri.parse('$baseUrl/missions/complete')
        .replace(queryParameters: {'missionId': missionId});
    final response = await http.put(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao concluir missão (${response.statusCode}): ${response.body}');
    }
  }
  }
}
