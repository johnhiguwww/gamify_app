import '../models/user_profile.dart';

// #$ CurrentUser — guarda em memória o UserProfile de quem está logado.
// Preenchido pelo AuthGate assim que a sessão do Supabase é confirmada,
// e limpo no logout. As telas leem CurrentUser.profile em vez de
// MockData.user assim que existe um usuário autenticado.
class CurrentUser {
  CurrentUser._();

  static UserProfile? profile;

  // #v userId — UUID do usuário Supabase, armazenado separadamente do
  // UserProfile para que as telas possam chamar a API sem re-importar
  // o SupabaseClient.
  static String? userId;

  static void clear() {
    profile = null;
    userId = null;
  }
}
