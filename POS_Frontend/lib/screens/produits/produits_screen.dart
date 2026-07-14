import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_helpers.dart';
import '../../core/utils/formatters.dart';
import '../../models/produit.dart';
import '../../providers/categorie_provider.dart';
import '../../providers/produit_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/filter_choice_chip.dart';

/// Écran : Gestion des produits — cahier des charges §10.5
class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({super.key});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().chargerProduits();
      context.read<CategorieProvider>().chargerCategories();
    });
  }

  Future<void> _ouvrirFormulaire({Produit? produit}) async {
    final resultat = await Navigator.pushNamed(
      context,
      AppRoutes.produitForm,
      arguments: produit,
    );
    if (resultat == true && mounted) {
      context.read<ProduitProvider>().chargerProduits();
    }
  }

  Future<void> _confirmerSuppression(Produit produit) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('« ${produit.nom} » sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.rouge)),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    try {
      await context.read<ProduitProvider>().supprimer(produit.idProduit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('« ${produit.nom} » supprimé'), backgroundColor: AppColors.vert),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.rouge),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produitProvider = context.watch<ProduitProvider>();
    final categorieProvider = context.watch<CategorieProvider>();

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des produits'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/produits'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: AppColors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: themedSearchDecoration(
                    context,
                    hint: 'Rechercher un produit (nom, code, code-barres)…',
                  ),
                  onChanged: produitProvider.rechercher,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ChipCategorie(
                        label: 'Toutes',
                        selectionnee: produitProvider.filtreCategorie == null,
                        onTap: () => produitProvider.filtrerParCategorie(null),
                      ),
                      for (final c in categorieProvider.categories)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _ChipCategorie(
                            label: c.nom,
                            selectionnee: produitProvider.filtreCategorie == c.idCategorie,
                            onTap: () => produitProvider.filtrerParCategorie(c.idCategorie),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (produitProvider.chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (produitProvider.erreur != null) {
                return Center(child: Text(produitProvider.erreur!, style: const TextStyle(color: AppColors.rouge)));
              }
              if (produitProvider.produits.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun produit trouvé',
                    style: ThemeHelpers.mutedTextStyle(context),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: produitProvider.chargerProduits,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: produitProvider.produits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final produit = produitProvider.produits[i];
                    return _LigneProduit(
                      produit: produit,
                      categorieNom: categorieProvider.nomCategorie(produit.categorie),
                      onTap: () => _ouvrirFormulaire(produit: produit),
                      onSupprimer: () => _confirmerSuppression(produit),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ChipCategorie extends StatelessWidget {
  final String label;
  final bool selectionnee;
  final VoidCallback onTap;

  const _ChipCategorie({required this.label, required this.selectionnee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChoiceChip(
      label: label,
      selected: selectionnee,
      onSelected: onTap,
    );
  }
}

class _LigneProduit extends StatelessWidget {
  final Produit produit;
  final String categorieNom;
  final VoidCallback onTap;
  final VoidCallback onSupprimer;

  const _LigneProduit({
    required this.produit,
    required this.categorieNom,
    required this.onTap,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 52,
            height: 52,
            child: _ProduitImage(image: produit.image),
          ),
        ),
        title: Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$categorieNom · ${produit.contenance ?? ''} · ${Formatters.montant(produit.prixVente)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!produit.actif)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.visibility_off_outlined, size: 18, color: AppColors.texteClair),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.rouge),
              onPressed: onSupprimer,
            ),
          ],
        ),
      ),
    );
  }
}


class _ProduitImage extends StatelessWidget {
  const _ProduitImage({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return Container(
        color: ThemeHelpers.fill(context),
        child: Icon(Icons.local_bar, color: ThemeHelpers.mutedText(context)),
      );
    }

    if (image!.startsWith('http') || image!.startsWith('/')) {
      return Image.network(image!, fit: BoxFit.cover);
    }

    try {
      return Image.memory(base64Decode(image!), fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: ThemeHelpers.fill(context),
        child: Icon(Icons.broken_image_outlined, color: ThemeHelpers.mutedText(context)),
      );
    }
  }
}
