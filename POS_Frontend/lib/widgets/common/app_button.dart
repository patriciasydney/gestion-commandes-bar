import 'package:flutter/material.dart';

/// Bouton d'action principal réutilisable (couleur orange de la charte graphique).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool chargement;
  final IconData? icone;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.chargement = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: chargement ? null : onPressed,
        icon: chargement
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icone ?? Icons.arrow_forward, size: 18),
        label: Text(label),
      ),
    );
  }
}
