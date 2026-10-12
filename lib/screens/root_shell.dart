import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';
import 'store_screen.dart';
import 'tasks_screen.dart';

// #$ RootShell — mantém o estado de cada aba vivo com IndexedStack
// (evita recriar a tela toda vez que o usuário troca de aba).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onSeeAllMissions: () => _goTo(1), onSeeAllTasks: () => _goTo(2)),
      const MissionsScreen(),
      const TasksScreen(),
      const StoreScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _goTo),
    );
  }
}
