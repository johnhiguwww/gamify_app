import 'package:flutter/material.dart';

// #$ StoreIconOption — um ícone que o usuário pode escolher para um item da loja
class StoreIconOption {
  // #v chave estável salva no navegador (nunca mude depois de publicar)
  final String key;
  // #v nome mostrado no tooltip
  final String label;
  final IconData icon;
  final Color color;

  const StoreIconOption(this.key, this.label, this.icon, this.color);
}

// #v lista de ícones disponíveis; o primeiro é o padrão
// ## a API NÃO guarda ícone: isto vive só no app
const List<StoreIconOption> storeIconOptions = [
  StoreIconOption('gift', 'Presente', Icons.card_giftcard, Color(0xFF22C55E)),
  StoreIconOption('cake', 'Doce', Icons.cake, Color(0xFFEC4899)),
  StoreIconOption('icecream', 'Sorvete', Icons.icecream, Color(0xFFF472B6)),
  StoreIconOption('coffee', 'Café', Icons.coffee, Color(0xFFB45309)),
  StoreIconOption('pizza', 'Pizza', Icons.local_pizza, Color(0xFFEF4444)),
  StoreIconOption('restaurant', 'Restaurante', Icons.restaurant, Color(0xFFF97316)),
  StoreIconOption('book', 'Livro', Icons.menu_book, Color(0xFF3B82F6)),
  StoreIconOption('game', 'Jogo', Icons.sports_esports, Color(0xFFA855F7)),
  StoreIconOption('movie', 'Filme', Icons.movie, Color(0xFFEF4444)),
  StoreIconOption('music', 'Música', Icons.music_note, Color(0xFFEC4899)),
  StoreIconOption('headphones', 'Fone', Icons.headphones, Color(0xFF06B6D4)),
  StoreIconOption('beach', 'Praia', Icons.beach_access, Color(0xFFFBBF24)),
  StoreIconOption('flight', 'Viagem', Icons.flight, Color(0xFF3B82F6)),
  StoreIconOption('bike', 'Passeio', Icons.directions_bike, Color(0xFF22C55E)),
  StoreIconOption('shopping', 'Compras', Icons.shopping_bag, Color(0xFFF59E0B)),
  StoreIconOption('spa', 'Descanso', Icons.spa, Color(0xFF14B8A6)),
  StoreIconOption('party', 'Festa', Icons.celebration, Color(0xFFFBBF24)),
  StoreIconOption('pets', 'Pet', Icons.pets, Color(0xFFA16207)),
];

// #f storeIconByKey — acha o ícone pela chave
// #p key: chave salva (pode ser null)
// #r o ícone; se a chave for nula ou desconhecida, devolve o padrão
StoreIconOption storeIconByKey(String? key) {
  // #if achou a chave: devolve o ícone correspondente
  for (final o in storeIconOptions) {
    if (o.key == key) return o;
  }
  // #else não achou: ícone padrão
  return storeIconOptions.first;
}