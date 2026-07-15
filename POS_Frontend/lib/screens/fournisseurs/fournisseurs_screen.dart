import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/fournisseur.dart';
import '../../providers/auth_provider.dart';
import '../../services/fournisseur_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Gestion des fournisseurs — cahier des charges §5.6
class FournisseursScreen extends StatefulWidget {
  const FournisseursScreen({super.key});

  @override
  State<FournisseursScreen> createState() => _FournisseursScreenState();
}

class _FournisseursScreenState extends State<FournisseursScreen> {
  final FournisseurService _service = FournisseurService();
  List<Fournisseur> _fournisseurs = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { _chargement = true; _erreur = null; });
    try {
      _fournisseurs = await _service.getAll();
    } catch (e) {
      _erreur = "Impossible de charger les fournisseurs (backend non branché ?)";
    }
    if (mounted) setState(() => _chargement = false);
  }

  Future<void> _ouvrirFormulaire({Fournisseur? fournisseur}) async {
    final formKey = GlobalKey<FormState>();
    final raisonCtrl = TextEditingController(text: fournisseur?.raisonSociale ?? '');
    final telCtrl = TextEditingController(text: fournisseur?.telephone ?? '');
    final emailCtrl = TextEditingController(text: fournisseur?.email ?? '');
    final adresseCtrl = TextEditingController(text: fournisseur?.adresse ?? '');
    bool actif = fournisseur?.actif ?? true;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(fournisseur == null ? 'Nouveau fournisseur' : 'Modifier le fournisseur'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: raisonCtrl,
                    decoration: const InputDecoration(labelText: 'Raison sociale'),
                    validator: (v) => Validators.requis(v, champ: 'La raison sociale'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telCtrl,
                    decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email (optionnel)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adresseCtrl,
                    decoration: const InputDecoration(labelText: 'Adresse (optionnel)'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Actif'),
                    value: actif,
                    onChanged: (v) => setStateDialog(() => actif = v),
                    activeThumbColor: AppColors.vert,
                  ),
                ],
              ),
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

    final nouveau = Fournisseur(
      idFournisseur: fournisseur?.idFournisseur ?? 0,
      raisonSociale: raisonCtrl.text.trim(),
      telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      adresse: adresseCtrl.text.trim().isEmpty ? null : adresseCtrl.text.trim(),
      actif: actif,
    );

    try {
      if (fournisseur != null) {
        await _service.update(fournisseur.idFournisseur, nouveau);
      } else {
        await _service.create(nouveau);
      }
      await _charger();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.rouge),
        );
      }
    }
  }

  Future<void> _confirmerSuppression(Fournisseur fournisseur) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce fournisseur ?'),
        content: Text('« ${fournisseur.raisonSociale} » sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.rouge)),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    try {
      await _service.delete(fournisseur.idFournisseur);
      await _charger();
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
    final peutModifier = RolePermissions.canWrite(
      AppModule.fournisseurs,
      context.watch<AuthProvider>().utilisateur,
    );

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des fournisseurs'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/fournisseurs'),
      floatingActionButton: peutModifier
          ? FloatingActionButton.extended(
              onPressed: () => _ouvrirFormulaire(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              backgroundColor: AppColors.orange,
            )
          : null,
      body: Builder(builder: (context) {
        if (_chargement) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_erreur != null) {
          return Center(child: Text(_erreur!, style: const TextStyle(color: AppColors.rouge)));
        }
        if (_fournisseurs.isEmpty) {
          return const Center(child: Text('Aucun fournisseur', style: TextStyle(color: AppColors.texteClair)));
        }
        return RefreshIndicator(
          onRefresh: _charger,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: _fournisseurs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final f = _fournisseurs[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _ouvrirFormulaire(fournisseur: f),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.orange.withValues(alpha: 0.12),
                    child: const Icon(Icons.local_shipping_outlined, color: AppColors.orange),
                  ),
                  title: Text(f.raisonSociale, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text([if (f.telephone != null) f.telephone!, if (f.email != null) f.email!].join(' · ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.rouge),
                    onPressed: () => _confirmerSuppression(f),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
