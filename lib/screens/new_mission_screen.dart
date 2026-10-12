import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/attribute_selector.dart';
import '../widgets/form_bits.dart';

class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});

  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  AttributeOption? _attribute;
  DateTime? _startDate;
  DateTime? _endDate;
  MissionKind _kind = MissionKind.individual;

  // #v recompensa é somente informativa aqui — #t regra de cálculo (baseada
  // em dificuldade/duração) fica a cargo do backend quando integrar.
  final int _xp = 0;
  final int _gold = 0;
  bool _saving = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      await GamifyApiService.instance.createMission(
        userId: userId,
        title: _titleController.text.trim(),
        reward: _gold,
        experience: _xp,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
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
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  String _fmt(DateTime? d) => d == null ? '' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 1.4),
                      ),
                      child: const Icon(Icons.add, color: AppColors.primaryGreen, size: 28),
                    ),
                    const SizedBox(height: 6),
                    const Text('Adicionar ícone', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const FormLabel('Título da missão'),
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Ex: Correr 5 km')),
            const SizedBox(height: 16),
            const FormLabel('Descrição'),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Descreva o objetivo da missão...'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Atributo principal'),
            AttributeSelector(selected: _attribute, onSelected: (o) => setState(() => _attribute = o)),
            const SizedBox(height: 16),
            const FormLabel('Duração'),
            Row(
              children: [
                Expanded(child: _DateBox(label: 'Data inicial', value: _fmt(_startDate), onTap: () => _pickDate(isStart: true))),
                const SizedBox(width: 12),
                Expanded(child: _DateBox(label: 'Data final (opcional)', value: _fmt(_endDate), onTap: () => _pickDate(isStart: false))),
              ],
            ),
            const SizedBox(height: 16),
            const FormLabel('Tipo de missão'),
            Row(
              children: [
                Expanded(
                  child: SelectableBox(
                    icon: Icons.person,
                    title: 'Individual',
                    subtitle: 'Apenas para você',
                    selected: _kind == MissionKind.individual,
                    onTap: () => setState(() => _kind = MissionKind.individual),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableBox(
                    icon: Icons.group,
                    title: 'Compartilhada',
                    subtitle: 'Pode ser compartilhada',
                    selected: _kind == MissionKind.compartilhada,
                    onTap: () => setState(() => _kind = MissionKind.compartilhada),
                  ),
                ),
              ],
            ),
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 18),
                  SizedBox(width: 6),
                  Text('Adicionar recompensa bônus', style: TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
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

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateBox({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value.isEmpty ? label : value,
                style: TextStyle(color: value.isEmpty ? AppColors.textMuted : AppColors.textPrimary, fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
