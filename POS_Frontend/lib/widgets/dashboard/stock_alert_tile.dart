import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_helpers.dart';
import '../../models/dashboard_summary.dart';

/// Ligne d'alerte stock faible sur le tableau de bord.
class StockAlertTile extends StatelessWidget {
  final ProduitStockFaible alerte;

  const StockAlertTile({super.key, required this.alerte});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.orange.withValues(alpha: 0.15),
        child: const Icon(Icons.warning_amber, color: AppColors.orange, size: 20),
      ),
      title: Text(
        alerte.produit,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Seuil : ${alerte.seuil} — Restant : ${alerte.quantite}',
        style: ThemeHelpers.mutedTextStyle(context, fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.rouge.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${alerte.quantite}',
          style: const TextStyle(
            color: AppColors.rouge,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
