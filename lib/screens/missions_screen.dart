import 'package:flutter/material.dart';
import '../models/api_mission.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import 'new_mission_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  List<ApiMission> _missions = [];
  bool _loading = true;
  // #v aba de filtro: false = em andamento, true = concluídas
  bool _showCompleted = false;

  List<ApiMission> get _filtered =>
      _missions.where((m) => m.finished == _showCompleted).toList();

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final userId = CurrentUser.userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final missions = await GamifyApiService.instance.fetchMissions(userId);
      if (mounted) setState(() { _missions = missions; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.track_changes_rounded, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text('Missões', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2),
                  ),
                if (!_loading)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                    onPressed: () { setState(() => _loading = true); _loadMissions(); },
                    tooltip: 'Atualizar',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StatusTabs(showCompleted: _showCompleted, onChanged: (v) => setState(() => _showCompleted = v)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Row(
                        children: [
                          Text(
                            _showCompleted ? 'Missões Concluídas' : 'Missões em Andamento',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                            child: Text('${_filtered.length}', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              _showCompleted
                                  ? 'Nenhuma missão concluída ainda.'
                                  : 'Nenhuma missão ativa.\nCrie uma clicando abaixo!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              children: [
                                for (var i = 0; i < _filtered.length; i++) ...[
                                  _MissionListTile(mission: _filtered[i]),
                                  if (i != _filtered.length - 1) const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const NewMissionScreen()))
                              .then((_) { setState(() => _loading = true); _loadMissions(); }),
                          icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                          label: const Text('Nova Missão', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _MissionListTile extends StatelessWidget {
  final ApiMission mission;
  const _MissionListTile({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (mission.finished ? AppColors.primaryGreen : AppColors.danger).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.finished ? Icons.check_circle_rounded : Icons.track_changes_rounded,
              color: mission.finished ? AppColors.primaryGreen : AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    color: mission.finished ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    decoration: mission.finished ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Text('+${mission.experience} XP',
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.monetization_on, color: AppColors.gold, size: 13),
                  const SizedBox(width: 3),
                  Text('${mission.reward}', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                ]),
              ],
            ),
          ),
          if (mission.finished)
            const Icon(Icons.verified, color: AppColors.primaryGreen, size: 22),
        ],
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  final bool showCompleted;
  final ValueChanged<bool> onChanged;
  const _StatusTabs({required this.showCompleted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _tab('Em Andamento', selected: !showCompleted, onTap: () => onChanged(false)),
          _tab('Concluídas', selected: showCompleted, onTap: () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _tab(String label, {required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: selected ? Border.all(color: AppColors.border) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primaryGreen : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
