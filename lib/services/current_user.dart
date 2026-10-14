import '../models/user_profile.dart';

// #$ CurrentUser — guarda em memória o UserProfile de quem está logado.
// Preenchido pelo AuthGate assim que a sessão do Supabase é confirmada,
// e limpo no logout. As telas leem CurrentUser.profile em vez de
// MockData.user assim que existe um usuário autenticado.
class CurrentUser {
  CurrentUser._();

  static UserProfile? profile;

  static void clear() {
    profile = null;
  }
}
