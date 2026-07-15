import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/auth/role_permissions.dart';
import '../../models/categorie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categorie_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Gestion des catégories — cahier des charges §5.3
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategorieProvider>().chargerCategories();
    });
  }

  Future<void> _ouvrirFormulaire({Categorie? categorie}) async {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: categorie?.nom ?? '');
    final descCtrl = TextEditingController(text: categorie?.description ?? '');
    bool actif = categorie?.actif ?? true;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(categorie == null ? 'Nouvelle catégorie' : 'Modifier la catégorie'),
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
                  decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: actif,
                  onChanged: (v) => setStateDialog(() => actif = v),
                  activeThumbColor: AppColors.vert,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context, true);
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
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      actif: actif,
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
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.rouge),
        );
      }
    }
  }

  Future<void> _confirmerSuppression(Categorie categorie) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette catégorie ?'),
        content: Text('« ${categorie.nom} » sera définitivement supprimée.'),
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
      await context.read<CategorieProvider>().supprimer(categorie.idCategorie);
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
    final provider = context.watch<CategorieProvider>();
    final peutModifier = RolePermissions.canWrite(
      AppModule.categories,
      context.watch<AuthProvider>().utilisateur,
    );

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des catégories'),
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
      body: Builder(builder: (context) {
        if (provider.chargement) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.erreur != null) {
          return Center(child: Text(provider.erreur!, style: const TextStyle(color: AppColors.rouge)));
        }
        if (provider.categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie', style: TextStyle(color: AppColors.texteClair)));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: provider.categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final categorie = provider.categories[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: peutModifier ? () => _ouvrirFormulaire(categorie: categorie) : null,
                leading: CircleAvatar(
                  backgroundColor: AppColors.bleuFonce.withValues(alpha: 0.1),
                  child: const Icon(Icons.category_outlined, color: AppColors.bleuFonce),
                ),
                title: Text(categorie.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: categorie.description != null ? Text(categorie.description!) : null,
                trailing: peutModifier
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.rouge),
                        onPressed: () => _confirmerSuppression(categorie),
                      )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }
}
