import 'package:flutter/material.dart';
import 'screens/auth/auth_gate.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const GamifyApp());
}

class GamifyApp extends StatelessWidget {
  const GamifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      // #!! largura máxima pra manter o layout mobile centralizado quando
      // rodando no navegador (Web) em telas largas de desktop.
      builder: (context, child) {
        return Container(
          color: const Color(0xFF05070B),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      home: const AuthGate(),
    );
  }
}
