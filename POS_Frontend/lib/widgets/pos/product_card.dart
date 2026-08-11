import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../core/utils/formatters.dart';

/// Carte produit affichée dans le catalogue du POS (§10.4).
class ProductCard extends StatelessWidget {
  final Produit produit;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.produit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2),
              const SizedBox(height: 4),
              Text(Formatters.montant(produit.prixVente)),
            ],
          ),
        ),
      ),
    );
  }
}
