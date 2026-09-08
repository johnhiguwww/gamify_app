import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

// #$ AuthService — encapsula as chamadas de autenticação do Supabase.
// #!! Depende da tabela `profiles` existir no seu projeto Supabase — veja o
// SQL sugerido em supabase_schema.sql.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;

  // #f signUp — cria o usuário no Supabase Auth e, em seguida, a linha
  // correspondente na tabela `profiles` com os dados de gamificação
  // inicial (nível 1, XP zerado, 0 de ouro).
  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
    String avatarUrl = '',
  }) async {
    final response = await _client.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('Não foi possível criar o usuário.');
    }

    await _client.from('profiles').insert({
      'id': user.id,
      'name': nickname.isNotEmpty ? nickname : name,
      'full_name': name,
      'avatar_url': avatarUrl,
      'rank': 'Iniciante',
      'global_level': 1,
      'current_xp': 0,
      'max_xp': 100,
      'gold': 0,
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // #f fetchProfile — busca a linha de `profiles` do usuário logado e
  // converte pro UserProfile já usado pelo Dashboard e pela tela de Perfil.
  Future<UserProfile?> fetchProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }
}
