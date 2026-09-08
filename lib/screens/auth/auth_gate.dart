import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/current_user.dart';
import '../../theme/app_colors.dart';
import '../root_shell.dart';
import 'login_screen.dart';

// #$ AuthGate — escuta o estado de autenticação do Supabase. Sem sessão,
// mostra o Login; com sessão, carrega o perfil (uma vez) e mostra o
// RootShell (Dashboard). Ponto de entrada usado no main.dart no lugar do
// RootShell direto.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _loadedForUserId;
  bool _loading = false;

  Future<void> _loadProfileIfNeeded(String userId) async {
    if (_loadedForUserId == userId || _loading) return;
    _loading = true;
    final profile = await AuthService.instance.fetchProfile(userId);
    if (!mounted) return;
    setState(() {
      CurrentUser.profile = profile;
      _loadedForUserId = userId;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        final session = AuthService.instance.currentSession;

        if (session == null) {
          CurrentUser.clear();
          _loadedForUserId = null;
          return const LoginScreen();
        }

        if (CurrentUser.profile == null || _loadedForUserId != session.user.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileIfNeeded(session.user.id));
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          );
        }

        return const RootShell();
      },
    );
  }
}
