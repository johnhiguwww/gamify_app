import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/form_bits.dart';

class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});

  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  final _titleController = TextEditingController();

  // #v recompensa é somente informativa aqui — #t regra de cálculo (baseada
  // em dificuldade/duração) fica a cargo do backend quando integrar.
  final int _xp = 100;
  final int _gold = 20;
  bool _saving = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final userId = CurrentUser.userId;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      await GamifyApiService.instance.createMission(
        userId: userId,
        title: _titleController.text.trim(),
        reward: _gold,
        experience: _xp,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      debugPrint('Erro ao criar missão: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível criar a missão: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // #!! reconstrói ao digitar pra habilitar/desabilitar "Criar Missão" em tempo real.
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Text('Nova Missão', style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            const FormLabel('Título da missão'),
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Ex: Correr 5 km')),
            const SizedBox(height: 16),
            const FormLabel('Recompensas'),
            Row(
              children: [
                Expanded(
                  child: MetricPill(
                    icon: Icons.bolt,
                    iconColor: AppColors.primaryGreen,
                    label: 'XP',
                    value: '$_xp',
                    caption: 'Pontos de Experiência',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricPill(
                    icon: Icons.monetization_on,
                    iconColor: AppColors.gold,
                    label: 'Gold',
                    value: '$_gold',
                    caption: 'Ouro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_titleController.text.trim().isEmpty || _saving) ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                      )
                    : const Text('Criar Missão'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
