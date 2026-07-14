import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/client.dart';
import '../../models/caisse.dart';
import '../../providers/auth_provider.dart';
import '../../providers/caisse_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/produit_provider.dart';
import '../../services/client_service.dart';
import '../../services/vente_service.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/pos/cart_item_tile.dart';
import '../../widgets/pos/product_card.dart';

/// Écran : Point de vente — cahier des charges §10.4
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final ClientService _clientService = ClientService();
  final VenteService _venteService = VenteService();

  List<Client> _clients = [];
  Client? _clientSelectionne;
  bool _encaissementEnCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().chargerProduits();
      final auth = context.read<AuthProvider>();
      context.read<CaisseProvider>().chargerCaisseActive(
            idUtilisateur: auth.utilisateur?.id,
          );
      _chargerClients();
    });
  }

  Future<void> _chargerClients() async {
    try {
      final clients = await _clientService.getAll();
      if (mounted) setState(() => _clients = clients);
    } catch (_) {}
  }

  Future<void> _ouvrirCaisse() async {
    final montantCtrl = TextEditingController(text: '0');
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ouvrir la caisse'),
        content: TextField(
          controller: montantCtrl,
          decoration: const InputDecoration(
            labelText: 'Montant initial (FCFA)',
            suffixText: 'FCFA',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ouvrir')),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final montant = double.tryParse(montantCtrl.text.trim()) ?? 0;
    try {
      await context.read<CaisseProvider>().ouvrir(montantInitial: montant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caisse ouverte'), backgroundColor: AppColors.vert),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.rouge),
        );
      }
    }
  }

  Future<void> _ouvrirPaiement() async {
    final caisseProvider = context.read<CaisseProvider>();
    if (!caisseProvider.aCaisseOuverte) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ouvrez une caisse avant d\'encaisser une vente'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    final panier = context.read<PanierProvider>();
    if (panier.articles.isEmpty) return;

    final modePaiement = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FeuillePaiement(total: panier.total),
    );

    if (modePaiement == null || !mounted) return;

    setState(() => _encaissementEnCours = true);

    try {
      final lignes = panier.articles
          .map((a) => LigneVente(
                produit: a.produit.idProduit,
                quantite: a.quantite,
                prixUnitaire: a.produit.prixVente,
              ))
          .toList();

      final vente = await _venteService.creerVenteComplete(
        lignes: lignes,
        remise: panier.remise,
        caisse: caisseProvider.caisseOuverte!.idCaisse,
        client: _clientSelectionne?.idClient,
        modePaiement: modePaiement,
      );

      panier.vider();
      setState(() => _clientSelectionne = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vente ${vente.reference} enregistrée — ${Formatters.montant(vente.montantTotal)}',
          ),
          backgroundColor: AppColors.vert,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.rouge,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _encaissementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caisseProvider = context.watch<CaisseProvider>();

    return Scaffold(
      appBar: AppHeader(title: 'Point de vente'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/pos'),
      body: Column(
        children: [
          _BandeauCaisse(
            caisse: caisseProvider.caisseOuverte,
            chargement: caisseProvider.chargement,
            onOuvrir: _ouvrirCaisse,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final large = constraints.maxWidth > 800;
                final catalogue = _Catalogue(
                  clients: _clients,
                  clientSelectionne: _clientSelectionne,
                  onClientChanged: (c) => setState(() => _clientSelectionne = c),
                );
                final panier = _PanierPanel(
                  encaissementEnCours: _encaissementEnCours,
                  caisseOuverte: caisseProvider.aCaisseOuverte,
                  onEncaisser: _ouvrirPaiement,
                );

                if (large) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: catalogue),
                      const VerticalDivider(width: 1),
                      Expanded(flex: 2, child: panier),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: catalogue),
                    const Divider(height: 1),
                    SizedBox(height: 320, child: panier),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BandeauCaisse extends StatelessWidget {
  const _BandeauCaisse({
    required this.caisse,
    required this.chargement,
    required this.onOuvrir,
  });

  final Caisse? caisse;
  final bool chargement;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    if (chargement) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    final ouverte = caisse?.estOuverte == true;
    return Material(
      color: ouverte ? AppColors.vert.withValues(alpha: 0.12) : AppColors.orange.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              ouverte ? Icons.point_of_sale : Icons.lock_outline,
              color: ouverte ? AppColors.vert : AppColors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ouverte
                    ? 'Caisse #${caisse!.idCaisse} ouverte — fond ${Formatters.montant(caisse!.montantInitial)}'
                    : 'Aucune caisse ouverte — ouvrez la caisse pour vendre',
                style: TextStyle(
                  fontSize: 13,
                  color: ouverte ? AppColors.vert : AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!ouverte)
              TextButton(onPressed: onOuvrir, child: const Text('Ouvrir')),
          ],
        ),
      ),
    );
  }
}

/// Recherche + grille du catalogue produits, et sélecteur de client.
class _Catalogue extends StatelessWidget {
  final List<Client> clients;
  final Client? clientSelectionne;
  final ValueChanged<Client?> onClientChanged;

  const _Catalogue({
    required this.clients,
    required this.clientSelectionne,
    required this.onClientChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProduitProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit (nom ou code-barres)…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: provider.rechercher,
              ),
              const SizedBox(height: 8),
              if (clients.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20, color: AppColors.texteClair),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Client?>(
                          isExpanded: true,
                          hint: const Text('Client de passage (optionnel)'),
                          value: clientSelectionne,
                          items: [
                            const DropdownMenuItem<Client?>(
                              value: null,
                              child: Text('Client de passage'),
                            ),
                            ...clients.map(
                              (c) => DropdownMenuItem<Client?>(
                                value: c,
                                child: Text('${c.nom} ${c.prenom ?? ''}'.trim()),
                              ),
                            ),
                          ],
                          onChanged: onClientChanged,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            if (provider.chargement) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.erreur != null) {
              return Center(
                child: Text(provider.erreur!, style: const TextStyle(color: AppColors.rouge)),
              );
            }
            if (provider.produits.isEmpty) {
              return const Center(
                child: Text('Aucun produit trouvé', style: TextStyle(color: AppColors.texteClair)),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: provider.produits.length,
              itemBuilder: (context, i) {
                final produit = provider.produits[i];
                return ProductCard(
                  produit: produit,
                  onTap: () => context.read<PanierProvider>().ajouterProduit(produit),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

/// Panneau du panier en cours, avec total et bouton d'encaissement.
class _PanierPanel extends StatelessWidget {
  final bool encaissementEnCours;
  final bool caisseOuverte;
  final VoidCallback onEncaisser;

  const _PanierPanel({
    required this.encaissementEnCours,
    required this.caisseOuverte,
    required this.onEncaisser,
  });

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Text('Panier (${panier.articles.length})', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (panier.articles.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => panier.vider(),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.rouge),
                    label: const Text('Vider', style: TextStyle(color: AppColors.rouge)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: panier.articles.isEmpty
                ? const Center(
                    child: Text(
                      'Touchez un produit pour l\'ajouter',
                      style: TextStyle(color: AppColors.texteClair),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: panier.articles.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final article = panier.articles[i];
                      return CartItemTile(
                        article: article,
                        onQuantiteChanged: (q) =>
                            panier.modifierQuantite(article.produit.idProduit, q),
                        onSupprimer: () => panier.retirerArticle(article.produit.idProduit),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      Formatters.montant(panier.total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (panier.articles.isEmpty || encaissementEnCours || !caisseOuverte)
                        ? null
                        : onEncaisser,
                    icon: encaissementEnCours
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.point_of_sale),
                    label: Text(
                      !caisseOuverte
                          ? 'Caisse fermée'
                          : encaissementEnCours
                              ? 'Enregistrement…'
                              : 'Encaisser',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feuille de sélection du mode de paiement — valeurs `Paiement.MODE_*` backend.
class _FeuillePaiement extends StatelessWidget {
  final double total;

  const _FeuillePaiement({required this.total});

  static const _modes = [
    (id: 'especes', label: 'Espèces', icon: Icons.payments_outlined),
    (id: 'mobile_money', label: 'Mobile Money', icon: Icons.phone_iphone),
    (id: 'carte_bancaire', label: 'Carte bancaire', icon: Icons.credit_card),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encaisser', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Montant à payer : ${Formatters.montant(total)}',
              style: const TextStyle(color: AppColors.texteClair),
            ),
            const SizedBox(height: 20),
            for (final mode in _modes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(mode.id),
                    icon: Icon(mode.icon, color: AppColors.bleuFonce),
                    label: Text(mode.label),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
