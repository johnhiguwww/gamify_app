import 'package:flutter/material.dart';
import '../models/attribute.dart';
import '../models/mission.dart';
import '../models/store_item.dart';
import '../models/task.dart';
import '../models/user_profile.dart';

// #$ MockData — #t substituir por chamadas ao Node.js/Supabase quando a API
// estiver pronta; por ora alimenta as telas com os mesmos valores do design.
class MockData {
  MockData._();

  static const user = UserProfile(
    name: 'João',
    rank: 'Faixa Verde',
    globalLevel: 8,
    currentXp: 1420,
    maxXp: 1600,
    gold: 372,
    avatarUrl: '',
  );

  static final missions = <Mission>[
    Mission(
      id: 'm1',
      title: 'Correr 5 km',
      icon: Icons.directions_run,
      iconColor: const Color(0xFF3B82F6),
      attribute: AttributeType.forca,
      status: MissionStatus.ativa,
      progress: 0.60,
      xpReward: 300,
      goldReward: 80,
      daysLeft: 3,
    ),
    Mission(
      id: 'm2',
      title: 'Tirar 10 em Fundamentos de IA',
      icon: Icons.psychology_alt,
      iconColor: const Color(0xFFA855F7),
      attribute: AttributeType.inteligencia,
      status: MissionStatus.ativa,
      progress: 0.60,
      xpReward: 400,
      goldReward: 100,
      daysLeft: 7,
    ),
    Mission(
      id: 'm3',
      title: 'Atingir A2 em nível de inglês',
      icon: Icons.translate,
      iconColor: const Color(0xFF3B82F6),
      attribute: AttributeType.linguagem,
      status: MissionStatus.ativa,
      progress: 0.40,
      xpReward: 300,
      goldReward: 90,
      daysLeft: 14,
    ),
    Mission(
      id: 'm4',
      title: 'Meditação diária por 7 dias',
      icon: Icons.self_improvement,
      iconColor: const Color(0xFFEC4899),
      attribute: AttributeType.espiritualidade,
      status: MissionStatus.ativa,
      progress: 0.28,
      xpReward: 150,
      goldReward: 40,
      daysLeft: 2,
    ),
  ];

  static final tasksToday = <GamifyTask>[
    GamifyTask(
      id: 't1',
      title: 'Estudar IA por 45 min',
      icon: Icons.menu_book,
      iconColor: const Color(0xFF3B82F6),
      partOfMission: true,
      xpReward: 25,
      goldReward: 10,
    ),
    GamifyTask(
      id: 't2',
      title: 'Treinar na academia',
      icon: Icons.fitness_center,
      iconColor: const Color(0xFFEF4444),
      attribute: AttributeType.forca,
      xpReward: 20,
      goldReward: 10,
    ),
    GamifyTask(
      id: 't3',
      title: 'Meditar por 10 min',
      icon: Icons.self_improvement,
      iconColor: const Color(0xFFEC4899),
      partOfMission: true,
      xpReward: 15,
      goldReward: 8,
      completedInCurrentCycle: true,
    ),
    GamifyTask(
      id: 't4',
      title: 'Fazer 10 contatos',
      icon: Icons.groups,
      iconColor: const Color(0xFF22C55E),
      attribute: AttributeType.carisma,
      xpReward: 20,
      goldReward: 10,
    ),
  ];

  static final storeItems = <StoreItem>[
    const StoreItem(
      id: 's1',
      title: 'Comprar um doce',
      description: 'Um pequeno prazer que você merece.',
      cost: 30,
      icon: Icons.cake,
      iconColor: Color(0xFFEC4899),
    ),
    const StoreItem(
      id: 's2',
      title: 'Comprar um livro',
      description: 'Invista no seu crescimento e conhecimento.',
      cost: 80,
      icon: Icons.menu_book,
      iconColor: Color(0xFF3B82F6),
    ),
    const StoreItem(
      id: 's3',
      title: 'Viagem para a praia',
      description: 'Desconecte, relaxe e recarregue.',
      cost: 300,
      icon: Icons.beach_access,
      iconColor: Color(0xFFFBBF24),
    ),
  ];
}