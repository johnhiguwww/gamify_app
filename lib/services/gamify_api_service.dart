import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/mission.dart';
import '../models/task.dart';
import '../models/store_item.dart';
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
      // ## falhar ao atualizar o cabeçalho não pode atrapalhar a operação
    }
  }

  // #f updateProfile — PUT /profiles/update/{uuid}, corpo {name, avatarUrl}
  // #!! a API SEMPRE grava os dois campos juntos e valida: name não pode ser
  // vazio e avatarUrl não pode ser vazio e precisa ser uma URL válida (400).
  // Para mudar só um dos dois, reenvie o valor atual do outro.
  // ## a API responde 200 com corpo vazio; por isso recarregamos o perfil
  // depois, e o CurrentUser avisa as telas (dashboard e perfil)
  // #p userId: id do usuário (igual ao id do perfil)
  // #p name: nome novo (ou o atual)
  // #p avatarUrl: link da foto nova (ou o atual)
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String avatarUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/update/$userId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'avatarUrl': avatarUrl}),
    );
    // #if 404: o perfil não existe na API
    if (response.statusCode == 404) {
      throw Exception('Perfil não encontrado na API.');
    }
    // #if outro status: mostra código e corpo (utf8 para manter os acentos)
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao atualizar perfil (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    // ## recarrega o perfil para a tela mostrar o novo nome e a nova foto
    final profile = await fetchProfile(userId);
    if (profile == null) {
      throw Exception('Perfil salvo, mas não foi possível recarregar.');
    }
    CurrentUser.profile = profile;
  }

  // #f createOrGetProfile — POST /profiles/new (chamado após o login)
  // #!! essa rota NÃO existe no ProfileController do Java (conferido);
  // hoje essa chamada deve falhar e o AuthGate cai no perfil temporário
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

  // ===================== LOJA =====================

  // #f fetchStore — GET /profiles/{uuid}/mystore (StoreOutputDTO)
  // #p userId: id do usuário (igual ao id do perfil)
  // #r lista de itens; null se a API respondeu 404 (perfil ou loja inexistente)
  Future<List<StoreItem>?> fetchStore(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/mystore');
    final response = await http.get(uri);
    // #if 404: perfil ou loja não existem
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar loja (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>?) ?? [];
    return [for (final e in items) StoreItem.fromJson(e as Map<String, dynamic>)];
  }

  // #f addStoreItem — POST /profiles/{uuid}/addItem, corpo {name, value}
  // #r void; a API responde 201 (404 se faltar perfil ou loja)
  Future<void> addStoreItem({
    required String userId,
    required String name,
    required int value,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/addItem');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'value': value}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao adicionar item (${response.statusCode}): ${response.body}');
    }
  }

  // #f updateStoreItem — PUT /profiles/{profileId}/updateItem/{itemId}
  // #r void; a API responde 200 (403 se o item não é do perfil)
  Future<void> updateStoreItem({
    required String userId,
    required String itemId,
    required String name,
    required int value,
  }) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/updateItem/$itemId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'value': value}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao editar item (${response.statusCode}): ${response.body}');
    }
  }

  // #f deleteStoreItem — DELETE /profiles/{profileId}/deleteItem/{itemId}
  // #r void; a API responde 204 (409 se o item já foi comprado)
  Future<void> deleteStoreItem({required String userId, required String itemId}) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/deleteItem/$itemId');
    final response = await http.delete(uri);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao apagar item (${response.statusCode}): ${response.body}');
    }
  }

  // #f purchaseStoreItem — PUT /profiles/{profileId}/purchaseItem/{itemId}
  // #!! a API devolve só o item (não o perfil): recarregamos o perfil depois
  // para o ouro do cabeçalho atualizar. 409 = ouro insuficiente.
  Future<void> purchaseStoreItem({required String userId, required String itemId}) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/purchaseItem/$itemId');
    final response = await http.put(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao comprar item (${response.statusCode}): ${response.body}');
    }
    await _refreshCurrentProfile();
  }
}