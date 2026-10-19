import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

// #$ SupabaseService — ponto único de configuração do Supabase.
// #!! troque supabaseUrl e supabaseAnonKey pelos valores do SEU projeto,
// disponíveis em Project Settings > API no painel do Supabase.
class SupabaseService {
  SupabaseService._();

  static const String supabaseUrl = 'https://eiyfmcjzhqqcrofllsjd.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_znaEWRyeirGQyC_E4kNbhg_hbR_s646';

  // #v nome do bucket público criado no Supabase Storage
  static const String avatarBucket = 'avatars';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // #f uploadAvatar — envia a foto para avatars/{userId}/avatar.{ext} e
  // devolve o link público (com ?v=data/hora para furar o cache do navegador)
  // #!! o primeiro nível da pasta TEM que ser o id do usuário: é o que as
  // políticas do Storage conferem (auth.uid())
  // #p userId: id do usuário logado
  // #p bytes: conteúdo da imagem
  // #p extension: jpg, jpeg, png ou webp
  // #r String com o link público da imagem
  static Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    // #v extensão normalizada (jpeg vira jpg)
    final String ext = extension.toLowerCase() == 'jpeg' ? 'jpg' : extension.toLowerCase();
    final String path = '$userId/avatar.$ext';

    // #v tipo do arquivo; o bucket só aceita jpeg, png e webp
    final String contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final storage = client.storage.from(avatarBucket);

    // ## upsert: troca a foto antiga se já existir
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: contentType),
    );

    // ## apaga fotos antigas de outro formato (ex.: trocou png por jpg)
    // falhar aqui não pode atrapalhar o envio
    try {
      final others = ['jpg', 'jpeg', 'png', 'webp']
          .where((e) => e != ext)
          .map((e) => '$userId/avatar.$e')
          .toList();
      await storage.remove(others);
    } catch (_) {}

    // #r link público + versão para não mostrar a imagem antiga em cache
    final String url = storage.getPublicUrl(path);
    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }
}