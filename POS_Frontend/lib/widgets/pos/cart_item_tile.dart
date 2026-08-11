import 'package:flutter/material.dart';
import '../../providers/panier_provider.dart';
import '../../core/utils/formatters.dart';

/// Ligne d'article dans le panier de la vente en cours (§10.4).
class CartItemTile extends StatelessWidget {
  final ArticlePanier article;
  final void Function(int quantite) onQuantiteChanged;
  final VoidCallback onSupprimer;
  final bool dense;
  final bool lectureSeule;

  const CartItemTile({
    super.key,
    required this.article,
    required this.onQuantiteChanged,
    required this.onSupprimer,
    this.dense = false,
    this.lectureSeule = false,
  });

  @override
  Widget build(BuildContext context) {
    final qtyControls = lectureSeule
        ? Text(
            '×${article.quantite}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: dense ? 13 : 14,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity:
                    dense ? VisualDensity.compact : VisualDensity.standard,
                iconSize: dense ? 20 : 24,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => onQuantiteChanged(article.quantite - 1),
              ),
              SizedBox(
                width: dense ? 20 : 24,
                child: Text(
                  '${article.quantite}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: dense ? 13 : 14,
                  ),
                ),
              ),
              IconButton(
                visualDensity:
                    dense ? VisualDensity.compact : VisualDensity.standard,
                iconSize: dense ? 20 : 24,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onQuantiteChanged(article.quantite + 1),
              ),
              IconButton(
                visualDensity:
                    dense ? VisualDensity.compact : VisualDensity.standard,
                iconSize: dense ? 20 : 24,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onSupprimer,
              ),
            ],
          );

    return ListTile(
      dense: dense,
      contentPadding: EdgeInsets.symmetric(
        horizontal: dense ? 4 : 8,
        vertical: 0,
      ),
      title: Text(
        article.produit.nom,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(Formatters.montant(article.sousTotal)),
      trailing: qtyControls,
    );
  }
}
