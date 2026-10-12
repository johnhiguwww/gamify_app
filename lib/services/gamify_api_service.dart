import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

// #$ GamifyApiService — encapsula as chamadas HTTP pra sua API Java
// (Spring Boot). #!! troque baseUrl pela URL onde a API estiver hospedada
// (ex: https://gamify-api.onrender.com). Enquanto estiver testando local,
// use http://localhost:8080 — mas lembre que isso só funciona se o Flutter
// também estiver rodando local (Chrome), nunca a partir do site publicado.
class GamifyApiService {
  GamifyApiService._();
  static final GamifyApiService instance = GamifyApiService._();

  //# CloudFire - API conectada com o Flutter
  static const String baseUrl = 'https://jelsoft-benefit-season-solomon.trycloudflare.com';

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
  Future<void> createTask({
    required String profileUuid,
    required String title,
    required String description,
    required int reward,
    required int experience,
    required String frequency,
    String? scheduledTime,
    List<String>? daysOfWeek,
    bool partOfMission = false,
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
        'frequency': frequency,
        if (scheduledTime != null) 'scheduledTime': scheduledTime,
        if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
        'partOfMission': partOfMission,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao criar tarefa (${response.statusCode}): ${response.body}');
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
    if (response.statusCode != 200) {
      throw Exception('Erro ao criar missão (${response.statusCode}): ${response.body}');
    }
  }
}
