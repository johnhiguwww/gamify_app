import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_mission.dart';
import '../models/api_task.dart';
import '../models/store_item.dart';
<<<<<<< Updated upstream
import '../models/user_profile.dart';
=======
import 'auth_service.dart';
import 'current_user.dart';
import 'task_icon_storage.dart';
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
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
=======
  // #f createTask — POST /tasks/newtask (TasksInputDTO)
  // frequency: UNIQUE, DAILY, WEEKLY ou MONTHLY; attributes: snake_case
  // #p partOfMission: true quando a tarefa será vinculada a uma missão
  // #!!! na Nova Missão NÃO esquecer o partOfMission: true
  // #r id (UUID em texto) da tarefa criada, lido do TasksOutPutDTO
  Future<String> createTask({
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar tarefa (${response.statusCode}): ${response.body}');
    }
  }

  // #f createMission — cria uma missão nova pro usuário informado,
  // chamado pela tela "Nova Missão".
=======
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Erro ao criar tarefa (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    // ## o TasksOutPutDTO traz o campo "id" (UUID)
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final id = data['id'];
    // #if a API não devolveu o id: não dá para vincular a missão
    if (id == null) {
      throw Exception('A API criou a tarefa mas não devolveu o id.');
    }
    return id.toString();
  }

  // #f updateTask — PUT /tasks/update?taskId={id}, corpo TasksInputDTO
  // #!! a API devolve o TasksOutPutDTO (200); 404 se a tarefa não existe;
  // 400 se os dados forem inválidos (ex.: expirationDate no passado)
  // #p taskId: id da tarefa a editar (vai na query, não no corpo)
  Future<void> updateTask({
    required String taskId,
    required String profileUuid,
    required String title,
    required String description,
    required int reward,
    required int experience,
    required String attributes,
    required String frequency,
    List<String>? daysOfWeek,
    bool partOfMission = false,
  }) async {
    final uri = Uri.parse('$baseUrl/tasks/update').replace(queryParameters: {'taskId': taskId});
    final response = await http.put(
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
        'partOfMission': partOfMission,
      }),
    );
    // #if 404: tarefa não encontrada
    if (response.statusCode == 404) {
      throw Exception('Tarefa não encontrada na API.');
    }
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao editar tarefa (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
  }

  // #f fetchTasks — GET /profiles/{uuid}/my_tasks (lista de TasksDTO)
  // #r tarefas com o ícone/atributo do navegador já aplicados
  Future<List<GamifyTask>> fetchTasks(String userId) async {
    final uri = Uri.parse('$baseUrl/profiles/$userId/my_tasks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao listar tarefas (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    // #v tarefas como vieram da API (ícone padrão, sem atributo)
    final tasks = [for (final e in list) GamifyTask.fromJson(e as Map<String, dynamic>)];
    // ## aplica o ícone e o atributo guardados no navegador (TaskIconStorage)
    return TaskIconStorage.applyIcons(tasks);
  }

  // #f deleteTask — DELETE /tasks/delete?taskId={id}
  // ## confirmado no TaskController/TaskService: 200 sem corpo; 404 se não
  // existe; 400 se a tarefa já estiver ENCERRADA (finished) — a API não deixa
  // apagar tarefa concluída de vez
  // #!! a API não verifica missão: apagar uma tarefa vinculada a uma missão
  // deve falhar no banco (chave estrangeira) e voltar erro 500 (NÃO testado)
  // ## depois de apagar, remove o ícone/atributo guardados no navegador
  // #p taskId: id da tarefa
  Future<void> deleteTask(String taskId) async {
    final uri = Uri.parse('$baseUrl/tasks/delete').replace(queryParameters: {'taskId': taskId});
    final response = await http.delete(uri);
    // #if 404: a tarefa já não existe
    if (response.statusCode == 404) {
      throw Exception('Tarefa não encontrada na API.');
    }
    // #elseif 400: tarefa encerrada não pode ser apagada
    if (response.statusCode == 400) {
      throw Exception('Tarefa já concluída não pode ser excluída.');
    }
    // #elseif 500: o mais provável é a tarefa estar vinculada a uma missão
    if (response.statusCode == 500) {
      throw Exception('A API recusou (500). Talvez a tarefa esteja vinculada a uma missão.');
    }
    // #elseif qualquer outro erro
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Erro ao excluir tarefa (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    await TaskIconStorage.remove(taskId);
  }

  // #f completeTask — POST /tasks/complete (corpo {"taskId"})
  // #!! a API marca a tarefa como finished para sempre; uma segunda chamada
  // na mesma tarefa dá 400 ("já concluída"). Por isso o app só usa esta rota
  // para tarefas ÚNICAS (ver concludeTask).
  // ## soma reward no ouro e experience no ATRIBUTO da tarefa
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

  // #f completeTaskCycle — PUT /tasks/complete-cycle?taskId={id}
  // ## conclui UM ciclo de tarefa recorrente: a API soma reward no ouro e
  // experience no atributo, grava lastCompletedAt e NÃO encerra a tarefa
  // #!! a API não limita repetições (dá para chamar sem parar); quem trava
  // por 24 h / 7 dias / 30 dias é o APP (GamifyTask.isDone). Citar no TCC.
  // #!! 400 se a tarefa já estiver encerrada (finished); 404 se não existe
  // ## a resposta é a tarefa (TaskOutPutDTO), não o perfil: recarregamos o
  // perfil depois para o cabeçalho (ouro) atualizar
  // #p taskId: id da tarefa
  Future<void> completeTaskCycle(String taskId) async {
    final uri = Uri.parse('$baseUrl/tasks/complete-cycle').replace(queryParameters: {'taskId': taskId});
    final response = await http.put(uri);
    // #if status diferente de 200: mostra código e corpo
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao concluir tarefa (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }
    await _refreshCurrentProfile();
  }

  // #f concludeTask — escolhe a rota certa de conclusão pela frequência
  // ## Única -> POST /tasks/complete (encerra de vez)
  // ## Diária/Semanal/Mensal -> PUT /tasks/complete-cycle (renova depois)
  // #!! a tela deve checar task.isDone ANTES de chamar (trava do período)
  // #p task: tarefa tocada na tela
  Future<void> concludeTask(GamifyTask task) async {
    // #if recorrente: conclui só o ciclo atual
    if (task.isRecurring) {
      await completeTaskCycle(task.id);
    } else {
      // #else única: encerra para sempre
      await completeTask(task.id);
    }
  }

  // #f createMission — POST /missions/new
  // #p taskId: id da tarefa vinculada (opcional; a API guarda UMA tarefa só)
  // #!! se o taskId não existir na API, ela responde 400
>>>>>>> Stashed changes
  Future<void> createMission({
    required String userId,
    required String title,
    required int reward,
    required int experience,
    String? taskId,
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
        // ## sem tarefa vinculada, o campo nem é enviado (Optional vazio no Java)
        if (taskId != null) 'taskId': taskId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erro ao criar missão (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
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
<<<<<<< Updated upstream
=======
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
  // #!! decisão do projeto: a loja não deve apagar itens (ficam como registro);
  // o método existe, mas as telas não devem chamá-lo
  Future<void> deleteStoreItem({required String userId, required String itemId}) async {
>>>>>>> Stashed changes
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
