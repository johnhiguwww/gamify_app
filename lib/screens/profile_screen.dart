import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mock_data.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../services/gamify_api_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gamify_progress_bar.dart';
import '../widgets/user_avatar.dart';

// #$ ProfileScreen — foto, nome editável, nível e botão de sair.
// ## a foto vai para o Supabase Storage (bucket avatars) e o link é gravado
// no avatarUrl do perfil pela API (PUT /profiles/update/{uuid}).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // #v controlador do campo de nome
  final TextEditingController _nameCtrl = TextEditingController();
  // #v seletor de imagem da galeria
  final ImagePicker _picker = ImagePicker();
  // #v true enquanto envia a foto ou salva o nome (trava cliques repetidos)
  bool _busy = false;
  // #v tamanho máximo da foto (o bucket foi criado com 2 MB)
  static const int _maxBytes = 2 * 1024 * 1024;
  // #v limite de caracteres do nome (escolha do app; a coluna comporta 255)
  static const int _maxNameLength = 100;

  @override
  void initState() {
    super.initState();
    // ## começa o campo com o nome atual do perfil
    _nameCtrl.text = (CurrentUser.profile ?? MockData.user).name;
    // ## redesenha para habilitar/desabilitar o botão Salvar ao digitar
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // #f _snack — mostra uma mensagem rápida embaixo da tela
  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // #f _currentAvatarUrl — link da foto a reenviar para a API
  // ## a API exige um avatarUrl válido em TODO update; se o perfil não tem
  // foto, usa a foto do Google (userMetadata) como alternativa
  // #r String com o link, ou vazio se não houver nenhum
  String _currentAvatarUrl(UserProfile profile) {
    // #if o perfil já tem foto
    if (profile.avatarUrl.trim().isNotEmpty) return profile.avatarUrl;
    // ## senão tenta a foto que o Google devolveu no login
    final google = AuthService.instance.currentUser?.userMetadata?['avatar_url'];
    return google is String ? google : '';
  }

  // #f _saveName — salva o nome novo (reenvia a foto atual)
  Future<void> _saveName(UserProfile profile) async {
    // #if já tem operação em andamento
    if (_busy) return;
    final userId = AuthService.instance.currentUser?.id;
    // #if sem sessão
    if (userId == null) {
      _snack('Sessão expirada, faça login novamente.');
      return;
    }
    final name = _nameCtrl.text.trim();
    // #if nome vazio (a API recusa: @NotBlank)
    if (name.isEmpty) {
      _snack('O nome não pode ficar vazio.');
      return;
    }
    final avatarUrl = _currentAvatarUrl(profile);
    // #if sem nenhuma foto: a API recusa avatarUrl vazio
    if (avatarUrl.isEmpty) {
      _snack('Escolha uma foto primeiro: a API exige uma foto para salvar o perfil.');
      return;
    }

    setState(() => _busy = true);
    try {
      await GamifyApiService.instance.updateProfile(
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      _snack('Nome atualizado!');
    } catch (e) {
      _snack('Não foi possível salvar o nome: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // #f _changePhoto — escolhe da galeria, envia ao Storage e grava o link
  Future<void> _changePhoto(UserProfile profile) async {
    // #if já tem operação em andamento
    if (_busy) return;
    final userId = AuthService.instance.currentUser?.id;
    // #if sem sessão
    if (userId == null) {
      _snack('Sessão expirada, faça login novamente.');
      return;
    }

    setState(() => _busy = true);
    try {
      // ## abre a galeria (na web, abre o seletor de arquivos)
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      // #if o usuário cancelou
      if (file == null) return;

      // #v extensão: pelo tipo do arquivo, ou pelo nome se o tipo vier vazio
      String ext = '';
      final mime = file.mimeType ?? '';
      if (mime.startsWith('image/')) {
        ext = mime.substring(6);
      } else if (file.name.contains('.')) {
        ext = file.name.split('.').last;
      }
      ext = ext.toLowerCase();
      // #if formato que o bucket não aceita
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        _snack('Use uma imagem JPG, PNG ou WEBP.');
        return;
      }

      final bytes = await file.readAsBytes();
      // #if maior que 2 MB
      if (bytes.length > _maxBytes) {
        _snack('A imagem passa de 2 MB. Escolha uma menor.');
        return;
      }

      // ## envia ao Supabase Storage e recebe o link público
      final url = await SupabaseService.uploadAvatar(
        userId: userId,
        bytes: bytes,
        extension: ext,
      );

      // ## grava o link na API reenviando o nome ATUAL do perfil
      await GamifyApiService.instance.updateProfile(
        userId: userId,
        name: profile.name,
        avatarUrl: url,
      );
      _snack('Foto atualizada!');
    } catch (e) {
      _snack('Não foi possível trocar a foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Center(child: Text(user.rank, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 13))),
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
          ),
        );
      },
    );
  }
}