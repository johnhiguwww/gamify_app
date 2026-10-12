import 'package:flutter/material.dart';

// #$ AppColors — paleta única do app; nunca usar Color(0x...) solto nas telas,
// sempre referenciar daqui para manter consistência visual entre as 6 telas.
class AppColors {
  AppColors._();

  // fundo
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF131926);
  static const Color surfaceAlt = Color(0xFF0F1420);
  static const Color border = Color(0xFF232B3A);

  // texto
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF8B96A8);
  static const Color textMuted = Color(0xFF5C6478);

  // marca
  static const Color primaryGreen = Color(0xFF22E36B);
  static const Color primaryGreenDim = Color(0xFF16A34A);
  static const Color gold = Color(0xFFF5B942);
  static const Color danger = Color(0xFFEF4444);

  // atributos (mesma ordem do dashboard)
  static const Color inteligencia = Color(0xFF3B82F6);
  static const Color forca = Color(0xFFEF4444);
  static const Color espiritualidade = Color(0xFFA855F7);
  static const Color carisma = Color(0xFF22C55E);
  static const Color percepcaoEspacial = Color(0xFF22D3EE);
  static const Color autoconsciencia = Color(0xFFFBBF24);
  static const Color linguagem = Color(0xFF6366F1);
  static const Color raciocinioLogico = Color(0xFFF97316);
  static const Color musicalidade = Color(0xFFEC4899);

  // dificuldade
  static const Color facil = Color(0xFF22C55E);
  static const Color media = Color(0xFFFBBF24);
  static const Color alta = Color(0xFFEF4444);
}
