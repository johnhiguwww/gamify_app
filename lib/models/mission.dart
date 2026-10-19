import 'package:flutter/material.dart';
import 'attribute.dart';

// #$ enums usados pela Mission (a API só manda `finished`)
enum MissionStatus { ativa, concluida }

enum MissionKind { individual, compartilhada }

// #$ Mission: ao concluir credita xpReward ao XP_Total do usuário (não ao
// atributo) e goldReward ao saldo de Gold. progress é a % mostrada na barra.
class Mission {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final AttributeType attribute;
  final double progress; // #v 0..1
  final int xpReward;
  final int goldReward;
  final int daysLeft;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  // #v createdAt e finishedAt vêm direto da API (MissionOutPutDTO)
  final DateTime? createdAt;
  final DateTime? finishedAt;

  // #v a API não manda estes dois: têm valor padrão
  final MissionStatus status;
  final MissionKind kind;

  // #f construtor: status e kind são opcionais
  const Mission({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.attribute,
    required this.progress,
    required this.xpReward,
    required this.goldReward,
    required this.daysLeft,
    this.status = MissionStatus.ativa,
    this.kind = MissionKind.individual,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.finishedAt,
  });

  // #f _parseDate — texto ISO da API vira DateTime; null se vier vazio ou inválido
  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  // #f fromJson: converte o MissionOutPutDTO da API em Mission
  // #p json: mapa vindo do jsonDecode
  // #r Mission pronta para as telas
  factory Mission.fromJson(Map<String, dynamic> json) {
    // #v a API só diz se terminou ou não
    final finished = json['finished'] as bool? ?? false;

    // #t a API não manda atributo: usando Inteligência até existir na API
    const attribute = AttributeType.inteligencia;

    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      // ## ícone vem do atributo (extension AttributeTypeX)
      icon: attribute.icon,
      // #t cor provisória, trocar pela cor do atributo (AppColors)
      iconColor: Colors.blueGrey,
      attribute: attribute,
      // #t sem tarefas contadas na API: 100% se concluída, 0% se não
      progress: finished ? 1.0 : 0.0,
      // ## nomes diferentes: experience -> xpReward, reward -> goldReward
      xpReward: json['experience'] as int,
      goldReward: json['reward'] as int,
      // #t sem data final na API, não há como calcular os dias restantes
      daysLeft: 0,
      // ## datas reais da API
      createdAt: _parseDate(json['createdAt']),
      finishedAt: _parseDate(json['finishedAt']),
      // #if concluída vira "concluida", senão "ativa"
      status: finished ? MissionStatus.concluida : MissionStatus.ativa,
    );
  }
}