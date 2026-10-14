import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/mission.dart';
import '../theme/app_colors.dart';
import '../widgets/mission_card.dart';
import 'new_mission_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  MissionStatus _tab = MissionStatus.ativa;

  List<Mission> get _filtered => MockData.missions.where((m) => m.status == _tab).toList();

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
                const Icon(Icons.help_outline, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StatusTabs(current: _tab, onChanged: (s) => setState(() => _tab = s)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Row(
                  children: [
                    Text('Missões ${_tab == MissionStatus.ativa ? 'Ativas' : _tab == MissionStatus.pendente ? 'Pendentes' : 'Concluídas'}',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Nenhuma missão por aqui ainda.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          for (var i = 0; i < _filtered.length; i++) ...[
                            MissionCard(mission: _filtered[i], detailed: true),
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
                        .push(MaterialPageRoute(builder: (_) => const NewMissionScreen())),
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

class _StatusTabs extends StatelessWidget {
  final MissionStatus current;
  final ValueChanged<MissionStatus> onChanged;
  const _StatusTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (status: MissionStatus.ativa, label: 'Ativas'),
      (status: MissionStatus.pendente, label: 'Pendentes'),
      (status: MissionStatus.concluida, label: 'Concluídas'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final t in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t.status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == t.status ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: current == t.status ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      color: current == t.status ? AppColors.primaryGreen : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
