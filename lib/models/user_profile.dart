// #$ UserProfile — dados do cabeçalho do dashboard (Figura 3).
class UserProfile {
  final String name;
  final String rank; // #v ex: "Faixa Verde"
  final int globalLevel;
  final int currentXp;
  final int maxXp;
  final int gold;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.rank,
    required this.globalLevel,
    required this.currentXp,
    required this.maxXp,
    required this.gold,
    required this.avatarUrl,
  });

  int get xpToNextLevel => maxXp - currentXp;
  double get ratio => maxXp == 0 ? 0 : (currentXp / maxXp).clamp(0, 1);

  // #f fromMap — monta o UserProfile a partir de uma linha da tabela
  // `profiles` do Supabase (ver AuthService.fetchProfile).
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: (map['name'] as String?) ?? (map['full_name'] as String?) ?? 'Jogador',
      rank: (map['rank'] as String?) ?? 'Iniciante',
      globalLevel: (map['global_level'] as num?)?.toInt() ?? 1,
      currentXp: (map['current_xp'] as num?)?.toInt() ?? 0,
      maxXp: (map['max_xp'] as num?)?.toInt() ?? 100,
      gold: (map['gold'] as num?)?.toInt() ?? 0,
      avatarUrl: (map['avatar_url'] as String?) ?? '',
    );
  }
}
