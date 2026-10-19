import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
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

  final _api = GamifyApiService.instance;
  List<Mission> _missions = [];
  bool _loading = true;
  String? _error;

  // #v id da missão que está sendo concluída (trava cliques repetidos)
  String? _completingId;

  // #f initState — carrega as missões assim que a tela abre
  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  // #f _loadMissions — busca as missões na API e atualiza a tela
  Future<void> _loadMissions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // #t id do usuário logado (mesmo caminho usado na NewMissionScreen)
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('Sessão expirada, faça login novamente.');
      }
      final missions = await _api.fetchMissions(userId);
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // #f _completeMission — PUT /missions/complete/{missionId}
  // ## depois de concluir, recarrega a lista para a missão ir para "Concluídas"
  Future<void> _completeMission(Mission mission) async {
    if (_completingId != null) return;
    setState(() => _completingId = mission.id);
    try {
      await _api.completeMission(mission.id);
      if (!mounted) return;
      await _loadMissions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missão concluída! +${mission.xpReward} XP e +${mission.goldReward} de ouro')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir a missão: $e')),
      );
    } finally {
      if (mounted) setState(() => _completingId = null);
    }
  }

  // ## filtra pela aba selecionada (usa a lista que veio da API)
  List<Mission> get _filtered => _missions.where((m) => m.status == _tab).toList();

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
                const Text('Missões',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
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
                    Text(
                        'Missões ${_tab == MissionStatus.ativa ? 'Ativas' : 'Concluídas'}',
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                      child: Text('${_filtered.length}',
                          style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadMissions,
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  )
                else if (_filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Nenhuma missão por aqui ainda.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          for (var i = 0; i < _filtered.length; i++) ...[
                            MissionCard(
                              mission: _filtered[i],
                              detailed: true,
                              onComplete: () => _completeMission(_filtered[i]),
                              completing: _completingId == _filtered[i].id,
                            ),
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
                    onPressed: () async {
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const NewMissionScreen()));
                      // ## ao voltar da tela de criação, busca a lista de novo
                      _loadMissions();
                    },
                    icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                    label: const Text('Nova Missão',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
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