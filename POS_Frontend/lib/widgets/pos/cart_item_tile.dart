import 'package:flutter/material.dart';
import '../../providers/panier_provider.dart';
import '../../core/utils/formatters.dart';

/// Ligne d'article dans le panier de la vente en cours (§10.4).
class CartItemTile extends StatelessWidget {
  final ArticlePanier article;
  final void Function(int quantite) onQuantiteChanged;
  final VoidCallback onSupprimer;

  const CartItemTile({
    super.key,
    required this.article,
    required this.onQuantiteChanged,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article.produit.nom),
      subtitle: Text(Formatters.montant(article.sousTotal)),
      leading: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () => onQuantiteChanged(article.quantite - 1),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${article.quantite}"),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onQuantiteChanged(article.quantite + 1),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onSupprimer,
          ),
        ],
      ),
    );
  }
}
