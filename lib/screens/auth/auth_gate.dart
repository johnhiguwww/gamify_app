import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/current_user.dart';
import '../../services/gamify_api_service.dart';
import '../../theme/app_colors.dart';
import '../root_shell.dart';
import 'login_screen.dart';

// #$ AuthGate — escuta o estado de autenticação do Supabase (login via
// Google). Sem sessão, mostra o Login. Com sessão, busca o perfil na API
// Java pelo UUID do usuário; se ainda não existir (primeiro login), cria
// ele automaticamente usando nome/email/avatar que o Google devolveu.
// #!! Se a API Java ainda não estiver no ar, cai num perfil temporário só
// com os dados do Google, pra você já ver o Dashboard funcionando — assim
// que a API estiver publicada, esse fallback deixa de ser usado sozinho.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _loadedForUserId;
  bool _loading = false;

  UserProfile _fallbackProfile(User user) {
    final name = (user.userMetadata?['full_name'] as String?) ??
        (user.userMetadata?['name'] as String?) ??
        (user.email ?? 'Jogador');
    final avatarUrl = (user.userMetadata?['avatar_url'] as String?) ?? '';
    return UserProfile(
      name: name,
      rank: 'Iniciante',
      globalLevel: 1,
      currentXp: 0,
      maxXp: 100,
      gold: 0,
      avatarUrl: avatarUrl,
    );
  }

  Future<void> _loadOrCreateProfile(User user) async {
    if (_loadedForUserId == user.id || _loading) return;
    _loading = true;
    try {
      final api = GamifyApiService.instance;
      var profile = await api.fetchProfile(user.id);
      profile ??= await api.createOrGetProfile(
        userId: user.id,
        email: user.email ?? '',
        name: (user.userMetadata?['full_name'] as String?) ??
            (user.userMetadata?['name'] as String?) ??
            (user.email ?? 'Jogador'),
        avatarUrl: (user.userMetadata?['avatar_url'] as String?) ?? '',
      );
      if (!mounted) return;
      setState(() {
        CurrentUser.profile = profile;
        CurrentUser.userId = user.id;
        _loadedForUserId = user.id;
        _loading = false;
      });
    } catch (e) {
      // #!! API Java indisponível (ainda não hospedada, ou fora do ar) —
      // segue com um perfil temporário em vez de travar o app.
      if (!mounted) return;
      setState(() {
        CurrentUser.profile = _fallbackProfile(user);
        CurrentUser.userId = user.id;
        _loadedForUserId = user.id;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        final user = AuthService.instance.currentUser;

        if (user == null) {
          CurrentUser.clear();
          _loadedForUserId = null;
          return const LoginScreen();
        }

        if (CurrentUser.profile == null || _loadedForUserId != user.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrCreateProfile(user));
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
