import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/form_bits.dart';

// #$ NewMissionScreen — só envia o que o POST /missions/new aceita:
// userId, title, experience e reward (todos obrigatórios; os números >= 0).
class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});

  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  final _titleController = TextEditingController();
  final _xpController = TextEditingController();
  final _goldController = TextEditingController();
  bool _saving = false;

  // #f _xp / _gold — valor digitado como int (null se vazio ou inválido)
  int? get _xp => int.tryParse(_xpController.text.trim());
  int? get _gold => int.tryParse(_goldController.text.trim());

  // #f _canSubmit — título preenchido, XP e ouro informados e sem envio em andamento
  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty && _xp != null && _gold != null && !_saving;

  @override
  void initState() {
    super.initState();
    // #!! reconstrói ao digitar pra habilitar/desabilitar "Criar Missão" em tempo real.
    _titleController.addListener(() => setState(() {}));
    _xpController.addListener(() => setState(() {}));
    _goldController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _xpController.dispose();
    _goldController.dispose();
    super.dispose();
  }

  // #f _submit — POST /missions/new
  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Sessão expirada, faça login novamente.');
      await GamifyApiService.instance.createMission(
        userId: userId,
        title: _titleController.text.trim(),
        reward: _gold!,
        experience: _xp!,
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

  // ## só dígitos (sem negativo), até 9 dígitos para caber no Integer da API
  List<TextInputFormatter> get _numberFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ];

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
                const Text('Nova Missão',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            const FormLabel('Título da missão'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Ex: Completar tutorial'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Experiência (XP)'),
            TextField(
              controller: _xpController,
              keyboardType: TextInputType.number,
              inputFormatters: _numberFormatters,
              decoration: const InputDecoration(hintText: 'Ex: 50'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Recompensa em ouro'),
            TextField(
              controller: _goldController,
              keyboardType: TextInputType.number,
              inputFormatters: _numberFormatters,
              decoration: const InputDecoration(hintText: 'Ex: 10'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
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