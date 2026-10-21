import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../theme/app_colors.dart';
import '../widgets/gamify_progress_bar.dart';
<<<<<<< Updated upstream
=======
import '../widgets/rank_badge.dart';
import '../widgets/user_avatar.dart';
>>>>>>> Stashed changes

// #!! placeholder — não veio nos prints; só evita uma aba vazia no bottom nav.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
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
=======
    // ## redesenha quando o perfil muda (nome ou foto novos)
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: CurrentUser.notifier,
      builder: (context, profile, _) {
        final user = profile ?? MockData.user;
        // #v true quando o texto do campo é diferente do nome salvo
        final bool nameChanged = _nameCtrl.text.trim() != user.name;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              // ## foto: toque para trocar
              Center(
                child: GestureDetector(
                  onTap: _busy ? null : () => _changePhoto(user),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      UserAvatar(name: user.name, avatarUrl: user.avatarUrl, radius: 48),
                      // ## indicador de envio por cima da foto
                      if (_busy)
                        const SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: AppColors.primaryGreen),
                        ),
                      // ## ícone de câmera no canto
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen,
                            border: Border.all(color: AppColors.surfaceAlt, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Toque na foto para trocar',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
              const SizedBox(height: 14),
              // ## selo da patente centralizado (mesmo do dashboard)
              Center(
                child: RankBadge(
                  rank: user.rank,
                  level: user.globalLevel,
                  xpToNext: user.xpToNextLevel,
                  center: true,
                ),
              ),
              const SizedBox(height: 20),

              // ## campo para editar o nome + botão Salvar
              TextField(
                controller: _nameCtrl,
                enabled: !_busy,
                maxLength: _maxNameLength,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onSubmitted: (_) {
                  if (nameChanged) _saveName(user);
                },
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                // #if sem mudança ou ocupado: botão desabilitado
                onPressed: (_busy || !nameChanged) ? null : () => _saveName(user),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar nome'),
              ),
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
>>>>>>> Stashed changes
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
