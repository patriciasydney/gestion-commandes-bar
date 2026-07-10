// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Palette de couleurs officielle du projet — cahier des charges §10.1
/// Version améliorée avec des tons plus harmonieux et modernes.
class AppColors {
  AppColors._();

  // Couleurs principales — extraites directement du logo ATSYS_POS
  static const Color bleuFonce = Color(0xFF12161B); // Anthracite/noir du logo
  static const Color bleuClair = Color(0xFF3A3F46); // Gris-anthracite clair dérivé (accents)
  static const Color orange = Color(0xFFA77425); // Or/bronze du logo
  static const Color orangeClair = Color(0xFFF4C664); // Or pastel dérivé (highlight du logo)
  
  // Couleurs d'état
  static const Color vert = Color(0xFF10B981); // Vert émeraude (succès)
  static const Color vertClair = Color(0xFF6EE7B7); // Vert pastel
  static const Color jaune = Color(0xFFFBBF24); // Jaune ambre (alerte)
  static const Color rouge = Color(0xFFEF4444); // Rouge corail (erreur)
  static const Color rougeClair = Color(0xFFFCA5A5); // Rouge pastel

  // Couleurs de fond et surface
  static const Color fond = Color(0xFFF8FAFC); // Fond très clair (bleuté)
  static const Color surface = Color(0xFFFFFFFF); // Surface blanche
  static const Color surfaceAlt = Color(0xFFF1F5F9); // Surface alternative
  static const Color bordure = Color(0xFFE2E8F0); // Bordures subtiles

  // Couleurs de texte
  static const Color texte = Color(0xFF0F172A); // Texte principal (presque noir)
  static const Color texteSecondaire = Color(0xFF475569); // Texte secondaire
  static const Color texteClair = Color(0xFF94A3B8); // Texte tertiaire
  static const Color texteDesactive = Color(0xFFCBD5E1); // Texte désactivé

  // Gradients
  static const LinearGradient gradientBleu = LinearGradient(
    colors: [bleuFonce, bleuClair],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientOrange = LinearGradient(
    colors: [orange, orangeClair],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ombres
  static const List<BoxShadow> ombreLegere = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> ombreMoyenne = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> ombreForte = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
