import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/journal_activite.dart';

/// Ligne d'activité récente affichée sur le tableau de bord.
class ActivityTile extends StatelessWidget {
  final JournalActivite activite;

  const ActivityTile({super.key, required this.activite});

  IconData get _icone {
    switch (activite.action) {
      case 'vente':
        return Icons.point_of_sale;
      case 'stock':
        return Icons.inventory_2;
      case 'produit':
        return Icons.local_bar;
      case 'depense':
        return Icons.receipt_long;
      case 'alerte':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  Color get _couleur {
    switch (activite.action) {
      case 'alerte':
        return AppColors.rouge;
      case 'depense':
        return AppColors.orange;
      case 'stock':
        return AppColors.jaune;
      default:
        return AppColors.bleuFonce;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _couleur.withValues(alpha: 0.12),
        child: Icon(_icone, color: _couleur, size: 20),
      ),
      title: Text(
        activite.description ?? activite.action,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        Formatters.tempsRelatif(activite.dateAction),
        style: const TextStyle(fontSize: 12, color: AppColors.texteClair),
      ),
    );
  }
}
