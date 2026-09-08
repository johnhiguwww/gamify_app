import 'package:supabase_flutter/supabase_flutter.dart';

// #$ SupabaseService — ponto único de configuração do Supabase.
// #!! troque supabaseUrl e supabaseAnonKey pelos valores do SEU projeto,
// disponíveis em Project Settings > API no painel do Supabase.
class SupabaseService {
  SupabaseService._();

  static const String supabaseUrl = 'https://eiyfmcjzhqqcrofllsjd.supabase.co';
  static const String supabaseAnonKey = 'postgresql://postgres:[YOUR-PASSWORD]@db.eiyfmcjzhqqcrofllsjd.supabase.co:5432/postgres';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
