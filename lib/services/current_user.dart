import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

// #$ CurrentUser — guarda em memória o UserProfile de quem está logado.
// Preenchido pelo AuthGate assim que a sessão do Supabase é confirmada,
// e limpo no logout.
// ## notifica as telas: quem usa o ValueListenableBuilder redesenha
// sozinho quando o perfil muda (ex: depois de concluir missão ou tarefa).
class CurrentUser {
  CurrentUser._();

  // #v notificador que guarda o perfil
  static final ValueNotifier<UserProfile?> notifier = ValueNotifier<UserProfile?>(null);

  // #f profile — leitura e escrita continuam iguais para o resto do app
  static UserProfile? get profile => notifier.value;
  static set profile(UserProfile? value) => notifier.value = value;

  static void clear() {
    notifier.value = null;
  }
}