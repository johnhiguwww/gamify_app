import 'package:flutter/material.dart';

// #$ StoreItem — recompensa real cadastrada pelo próprio usuário.
// ## a API (ItemOutputDTO) só guarda: id, title, value, created_at,
// updated_at e purchase_at. O ícone NÃO vem da API: é escolhido pelo usuário
// e guardado no navegador (StoreIconStorage).
class StoreItem {
  final String id;
  final String title;
  // #v valor em ouro (campo "value" da API)
  final int cost;
  // #v data da compra (null = nunca comprado)
  final DateTime? purchasedAt;
  final DateTime? createdAt;
  // #!! campos abaixo NÃO vêm da API
  final String description;
  final IconData icon;
  final Color iconColor;
  // #v chave do ícone escolhido (null = ícone padrão)
  final String? iconKey;
  final bool active;

  const StoreItem({
    required this.id,
    required this.title,
    required this.cost,
    this.purchasedAt,
    this.createdAt,
    this.description = '',
    this.icon = Icons.card_giftcard,
    this.iconColor = const Color(0xFF22C55E),
    this.iconKey,
    this.active = true,
  });

  // #v true se o item já foi comprado alguma vez
  bool get purchased => purchasedAt != null;

  // #f fromJson — converte o ItemOutputDTO da API em StoreItem
  // #p json: mapa vindo do jsonDecode
  // #r StoreItem pronto para as telas
  // ## chaves confirmadas no Java: id, title, value, created_at, purchase_at
  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      cost: (json['value'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      purchasedAt: DateTime.tryParse((json['purchase_at'] ?? '').toString()),
    );
  }

  // #f copyWith — cópia com ícone ou "ativo" trocados
  StoreItem copyWith({bool? active, IconData? icon, Color? iconColor, String? iconKey}) => StoreItem(
        id: id,
        title: title,
        cost: cost,
        purchasedAt: purchasedAt,
        createdAt: createdAt,
        description: description,
        icon: icon ?? this.icon,
        iconColor: iconColor ?? this.iconColor,
        iconKey: iconKey ?? this.iconKey,
        active: active ?? this.active,
      );
}