import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/gamify_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/form_bits.dart';

// #$ NewMissionScreen — só envia o que o POST /missions/new aceita:
// userId, title, experience e reward (todos obrigatórios; os números >= 0).
// ## visual alinhado com a NewTaskScreen (cabeçalho, contador, prévia),
// mas SEM campos que a API de missão não aceita.
class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});

  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  // #v controladores dos três campos
  final _titleController = TextEditingController();
  final _xpController = TextEditingController();
  final _goldController = TextEditingController();

  // #v true enquanto o POST está em andamento
  bool _saving = false;

  // #!! limite só visual (contador); a API não foi conferida quanto ao tamanho do título
  static const int _titleMax = 60;

  // #f _xp / _gold — valor digitado como int (null se vazio ou inválido)
  int? get _xp => int.tryParse(_xpController.text.trim());
  int? get _gold => int.tryParse(_goldController.text.trim());

  // #f _canSubmit — título preenchido, XP e ouro informados e sem envio em andamento
  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty && _xp != null && _gold != null && !_saving;

  @override
  void initState() {
    super.initState();
    // #!! reconstrói ao digitar para habilitar/desabilitar o botão e atualizar a prévia
    for (final c in [_titleController, _xpController, _goldController]) {
      c.addListener(() => setState(() {}));
    }
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
    // #if não pode enviar: sai sem fazer nada
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
    // #v valores exibidos na prévia (0 enquanto vazio)
    final previewXp = _xp ?? 0;
    final previewGold = _gold ?? 0;
    final previewTitle = _titleController.text.trim().isEmpty
        ? 'Título da missão'
        : _titleController.text.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ## cabeçalho: fechar, título, subtítulo e botão Salvar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nova Missão',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text('Defina um objetivo e a recompensa por cumpri-lo.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Text('Salvar',
                          style: TextStyle(
                              color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ## título com contador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FormLabel('Título da missão'),
                Text('${_titleController.text.length}/$_titleMax',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            TextField(
              controller: _titleController,
              maxLength: _titleMax,
              // ## esconde o contador padrão (usamos o nosso acima)
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(hintText: 'Ex: Completar tutorial'),
            ),
            const SizedBox(height: 18),

            // ## recompensa: XP e ouro lado a lado
            const FormLabel('Recompensa', tooltip: 'XP e ouro ganhos ao concluir a missão'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('XP',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _xpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: _numberFormatters,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 50',
                          prefixIcon: Icon(Icons.bolt_rounded, color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ouro',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _goldController,
                        keyboardType: TextInputType.number,
                        inputFormatters: _numberFormatters,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 10',
                          prefixIcon: Icon(Icons.monetization_on, color: AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ## prévia: mostra como a missão aparece na lista
            const FormLabel('Prévia da missão'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.track_changes_rounded,
                          color: AppColors.danger, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _titleController.text.trim().isEmpty
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // ## toda missão nova nasce ativa (finished = false)
                          const Text('Missão · Ativa',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+$previewXp XP',
                            style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5)),
                        Row(children: [
                          const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                          const SizedBox(width: 3),
                          Text('$previewGold Ouro',
                              style: const TextStyle(color: AppColors.gold, fontSize: 11.5)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ## botão principal também embaixo (mais fácil de achar no celular)
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