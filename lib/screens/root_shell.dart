import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';
import 'store_screen.dart';
import 'tasks_screen.dart';

// #$ RootShell — mantém o estado de cada aba vivo com IndexedStack
// (evita recriar a tela toda vez que o usuário troca de aba).
// ## exceção: Início, Missões e Tarefas são recriadas ao entrar na aba,
// para buscar os dados da API de novo (senão ficam desatualizadas).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  // #v aba atual
  int _index = 0;

  // #v contador por aba (0 = Início, 1 = Missões, 2 = Tarefas)
  // ## quando o número muda, a ValueKey muda e o Flutter recria a tela
  final List<int> _versions = [0, 0, 0];

  // #f _goTo — troca de aba
  // #p i: índice da aba de destino
  void _goTo(int i) {
    setState(() {
      // #if mudou de aba e a aba é uma das 3 que precisam recarregar
      if (i != _index && i < _versions.length) {
        _versions[i]++;
      }
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ## a key com a versão força a recriação só quando o contador muda
    final screens = [
      DashboardScreen(
        key: ValueKey('dashboard-${_versions[0]}'),
        onSeeAllMissions: () => _goTo(1),
        onSeeAllTasks: () => _goTo(2),
      ),
      MissionsScreen(key: ValueKey('missions-${_versions[1]}')),
      TasksScreen(key: ValueKey('tasks-${_versions[2]}')),
      const StoreScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _goTo),
    );
  }
}