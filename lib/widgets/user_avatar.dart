import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// #$ UserAvatar — foto de perfil redonda; sem foto (ou se a imagem falhar),
// mostra a inicial do nome. Usada no dashboard e na tela de perfil.
class UserAvatar extends StatelessWidget {
  // #p name: nome do usuário (de onde sai a inicial)
  final String name;
  // #p avatarUrl: link da imagem; vazio = mostra só a inicial
  final String avatarUrl;
  // #p radius: raio do círculo
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    // #v inicial do nome (characters evita quebrar emoji no meio)
    final String trimmed = name.trim();
    final String initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    // #v letra exibida quando não há imagem
    final Widget letter = Text(
      initial,
      style: TextStyle(fontSize: radius * 0.8, color: AppColors.primaryGreen),
    );

    // #if sem link: só a letra
    if (avatarUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceAlt,
        child: letter,
      );
    }

    // ## com link: carrega a imagem recortada em círculo
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceAlt,
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          // ## a key com a URL força recarregar quando o link muda (?v=...)
          key: ValueKey(avatarUrl),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          // #!! na web, imagens de outros domínios (ex.: foto do Google)
          // podem ser bloqueadas por CORS; este modo usa a tag <img> e evita isso
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          // #if a imagem falhou: mostra a letra
          errorBuilder: (context, error, stack) => SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Center(child: letter),
          ),
          // #if ainda carregando: mostra a letra
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: Center(child: letter),
            );
          },
        ),
      ),
    );
  }
}