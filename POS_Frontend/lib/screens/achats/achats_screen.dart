import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/achat.dart';
import '../../models/produit.dart';
import '../../providers/produit_provider.dart';
import '../../services/achat_service.dart';
import '../../services/fournisseur_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Achats / Approvisionnements — cahier des charges §10.6 (volet approvisionnement)
///
/// Liste les achats déjà enregistrés et permet d'en créer un nouveau via un
/// formulaire multi-lignes. La validation déclenche côté backend la création
/// automatique des mouvements de stock d'entrée pour chaque produit commandé.
class AchatsScreen extends StatefulWidget {
  const AchatsScreen({super.key});

  @override
  State<AchatsScreen> createState() => _AchatsScreenState();
}

class _AchatsScreenState extends State<AchatsScreen> {
  final AchatService _achatService = AchatService();

  List<Achat> _achats = [];
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().chargerProduits();
      _chargerAchats();
    });
  }

  Future<void> _chargerAchats() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      _achats = await _achatService.getAll();
    } catch (_) {
      _erreur = "Impossible de charger les achats (backend non branché ?)";
    }
    if (mounted) setState(() => _chargement = false);
  }

  String _nomFournisseur(int? idFournisseur) {
    if (idFournisseur == null) return '—';
    // Récupère le nom via le service (cache local possible plus tard).
    // Pour rester simple, on retourne l'id temporairement et le formulaire
    // affichera le nom complet du fournisseur sélectionné.
    return 'Fournisseur #$idFournisseur';
  }

  Future<void> _ouvrirFormulaireNouvelAchat() async {
    final resultat = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const _FormulaireAchatScreen()),
    );
    if (resultat == true && mounted) {
      _chargerAchats();
      // Recharge aussi les stocks pour que les nouvelles entrées soient visibles.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Achat enregistré — stock mis à jour automatiquement'),
            backgroundColor: AppColors.vert,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'Achats / Approvisionnements'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/achats'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirFormulaireNouvelAchat,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel achat'),
        backgroundColor: AppColors.orange,
      ),
      body: Builder(builder: (context) {
        if (_chargement) return const Center(child: CircularProgressIndicator());
        if (_erreur != null) {
          return Center(child: Text(_erreur!,
              style: const TextStyle(color: AppColors.rouge)));
        }
        if (_achats.isEmpty) {
          return const Center(
            child: Text('Aucun achat enregistré pour le moment',
                style: TextStyle(color: AppColors.texteClair)),
          );
        }
        return RefreshIndicator(
          onRefresh: _chargerAchats,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: _achats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = _achats[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.bleuFonce,
                    child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  ),
                  title: Text('Achat #${a.idAchat}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(_nomFournisseur(a.fournisseur)),
                      Text(Formatters.dateHeure(a.dateAchat),
                          style: const TextStyle(
                              color: AppColors.texteClair, fontSize: 12)),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Formatters.montant(a.montantTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.vert.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          a.statut.toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.vert, fontSize: 10),
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Formulaire de création d'un achat multi-lignes
// ---------------------------------------------------------------------------

class _FormulaireAchatScreen extends StatefulWidget {
  const _FormulaireAchatScreen();

  @override
  State<_FormulaireAchatScreen> createState() => _FormulaireAchatScreenState();
}

class _LigneAchat {
  Produit? produit;
  final TextEditingController quantiteCtrl = TextEditingController(text: '1');
  final TextEditingController prixUnitaireCtrl = TextEditingController();

  double get sousTotal {
    final qte = int.tryParse(quantiteCtrl.text) ?? 0;
    final pu = double.tryParse(prixUnitaireCtrl.text) ?? 0;
    return qte * pu;
  }

  void dispose() {
    quantiteCtrl.dispose();
    prixUnitaireCtrl.dispose();
  }
}

class _FormulaireAchatScreenState extends State<_FormulaireAchatScreen> {
  final AchatService _achatService = AchatService();
  final FournisseurService _fournisseurService = FournisseurService();

  final _formKey = GlobalKey<FormState>();
  final List<_LigneAchat> _lignes = [];
  List<dynamic> _fournisseurs = [];
  int? _idFournisseur;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _ajouterLigne(); // au moins une ligne au démarrage
    _chargerFournisseurs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().chargerProduits();
    });
  }

  @override
  void dispose() {
    for (final l in _lignes) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _chargerFournisseurs() async {
    try {
      final liste = await _fournisseurService.getAll();
      if (mounted) setState(() => _fournisseurs = liste);
    } catch (_) {}
  }

  void _ajouterLigne() {
    setState(() => _lignes.add(_LigneAchat()));
  }

  void _supprimerLigne(int index) {
    setState(() {
      _lignes[index].dispose();
      _lignes.removeAt(index);
    });
  }

  double get _totalGeneral {
    double total = 0;
    for (final l in _lignes) {
      total += l.sousTotal;
    }
    return total;
  }

  Future<void> _enregistrer() async {
    if (_idFournisseur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez un fournisseur'),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une ligne d\'achat'),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }
    for (final l in _lignes) {
      if (l.produit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sélectionnez un produit pour chaque ligne'),
            backgroundColor: AppColors.rouge,
          ),
        );
        return;
      }
      if (int.tryParse(l.quantiteCtrl.text) == null ||
          int.parse(l.quantiteCtrl.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les quantités doivent être des entiers positifs'),
            backgroundColor: AppColors.rouge,
          ),
        );
        return;
      }
    }

    setState(() => _enregistrement = true);

    try {
      await _achatService.creerAvecDetails(
        fournisseur: _idFournisseur!,
        details: [
          for (final l in _lignes)
            {
              'produit': l.produit!.idProduit,
              'quantite': int.parse(l.quantiteCtrl.text),
              'prix_unitaire': double.parse(l.prixUnitaireCtrl.text),
            },
        ],
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'),
              backgroundColor: AppColors.rouge),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produits = context.watch<ProduitProvider>().tousLesProduits;

    return Scaffold(
      appBar: AppHeader(title: 'Nouvel achat'),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // En-tête : choix du fournisseur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: DropdownButtonFormField<int>(
                initialValue: _idFournisseur,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                items: [
                  for (final f in _fournisseurs)
                    DropdownMenuItem(
                      value: f.idFournisseur as int,
                      child: Text(f.raisonSociale),
                    ),
                ],
                onChanged: (v) => setState(() => _idFournisseur = v),
              ),
            ),
            const SizedBox(height: 8),
            // Liste des lignes
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _lignes.length,
                itemBuilder: (context, i) {
                  final ligne = _lignes[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Ligne ${i + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.rouge, size: 20),
                                onPressed: () => _supprimerLigne(i),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<int>(
                            initialValue: ligne.produit?.idProduit,
                            decoration: const InputDecoration(
                              labelText: 'Produit',
                              isDense: true,
                            ),
                            items: [
                              for (final p in produits)
                                DropdownMenuItem(
                                  value: p.idProduit,
                                  child: Text(p.nom),
                                ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                ligne.produit = produits.firstWhere(
                                    (p) => p.idProduit == v);
                                // Pré-remplit le prix avec le prix d'achat par défaut.
                                ligne.prixUnitaireCtrl.text =
                                    ligne.produit!.prixAchat.toStringAsFixed(0);
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: ligne.quantiteCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantité',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: ligne.prixUnitaireCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Prix unitaire',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Sous-total : ${Formatters.montant(ligne.sousTotal)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.bleuFonce),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pied : total + bouton enregistrer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total général',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(Formatters.montant(_totalGeneral),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _ajouterLigne,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une ligne'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _enregistrement ? null : _enregistrer,
                            icon: _enregistrement
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check),
                            label: Text(_enregistrement
                                ? 'Enregistrement…'
                                : 'Enregistrer l\'achat'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
