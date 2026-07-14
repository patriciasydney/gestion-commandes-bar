import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/stock.dart';
import '../../providers/produit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../core/theme/theme_helpers.dart';
import '../../widgets/common/filter_choice_chip.dart';

/// Écran : Gestion des stocks — cahier des charges §10.6
///
/// Affiche l'état des stocks (quantité disponible + seuil d'alerte), les
/// alertes de rupture, l'historique des mouvements (entrées/sorties), et
/// permet d'enregistrer manuellement une entrée ou une sortie de stock.
class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  String _recherche = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().chargerStocks();
      context.read<StockProvider>().chargerMouvements();
      context.read<ProduitProvider>().chargerProduits();
    });
  }

  String _nomProduit(int idProduit) {
    final produit = context.read<ProduitProvider>().produitParId(idProduit);
    return produit == null ? 'Produit #$idProduit' : produit.nom;
  }

  /// Ouvre un dialogue permettant d'enregistrer une entrée ou une sortie
  /// de stock pour le produit passé en paramètre.
  Future<void> _ouvrirDialogueMouvement(Stock stock, String type) async {
    final quantiteCtrl = TextEditingController();
    final referenceCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final titre = type == 'entree' ? 'Entrée de stock' : 'Sortie de stock';
    final libellePeriode = type == 'entree'
        ? 'Quantité à ajouter au stock'
        : 'Quantité à retirer du stock';

    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              type == 'entree' ? Icons.add_circle : Icons.remove_circle,
              color: type == 'entree' ? AppColors.vert : AppColors.rouge,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(titre)),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nomProduit(stock.produit),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Stock actuel : ${stock.quantiteDisponible} unités',
                  style: const TextStyle(color: AppColors.texteClair, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantiteCtrl,
                  decoration: InputDecoration(
                    labelText: libellePeriode,
                    suffixText: 'unités',
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'La quantité est requise';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Entrez un entier positif';
                    if (type == 'sortie' && n > stock.quantiteDisponible) {
                      return 'Stock insuffisant (disponible : ${stock.quantiteDisponible})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: referenceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Référence (optionnel)',
                    hintText: 'Ex : BC-001, Inventaire, etc.',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final quantite = int.parse(quantiteCtrl.text.trim());
    final reference = referenceCtrl.text.trim().isEmpty ? null : referenceCtrl.text.trim();

    try {
      await context.read<StockProvider>().ajusterQuantite(
            idStock: stock.idStock,
            quantite: type == 'entree' ? quantite : -quantite,
            referenceOperation: reference,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'entree'
                  ? '+$quantite unités ajoutées au stock'
                  : '-$quantite unités retirées du stock',
            ),
            backgroundColor: type == 'entree' ? AppColors.vert : AppColors.bleuFonce,
          ),
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

  /// Dialogue pour ajuster le seuil d'alerte d'un produit.
  Future<void> _ouvrirDialogueSeuil(Stock stock) async {
    final seuilCtrl = TextEditingController(text: stock.seuilAlerte.toString());
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajuster le seuil d\'alerte'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nomProduit(stock.produit),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: seuilCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nouveau seuil d\'alerte',
                  suffixText: 'unités',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Le seuil est requis';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Entrez un entier valide';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La modification du seuil n\'est pas encore exposée par l\'API backend.',
          ),
          backgroundColor: AppColors.orange,
        ),
      );
    }
  }

  /// Dialogue affichant l'historique des mouvements d'un produit.
  Future<void> _ouvrirHistorique(Stock stock) async {
    final provider = context.read<StockProvider>();
    final mouvements = provider.mouvements
        .where((m) => m.produit == stock.produit)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Historique — ${_nomProduit(stock.produit)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: mouvements.isEmpty
              ? const Text('Aucun mouvement enregistré pour ce produit.',
                  style: TextStyle(color: AppColors.texteClair))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: mouvements.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = mouvements[i];
                    final estEntree = m.typeMouvement == 'entree';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        estEntree ? Icons.arrow_downward : Icons.arrow_upward,
                        color: estEntree ? AppColors.vert : AppColors.rouge,
                        size: 20,
                      ),
                      title: Text(
                        '${estEntree ? "+" : "-"}${m.quantite} unités'
                        '${m.referenceOperation != null ? " · ${m.referenceOperation}" : ""}',
                      ),
                      subtitle: Text(Formatters.dateHeure(m.dateMouvement)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des stocks'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/stocks'),
      body: Column(
        children: [
          // Bandeau résumé + alerte rupture
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: AppColors.bleuFonce,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'État global du stock',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatBandeau(
                      valeur: stockProvider.stocks.length.toString(),
                      label: 'Produits suivis',
                    ),
                    const SizedBox(width: 12),
                    _StatBandeau(
                      valeur: stockProvider.stocksEnAlerte.length.toString(),
                      label: 'En alerte',
                      couleurAccent: stockProvider.stocksEnAlerte.isEmpty
                          ? AppColors.vert
                          : AppColors.rouge,
                    ),
                    const SizedBox(width: 12),
                    _StatBandeau(
                      valeur: (stockProvider.stocks.length - stockProvider.stocksEnAlerte.length)
                          .toString(),
                      label: 'OK',
                      couleurAccent: AppColors.vert,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barre de recherche + filtre
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: themedSearchDecoration(
                      context,
                      hint: 'Rechercher un produit par son nom…',
                    ),
                    onChanged: (v) => setState(() => _recherche = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Alertes'),
                  selected: stockProvider.filtreAlerteSeulement,
                  onSelected: (v) => stockProvider.basculerFiltreAlerte(v),
                  selectedColor: AppColors.rouge,
                  backgroundColor: ThemeHelpers.fill(context),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: stockProvider.filtreAlerteSeulement
                        ? Colors.white
                        : ThemeHelpers.mutedText(context),
                    fontWeight: stockProvider.filtreAlerteSeulement
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: stockProvider.filtreAlerteSeulement
                        ? AppColors.rouge
                        : ThemeHelpers.border(context),
                  ),
                ),
              ],
            ),
          ),

          // Corps : liste des stocks
          Expanded(
            child: Builder(builder: (context) {
              if (stockProvider.chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (stockProvider.erreur != null) {
                return Center(
                  child: Text(stockProvider.erreur!,
                      style: const TextStyle(color: AppColors.rouge)),
                );
              }
              // Applique la recherche par nom (côté écran) en plus du
              // filtre "Alertes seulement" géré par le provider.
              final stocksFiltres = stockProvider.stocks.where((s) {
                if (_recherche.trim().isEmpty) return true;
                final nom = _nomProduit(s.produit).toLowerCase();
                return nom.contains(_recherche.toLowerCase());
              }).toList();
              if (stocksFiltres.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun stock trouvé',
                    style: ThemeHelpers.mutedTextStyle(context),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await stockProvider.chargerStocks();
                  await stockProvider.chargerMouvements();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: stocksFiltres.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final stock = stocksFiltres[i];
                    return _CarteStock(
                      nomProduit: _nomProduit(stock.produit),
                      stock: stock,
                      onEntree: () => _ouvrirDialogueMouvement(stock, 'entree'),
                      onSortie: () => _ouvrirDialogueMouvement(stock, 'sortie'),
                      onSeuil: () => _ouvrirDialogueSeuil(stock),
                      onHistorique: () => _ouvrirHistorique(stock),
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

// ---------------------------------------------------------------------------
// Sous-composants privés
// ---------------------------------------------------------------------------

class _StatBandeau extends StatelessWidget {
  final String valeur;
  final String label;
  final Color couleurAccent;

  const _StatBandeau({
    required this.valeur,
    required this.label,
    this.couleurAccent = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(valeur,
                style: TextStyle(
                  color: couleurAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CarteStock extends StatelessWidget {
  final String nomProduit;
  final Stock stock;
  final VoidCallback onEntree;
  final VoidCallback onSortie;
  final VoidCallback onSeuil;
  final VoidCallback onHistorique;

  const _CarteStock({
    required this.nomProduit,
    required this.stock,
    required this.onEntree,
    required this.onSortie,
    required this.onSeuil,
    required this.onHistorique,
  });

  /// Détermine le statut visuel d'une ligne de stock.
  /// - `rupture` : quantité = 0
  /// - `alerte`  : quantité <= seuil d'alerte (mais > 0)
  /// - `ok`      : quantité > seuil d'alerte
  String get _statut {
    if (stock.quantiteDisponible == 0) return 'rupture';
    if (stock.quantiteDisponible <= stock.seuilAlerte) return 'alerte';
    return 'ok';
  }

  Color get _couleurStatut {
    switch (_statut) {
      case 'rupture':
        return AppColors.rouge;
      case 'alerte':
        return AppColors.jaune;
      default:
        return AppColors.vert;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(nomProduit,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _couleurStatut.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statut == 'rupture'
                        ? 'RUPTURE'
                        : _statut == 'alerte'
                            ? 'ALERTE'
                            : 'OK',
                    style: TextStyle(
                      color: _couleurStatut,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _BlocQuantite(
                  valeur: stock.quantiteDisponible.toString(),
                  label: 'Disponible',
                ),
                const SizedBox(width: 12),
                _BlocQuantite(
                  valeur: stock.seuilAlerte.toString(),
                  label: 'Seuil',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Barre de progression visuelle stock / seuil
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (stock.quantiteDisponible /
                        (stock.seuilAlerte * 2 == 0 ? 1 : stock.seuilAlerte * 2))
                    .clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: ThemeHelpers.progressTrack(context),
                color: _couleurStatut,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onEntree,
                  icon: const Icon(Icons.add_circle, size: 18, color: AppColors.vert),
                  label: const Text('Entrée',
                      style: TextStyle(color: AppColors.vert)),
                ),
                TextButton.icon(
                  onPressed: onSortie,
                  icon: const Icon(Icons.remove_circle, size: 18, color: AppColors.rouge),
                  label: const Text('Sortie',
                      style: TextStyle(color: AppColors.rouge)),
                ),
                IconButton(
                  tooltip: 'Ajuster le seuil',
                  onPressed: onSeuil,
                  icon: const Icon(Icons.tune, size: 18, color: AppColors.texteClair),
                ),
                IconButton(
                  tooltip: 'Historique',
                  onPressed: onHistorique,
                  icon: const Icon(Icons.history, size: 18, color: AppColors.texteClair),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlocQuantite extends StatelessWidget {
  final String valeur;
  final String label;

  const _BlocQuantite({required this.valeur, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(valeur,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: AppColors.texteClair, fontSize: 11)),
      ],
    );
  }
}
