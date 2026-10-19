import 'package:shared_preferences/shared_preferences.dart';
import '../data/store_icons.dart';
import '../models/store_item.dart';

// #$ StoreIconStorage — guarda no navegador qual ícone cada item da loja usa.
// ## mapa "id do item -> chave do ícone", salvo com shared_preferences
// (localStorage na web). Não vai para a API e não acompanha o usuário
// em outro navegador ou aparelho.
class StoreIconStorage {
  StoreIconStorage._();

  // #v prefixo das chaves salvas
  static const String _prefix = 'store_icon_';

  // #f applyIcons — põe o ícone salvo em cada item
  // #p items: itens que vieram da API
  // #r os mesmos itens, com o ícone escolhido (ou o padrão)
  static Future<List<StoreItem>> applyIcons(List<StoreItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return [
        for (final item in items) _apply(item, prefs.getString('$_prefix${item.id}')),
      ];
    } catch (_) {
      // ## se o armazenamento falhar, mostra os itens com o ícone padrão
      return items;
    }
  }

  // #f _apply — aplica uma chave de ícone a um item
  static StoreItem _apply(StoreItem item, String? key) {
    // #if sem ícone salvo: mantém o padrão
    if (key == null) return item;
    final option = storeIconByKey(key);
    return item.copyWith(icon: option.icon, iconColor: option.color, iconKey: option.key);
  }

  // #f save — salva o ícone escolhido para um item
  static Future<void> save(String itemId, String iconKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$itemId', iconKey);
    } catch (_) {
      // ## falhar ao salvar o ícone não pode atrapalhar o item
    }
  }

  // #f remove — apaga o ícone salvo (quando o item é apagado)
  static Future<void> remove(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$itemId');
    } catch (_) {}
  }
}