import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_helpers.dart';
import '../../core/utils/validators.dart';
import '../../models/categorie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categorie_provider.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_skeleton.dart';

/// Écran : Gestion des catégories — cahier des charges §5.4 / §10.8
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _rechercheCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategorieProvider>().chargerCategories();
    });
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _ouvrirFormulaire({Categorie? categorie}) async {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: categorie?.nom ?? '');
    final descCtrl = TextEditingController(text: categorie?.description ?? '');
    var actif = categorie?.actif ?? true;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            categorie == null ? 'Nouvelle catégorie' : 'Modifier la catégorie',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => Validators.requis(v, champ: 'Le nom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text(
                    'Les catégories inactives n’apparaissent pas au POS',
                  ),
                  value: actif,
                  onChanged: (v) => setStateDialog(() => actif = v),
                  activeThumbColor: AppColors.vert,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (resultat != true || !mounted) return;

    final provider = context.read<CategorieProvider>();
    final nouvelle = Categorie(
      idCategorie: categorie?.idCategorie ?? 0,
      nom: nomCtrl.text.trim(),
      description:
          descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      actif: actif,
      nombreProduits: categorie?.nombreProduits ?? 0,
    );

    try {
      if (categorie != null) {
        await provider.modifier(categorie.idCategorie, nouvelle);
      } else {
        await provider.creer(nouvelle);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.rouge,
          ),
        );
      }
    }
  }

  Future<void> _confirmerSuppression(Categorie categorie) async {
    if (categorie.nombreProduits > 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Suppression impossible'),
          content: Text(
            '« ${categorie.nom} » contient ${categorie.nombreProduits} produit(s).\n\n'
            'Réaffectez ces produits à une autre catégorie (ou désactivez-les) '
            'avant de supprimer celle-ci.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
      return;
    }

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette catégorie ?'),
        content: Text('« ${categorie.nom} » sera définitivement supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.rouge),
            ),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    try {
      await context.read<CategorieProvider>().supprimer(categorie.idCategorie);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie supprimée'),
            backgroundColor: AppColors.vert,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.rouge,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorieProvider>();
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final peutModifier = RolePermissions.canWrite(
      AppModule.categories,
      utilisateur,
    );
    final peutSupprimer = utilisateur?.isAdministrateur == true;
    final liste = provider.categoriesFiltrees;

    return Scaffold(
      appBar: const AppHeader(title: 'Gestion des catégories'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/categories'),
      floatingActionButton: peutModifier
          ? FloatingActionButton.extended(
              onPressed: () => _ouvrirFormulaire(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              backgroundColor: AppColors.orange,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: provider.rechercher,
              decoration: InputDecoration(
                hintText: 'Rechercher une catégorie…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: ThemeHelpers.fill(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: provider.recherche.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _rechercheCtrl.clear();
                          provider.rechercher('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.chargement) {
                  return const SkeletonList();
                }
                if (provider.erreur != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.erreur!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.rouge),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: provider.chargerCategories,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (provider.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune catégorie',
                      style: TextStyle(color: AppColors.texteClair),
                    ),
                  );
                }
                if (liste.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun résultat pour cette recherche',
                      style: TextStyle(color: AppColors.texteClair),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: provider.chargerCategories,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: liste.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final categorie = liste[i];
                      return _CarteCategorie(
                        categorie: categorie,
                        peutModifier: peutModifier,
                        peutSupprimer: peutSupprimer,
                        onEdit: () =>
                            _ouvrirFormulaire(categorie: categorie),
                        onDelete: () => _confirmerSuppression(categorie),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteCategorie extends StatelessWidget {
  const _CarteCategorie({
    required this.categorie,
    required this.peutModifier,
    required this.peutSupprimer,
    required this.onEdit,
    required this.onDelete,
  });

  final Categorie categorie;
  final bool peutModifier;
  final bool peutSupprimer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final couleurStatut = categorie.actif ? AppColors.vert : AppColors.orange;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: peutModifier ? onEdit : null,
        leading: CircleAvatar(
          backgroundColor: (categorie.actif
                  ? AppColors.bleuFonce
                  : AppColors.texteClair)
              .withValues(alpha: 0.12),
          child: Icon(
            Icons.category_outlined,
            color: categorie.actif ? AppColors.bleuFonce : AppColors.texteClair,
          ),
        ),
        title: Text(
          categorie.nom,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: categorie.actif ? null : AppColors.texteClair,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categorie.description != null &&
                categorie.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                categorie.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: couleurStatut.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    categorie.actif ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: couleurStatut,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${categorie.nombreProduits} produit'
                  '${categorie.nombreProduits > 1 ? 's' : ''}',
                  style: ThemeHelpers.mutedTextStyle(context, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: peutSupprimer
            ? IconButton(
                tooltip: categorie.nombreProduits > 0
                    ? 'Suppression bloquée (produits liés)'
                    : 'Supprimer',
                icon: Icon(
                  Icons.delete_outline,
                  color: categorie.nombreProduits > 0
                      ? AppColors.texteClair
                      : AppColors.rouge,
                ),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
