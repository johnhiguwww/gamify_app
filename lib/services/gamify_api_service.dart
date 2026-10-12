import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_mission.dart';
import '../models/api_task.dart';
import '../models/store_item.dart';
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
  static const String baseUrl = 'https://simulation-democracy-attempt-karma.trycloudflare.com';

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

  // #f fetchTasks — lista as tarefas do perfil logado, retornando lista
  // tipada de ApiTask (espelho do TasksDTO da API Java).
  Future<List<ApiTask>> fetchTasks(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_tasks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar tarefas (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ApiTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  // #f fetchMissions — lista as missões do perfil logado, retornando lista
  // tipada de ApiMission (espelho do MissionOutPutDTO da API Java).
  // Endpoint: GET /profiles/{uuid}/my_missions
  Future<List<ApiMission>> fetchMissions(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_missions');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar missões (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ApiMission.fromJson(e as Map<String, dynamic>)).toList();
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
    required String attributes,
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
        'attributes': attributes,
        if (scheduledTime != null) 'scheduledTime': scheduledTime,
        if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
        'partOfMission': partOfMission,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
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
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar missão (${response.statusCode}): ${response.body}');
    }
  }

  // #f fetchStoreItems — busca a loja do usuário e devolve a lista de itens.
  // Endpoint: GET /profiles/{uuid}/mystore
  Future<List<StoreItem>> fetchStoreItems(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/mystore');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar loja (${response.statusCode}): ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return itemsList.map((e) => StoreItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // #f addStoreItem — adiciona um novo item à loja do perfil.
  // Endpoint: POST /profiles/{uuid}/addItem
  Future<StoreItem> addStoreItem({
    required String userId,
    required String name,
    required int value,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/addItem');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'value': value,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar item à loja (${response.statusCode}): ${response.body}');
    }
    return StoreItem.fromJson(jsonDecode(response.body));
  }

  // #f deleteStoreItem — remove um item da loja.
  // Endpoint: DELETE /profiles/{profileId}/deleteItem/{itemId}
  Future<void> deleteStoreItem({
    required String userId,
    required String itemId,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/deleteItem/$itemId');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover item da loja (${response.statusCode}): ${response.body}');
    }
  }

  // #f purchaseStoreItem — compra um item da loja usando o ouro do perfil.
  // Endpoint: PUT /profiles/{profileId}/purchaseItem/{itemId}
  Future<StoreItem> purchaseStoreItem({
    required String userId,
    required String itemId,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/purchaseItem/$itemId');
    final response = await http.put(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao comprar item (${response.statusCode}): ${response.body}');
    }
    return StoreItem.fromJson(jsonDecode(response.body));
  }
}
