import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/client.dart';
import '../../models/caisse.dart';
import '../../models/vente.dart';
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
      final user = auth.utilisateur;
      // Le serveur rattache ses commandes à la caisse déjà ouverte par le caissier.
      final modeServeur = RolePermissions.canEnvoyerCommande(user);
      context.read<CaisseProvider>().chargerCaisseActive(
            idUtilisateur: modeServeur ? null : user?.id,
          );
      _chargerClients();
      _ouvrirPanierSiCommandeChargee();
    });
  }

  Future<void> _ouvrirPanierSiCommandeChargee() async {
    final panier = context.read<PanierProvider>();
    if (!panier.consommerDemandeOuverturePanier()) return;
    if (!mounted) return;
    // Mobile : ouvrir directement la feuille panier pour voir les produits.
    if (MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.tablet) {
      await _ouvrirFeuillePanier();
    }
  }

  Future<void> _chargerClients() async {
    try {
      final clients = await _clientService.getAll();
      if (mounted) setState(() => _clients = clients);
    } catch (_) {}
  }

  Future<void> _ouvrirCaisse() async {
    final utilisateur = context.read<AuthProvider>().utilisateur;
    if (!RolePermissions.canOperateCaisse(utilisateur)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seul un caissier ou un administrateur peut ouvrir la caisse.',
          ),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }

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
    final utilisateur = context.read<AuthProvider>().utilisateur;
    if (RolePermissions.canEnvoyerCommande(utilisateur)) {
      await _envoyerCommande();
      return;
    }

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
      final Vente vente;
      if (panier.aCommandeEnAttente) {
        vente = await _venteService.encaisserCommande(
          idVente: panier.commandeEnAttenteId!,
          modePaiement: modePaiement,
        );
      } else {
        final lignes = panier.articles
            .map((a) => LigneVente(
                  produit: a.produit.idProduit,
                  quantite: a.quantite,
                  prixUnitaire: a.produit.prixVente,
                ))
            .toList();

        vente = await _venteService.creerVenteComplete(
          lignes: lignes,
          remise: panier.remise,
          caisse: caisseProvider.caisseOuverte!.idCaisse,
          client: _clientSelectionne?.idClient,
          modePaiement: modePaiement,
        );
      }

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

  Future<void> _envoyerCommande() async {
    final caisseProvider = context.read<CaisseProvider>();
    if (!caisseProvider.aCaisseOuverte) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune caisse ouverte. Le caissier doit ouvrir la caisse avant les commandes.',
          ),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (_clientSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sélectionnez le client qui passe la commande (obligatoire).',
          ),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    final panier = context.read<PanierProvider>();
    if (panier.articles.isEmpty) return;

    setState(() => _encaissementEnCours = true);
    try {
      final lignes = panier.articles
          .map((a) => LigneVente(
                produit: a.produit.idProduit,
                quantite: a.quantite,
                prixUnitaire: a.produit.prixVente,
              ))
          .toList();

      final vente = await _venteService.creerCommandeEnAttente(
        lignes: lignes,
        remise: panier.remise,
        caisse: caisseProvider.caisseOuverte!.idCaisse,
        client: _clientSelectionne!.idClient,
      );

      panier.vider();
      setState(() => _clientSelectionne = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Commande ${vente.reference}'
            '${vente.clientNom != null ? ' — ${vente.clientNom}' : ''} '
            'envoyée au caissier — ${Formatters.montant(vente.montantTotal)}',
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

  Future<void> _creerClientRapide() async {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom *'),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            TextField(
              controller: prenomCtrl,
              decoration: const InputDecoration(labelText: 'Prénom'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: telCtrl,
              decoration: const InputDecoration(labelText: 'Téléphone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final cree = await _clientService.create(
        Client(
          idClient: 0,
          nom: nomCtrl.text.trim(),
          prenom: prenomCtrl.text.trim().isEmpty ? null : prenomCtrl.text.trim(),
          telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
          actif: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _clients = [..._clients, cree]
          ..sort((a, b) => a.nomComplet.compareTo(b.nomComplet));
        _clientSelectionne = cree;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client ${cree.nomComplet} sélectionné'),
          backgroundColor: AppColors.vert,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.rouge),
      );
    }
  }

  Future<void> _ouvrirFeuillePanier() async {
    final caisseOuverte = context.read<CaisseProvider>().aCaisseOuverte;
    final utilisateur = context.read<AuthProvider>().utilisateur;
    final modeServeur = RolePermissions.canEnvoyerCommande(utilisateur);
    final modeCommande = context.read<PanierProvider>().aCommandeEnAttente;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final hauteur = MediaQuery.sizeOf(ctx).height;
        return SizedBox(
          height: (hauteur * 0.78).clamp(360.0, 720.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: _PanierPanel(
                  encaissementEnCours: _encaissementEnCours,
                  caisseOuverte: caisseOuverte,
                  modeServeur: modeServeur,
                  modeCommande: modeCommande,
                  onEncaisser: () {
                    Navigator.of(ctx).pop();
                    _ouvrirPaiement();
                  },
                  compact: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final caisseProvider = context.watch<CaisseProvider>();
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final peutOpererCaisse = RolePermissions.canOperateCaisse(utilisateur);
    final modeServeur = RolePermissions.canEnvoyerCommande(utilisateur);
    final panier = context.watch<PanierProvider>();
    final modeCommande = panier.aCommandeEnAttente;

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
            peutOperer: peutOpererCaisse,
            modeServeur: modeServeur,
          ),
          if (modeCommande)
            Material(
              color: AppColors.orange.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [
                          'Commande ${panier.commandeReference ?? ''}',
                          if ((panier.commandeClientNom ?? '').isNotEmpty)
                            panier.commandeClientNom!,
                          'produits dans le panier',
                        ].join(' — '),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => panier.vider(),
                      child: const Text('Quitter'),
                    ),
                  ],
                ),
              ),
            )
          else if (modeServeur)
            Material(
              color: AppColors.bleuFonce.withValues(alpha: 0.12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.room_service_outlined, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode serveur : les commandes sont envoyées au caissier (sans encaissement).',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Side-by-side seulement tablette large / desktop.
                final large =
                    constraints.maxWidth >= ResponsiveBreakpoints.tablet;
                final catalogue = IgnorePointer(
                  ignoring: modeCommande,
                  child: Opacity(
                    opacity: modeCommande ? 0.45 : 1,
                    child: _Catalogue(
                      clients: _clients,
                      clientSelectionne: _clientSelectionne,
                      clientObligatoire: modeServeur,
                      onClientChanged: (c) =>
                          setState(() => _clientSelectionne = c),
                      onNouveauClient: _creerClientRapide,
                    ),
                  ),
                );

                if (large) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: catalogue),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 2,
                        child: _PanierPanel(
                          encaissementEnCours: _encaissementEnCours,
                          caisseOuverte: caisseProvider.aCaisseOuverte,
                          modeServeur: modeServeur,
                          modeCommande: modeCommande,
                          onEncaisser: _ouvrirPaiement,
                        ),
                      ),
                    ],
                  );
                }

                // Mobile / tablette : catalogue 100 % + barre (pas de panneau
                // qui vole la moitié de l'écran).
                return catalogue;
              },
            ),
          ),
          if (MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.tablet)
            _PanierBarreMobile(
              nombreArticles: panier.articles.fold<int>(
                0,
                (somme, a) => somme + a.quantite,
              ),
              total: panier.total,
              caisseOuverte: caisseProvider.aCaisseOuverte,
              encaissementEnCours: _encaissementEnCours,
              modeServeur: modeServeur,
              modeCommande: modeCommande,
              onOuvrirPanier: _ouvrirFeuillePanier,
              onEncaisser: _ouvrirPaiement,
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
    required this.peutOperer,
    this.modeServeur = false,
  });

  final Caisse? caisse;
  final bool chargement;
  final VoidCallback onOuvrir;
  final bool peutOperer;
  final bool modeServeur;

  @override
  Widget build(BuildContext context) {
    if (chargement) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    final ouverte = caisse?.estOuverte == true;
    final messageFerme = modeServeur
        ? 'Aucune caisse ouverte — le caissier doit ouvrir la caisse pour recevoir les commandes'
        : peutOperer
            ? 'Aucune caisse ouverte — ouvrez la caisse pour vendre'
            : 'Aucune caisse ouverte — réservé au caissier / administrateur';
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
                    : messageFerme,
                style: TextStyle(
                  fontSize: 13,
                  color: ouverte ? AppColors.vert : AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!ouverte && peutOperer)
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
  final bool clientObligatoire;
  final VoidCallback onNouveauClient;

  const _Catalogue({
    required this.clients,
    required this.clientSelectionne,
    required this.onClientChanged,
    this.clientObligatoire = false,
    required this.onNouveauClient,
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
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20,
                    color: clientObligatoire && clientSelectionne == null
                        ? AppColors.orange
                        : AppColors.texteClair,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Client?>(
                        isExpanded: true,
                        hint: Text(
                          clientObligatoire
                              ? 'Client (obligatoire)'
                              : 'Client de passage (optionnel)',
                        ),
                        value: clientSelectionne,
                        items: [
                          if (!clientObligatoire)
                            const DropdownMenuItem<Client?>(
                              value: null,
                              child: Text('Client de passage'),
                            ),
                          ...clients.map(
                            (c) => DropdownMenuItem<Client?>(
                              value: c,
                              child: Text(c.nomComplet),
                            ),
                          ),
                        ],
                        onChanged: onClientChanged,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Nouveau client',
                    onPressed: onNouveauClient,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
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
  final bool compact;
  final bool modeServeur;
  final bool modeCommande;

  const _PanierPanel({
    required this.encaissementEnCours,
    required this.caisseOuverte,
    required this.onEncaisser,
    this.compact = false,
    this.modeServeur = false,
    this.modeCommande = false,
  });

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final labelAction = !caisseOuverte
        ? (modeServeur ? 'Caisse requise' : 'Caisse fermée')
        : encaissementEnCours
            ? (modeServeur ? 'Envoi…' : 'Enregistrement…')
            : (modeServeur
                ? 'Envoyer au caissier'
                : (modeCommande ? 'Encaisser la commande' : 'Encaisser'));

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, compact ? 8 : 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    modeCommande
                        ? [
                            'Commande',
                            if ((panier.commandeClientNom ?? '').isNotEmpty)
                              panier.commandeClientNom!,
                            '(${panier.articles.length})',
                          ].join(' ')
                        : 'Panier (${panier.articles.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (panier.articles.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => panier.vider(),
                    icon: Icon(
                      modeCommande
                          ? Icons.close
                          : Icons.delete_sweep_outlined,
                      size: 18,
                      color: AppColors.rouge,
                    ),
                    label: Text(
                      modeCommande ? 'Quitter' : 'Vider',
                      style: const TextStyle(color: AppColors.rouge),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: panier.articles.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Touchez un produit pour l\'ajouter',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.texteClair),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: panier.articles.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final article = panier.articles[i];
                      return CartItemTile(
                        article: article,
                        dense: compact,
                        lectureSeule: modeCommande,
                        onQuantiteChanged: (q) => panier.modifierQuantite(
                          article.produit.idProduit,
                          q,
                        ),
                        onSupprimer: () =>
                            panier.retirerArticle(article.produit.idProduit),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            Formatters.montant(panier.total),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (panier.articles.isEmpty ||
                              encaissementEnCours ||
                              !caisseOuverte)
                          ? null
                          : onEncaisser,
                      icon: encaissementEnCours
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(modeServeur
                              ? Icons.send_outlined
                              : Icons.point_of_sale),
                      label: Text(labelAction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre compacte mobile : laisse le catalogue plein écran.
class _PanierBarreMobile extends StatelessWidget {
  const _PanierBarreMobile({
    required this.nombreArticles,
    required this.total,
    required this.caisseOuverte,
    required this.encaissementEnCours,
    required this.onOuvrirPanier,
    required this.onEncaisser,
    this.modeServeur = false,
    this.modeCommande = false,
  });

  final int nombreArticles;
  final double total;
  final bool caisseOuverte;
  final bool encaissementEnCours;
  final VoidCallback onOuvrirPanier;
  final VoidCallback onEncaisser;
  final bool modeServeur;
  final bool modeCommande;

  @override
  Widget build(BuildContext context) {
    final vide = nombreArticles == 0;
    final labelCourt = !caisseOuverte
        ? (modeServeur ? 'Caisse?' : 'Caisse')
        : encaissementEnCours
            ? '…'
            : (modeServeur
                ? 'Au caissier'
                : (modeCommande ? 'Encaisser' : 'Encaisser'));

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onOuvrirPanier,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Badge(
                          isLabelVisible: !vide,
                          label: Text('$nombreArticles'),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vide ? 'Panier vide' : 'Voir le panier',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                Formatters.montant(total),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_up),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onPressed: (vide || encaissementEnCours || !caisseOuverte)
                    ? null
                    : onEncaisser,
                child: Text(labelCourt),
              ),
            ],
          ),
        ),
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
