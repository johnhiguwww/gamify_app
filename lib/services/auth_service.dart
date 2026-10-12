import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

// #$ AuthService — encapsula a autenticação do Supabase. O login é feito
// só via Google (OAuth); não existe mais signUp/signIn com email e senha,
// nem tabela `profiles` no Supabase — o perfil de jogo mora na API Java.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  // #f signInWithGoogle — abre o fluxo OAuth do Google. Na Web, isso
  // redireciona a própria aba pro Google e volta pro redirectTo informado
  // (deixamos null para usar o Site URL configurado no painel do Supabase).
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: null,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
