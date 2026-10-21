import 'package:shared_preferences/shared_preferences.dart';
import '../data/task_icons.dart';
import '../models/attribute.dart';
import '../models/task.dart';

// #$ TaskIconStorage — guarda no navegador o ícone e o atributo de cada tarefa.
// ## dois mapas salvos com shared_preferences (localStorage na web):
//    "task_icon_<id>" -> chave do ícone (TaskIconOption.key)
//    "task_attr_<id>" -> nome do atributo (AttributeType.name)
// #!! nada disso vai para a API: não acompanha o usuário em outro navegador
// ou aparelho. O atributo é guardado porque o GET de tarefas NÃO devolve o
// atributo; assim a edição já abre com ele escolhido (só para tarefas
// criadas/editadas depois desta versão).
class TaskIconStorage {
  TaskIconStorage._();

  // #v prefixo das chaves de ícone
  static const String _iconPrefix = 'task_icon_';
  // #v prefixo das chaves de atributo
  static const String _attrPrefix = 'task_attr_';

  // #f applyIcons — põe o ícone (e o atributo) salvo em cada tarefa
  // #p tasks: tarefas que vieram da API
  // #r as mesmas tarefas, com o ícone escolhido (ou o padrão)
  static Future<List<GamifyTask>> applyIcons(List<GamifyTask> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return [
        for (final t in tasks)
          _apply(t, prefs.getString('$_iconPrefix${t.id}'), prefs.getString('$_attrPrefix${t.id}')),
      ];
    } catch (_) {
      // ## se o armazenamento falhar, mostra as tarefas com o ícone padrão
      return tasks;
    }
  }

  // #f _apply — aplica a chave de ícone e o atributo salvos a uma tarefa
  // #p task: tarefa da API
  // #p iconKey: chave do ícone salva (ou null)
  // #p attrName: nome do atributo salvo (ou null)
  // #r tarefa com ícone/cor/atributo aplicados
  static GamifyTask _apply(GamifyTask task, String? iconKey, String? attrName) {
    // #v atributo salvo convertido de volta para o enum (null se não houver)
    final attribute = _attributeFromName(attrName);
    // #if sem ícone e sem atributo salvos: mantém o padrão
    if (iconKey == null && attribute == null) return task;
    // #if só não tem ícone: mantém o ícone padrão, mas guarda o atributo
    if (iconKey == null) return task.copyWith(attribute: attribute);
    // #else tem ícone: aplica ícone, cor e chave (e o atributo, se houver)
    final option = taskIconByKey(iconKey);
    return task.copyWith(
      icon: option.icon,
      iconColor: option.color,
      iconKey: option.key,
      attribute: attribute,
    );
  }

  // #f _attributeFromName — texto salvo -> AttributeType
  // #p name: AttributeType.name salvo (ex.: "inteligencia")
  // #r o atributo, ou null se vazio/desconhecido
  static AttributeType? _attributeFromName(String? name) {
    // #if nada salvo
    if (name == null) return null;
    // #wh (for) procura o atributo com esse nome
    for (final a in AttributeType.values) {
      if (a.name == name) return a;
    }
    // ## nome desconhecido (ex.: versão antiga): ignora
    return null;
  }

  // #f save — salva o ícone e o atributo escolhidos para uma tarefa
  // #p taskId: id da tarefa (vindo da API)
  // #p iconKey: chave do ícone escolhido
  // #p attribute: atributo escolhido no formulário
  static Future<void> save(String taskId, String iconKey, AttributeType? attribute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_iconPrefix$taskId', iconKey);
      // #if veio atributo: guarda; senão apaga o antigo
      if (attribute != null) {
        await prefs.setString('$_attrPrefix$taskId', attribute.name);
      } else {
        await prefs.remove('$_attrPrefix$taskId');
      }
    } catch (_) {
      // ## falhar ao salvar o ícone não pode atrapalhar a tarefa
    }
  }

  // #f remove — apaga ícone e atributo salvos (quando a tarefa é excluída)
  // #p taskId: id da tarefa
  static Future<void> remove(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_iconPrefix$taskId');
      await prefs.remove('$_attrPrefix$taskId');
    } catch (_) {
      // ## falhar aqui só deixa uma chave sobrando no navegador
    }
  }
}
