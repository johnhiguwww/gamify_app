import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../theme/app_colors.dart';
import '../widgets/gamify_progress_bar.dart';

// #!! placeholder — não veio nos prints; só evita uma aba vazia no bottom nav.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.profile ?? MockData.user;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surfaceAlt,
              child: Text(user.name.substring(0, 1), style: const TextStyle(fontSize: 30, color: AppColors.primaryGreen)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700))),
          Center(child: Text(user.rank, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 13))),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nível Global ${user.globalLevel}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                      Text('${user.currentXp}/${user.maxXp} XP', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GamifyProgressBar(ratio: user.ratio),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout, color: AppColors.danger, size: 18),
            label: const Text('Sair', style: TextStyle(color: AppColors.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
