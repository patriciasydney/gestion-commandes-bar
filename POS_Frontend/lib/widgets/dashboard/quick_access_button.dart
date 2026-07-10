import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Raccourci vers un module principal, affiché en grille sur le tableau de bord
/// (inspiré du sélecteur d'applications d'Odoo).
class QuickAccessButton extends StatelessWidget {
  final String label;
  final IconData icone;
  final Color couleur;
  final VoidCallback onTap;

  const QuickAccessButton({
    super.key,
    required this.label,
    required this.icone,
    required this.onTap,
    this.couleur = AppColors.bleuFonce,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: couleur),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
