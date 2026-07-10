import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/rapport.dart';
import '../../services/rapport_service.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';

/// Écran : Rapports et statistiques — aligné sur `/reports/*` (DRF).
class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  final RapportService _service = RapportService();

  RapportComplet? _rapport;
  bool _chargement = false;
  String? _erreur;
  String _periode = 'jour';

  static const _periodes = [
    ('jour', 'Jour', Icons.today),
    ('semaine', 'Semaine', Icons.calendar_view_week),
    ('mois', 'Mois', Icons.calendar_month),
    ('annee', 'Année', Icons.date_range),
  ];

  @override
  void initState() {
    super.initState();
    _chargerRapport();
  }

  Future<void> _chargerRapport() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      _rapport = await _service.genererRapport(periode: _periode);
    } catch (e) {
      _erreur = e.toString();
      _rapport = null;
    }
    if (mounted) setState(() => _chargement = false);
  }

  void _changerPeriode(String p) {
    if (p == _periode) return;
    setState(() => _periode = p);
    _chargerRapport();
  }

  Future<void> _exporterCsv() async {
    final rapport = _rapport;
    if (rapport == null) return;

    final lignes = <String>[
      'Rapport POS Débits de Boissons',
      'Période;${rapport.libellePeriode}',
      'Généré le;${Formatters.dateHeure(DateTime.now())}',
      '',
      'Indicateur;Valeur',
      "Chiffre d'affaires;${Formatters.montant(rapport.chiffreAffaires)}",
      'Nombre de ventes;${rapport.nombreVentes}',
      'Dépenses opérationnelles;${Formatters.montant(rapport.depensesTotal)}',
      'Achats fournisseurs;${Formatters.montant(rapport.achatsTotal)}',
      'Total sorties;${Formatters.montant(rapport.sortiesTotal)}',
      'Bénéfice net;${Formatters.montant(rapport.beneficeNet)}',
      'Panier moyen;${Formatters.montant(rapport.panierMoyen)}',
      '',
      'Top produits',
      "Produit;Quantité vendue;Chiffre d'affaires",
      for (final p in rapport.topProduits)
        '${p.nom};${p.quantiteTotale};${Formatters.montant(p.chiffreAffaires)}',
      '',
      'Dépenses opérationnelles par catégorie',
      'Catégorie;Montant',
      for (final d in rapport.depensesParCategorie)
        '${d.categorie};${Formatters.montant(d.total)}',
      '',
      'Achats fournisseurs',
      'Fournisseur;Nombre achats;Montant',
      for (final a in rapport.achatsParFournisseur)
        '${a.fournisseur};${a.nombreAchats};${Formatters.montant(a.total)}',
    ];

    await Clipboard.setData(ClipboardData(text: lignes.join('\n')));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport CSV copié dans le presse-papiers'),
          backgroundColor: AppColors.vert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Rapports et statistiques',
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter (CSV)',
            onPressed: _rapport == null ? null : _exporterCsv,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/rapports'),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (valeur, label, icone) in _periodes)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(
                          icone,
                          size: 16,
                          color: _periode == valeur ? Colors.white : AppColors.texteClair,
                        ),
                        label: Text(label),
                        selected: _periode == valeur,
                        onSelected: (_) => _changerPeriode(valeur),
                        selectedColor: AppColors.bleuFonce,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: _periode == valeur ? Colors.white : AppColors.texteClair,
                          fontWeight: _periode == valeur ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: _periode == valeur ? AppColors.bleuFonce : AppColors.bordure,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (_chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_erreur != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _erreur!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.rouge),
                    ),
                  ),
                );
              }
              final rapport = _rapport;
              if (rapport == null) return const SizedBox.shrink();

              return RefreshIndicator(
                onRefresh: _chargerRapport,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rapport.libellePeriode,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Synthèse ventes, achats fournisseurs et dépenses opérationnelles',
                        style: TextStyle(color: AppColors.texteClair, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _CarteStat(
                            titre: "Chiffre d'affaires",
                            valeur: Formatters.montant(rapport.chiffreAffaires),
                            icone: Icons.payments,
                            couleur: AppColors.vert,
                          ),
                          _CarteStat(
                            titre: 'Nombre de ventes',
                            valeur: rapport.nombreVentes.toString(),
                            icone: Icons.receipt_long,
                            couleur: AppColors.bleuFonce,
                          ),
                          _CarteStat(
                            titre: 'Dépenses opérationnelles',
                            valeur: Formatters.montant(rapport.depensesTotal),
                            icone: Icons.receipt_outlined,
                            couleur: AppColors.rouge,
                          ),
                          _CarteStat(
                            titre: 'Achats fournisseurs',
                            valeur: Formatters.montant(rapport.achatsTotal),
                            icone: Icons.local_shipping_outlined,
                            couleur: AppColors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CarteStatLarge(
                        titre: 'Bénéfice net (CA − dépenses − achats)',
                        valeur: Formatters.montant(rapport.beneficeNet),
                        icone: Icons.savings,
                        couleur: rapport.beneficeNet >= 0 ? AppColors.vert : AppColors.rouge,
                      ),
                      const SizedBox(height: 12),
                      _CarteStatLarge(
                        titre: 'Panier moyen',
                        valeur: Formatters.montant(rapport.panierMoyen),
                        icone: Icons.shopping_basket,
                        couleur: AppColors.jaune,
                      ),
                      const SizedBox(height: 24),
                      _TitreSection('Top produits vendus'),
                      const SizedBox(height: 8),
                      _ListeTopProduits(rapport.topProduits),
                      const SizedBox(height: 24),
                      _TitreSection('Achats fournisseurs'),
                      if (rapport.nombreAchats > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${rapport.nombreAchats} achat(s) — ${Formatters.montant(rapport.achatsTotal)}',
                            style: const TextStyle(color: AppColors.texteClair, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 4),
                      _ListeAchatsFournisseur(rapport.achatsParFournisseur),
                      const SizedBox(height: 24),
                      _TitreSection('Dépenses opérationnelles'),
                      const SizedBox(height: 8),
                      _ListeDepensesCategorie(rapport.depensesParCategorie),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  final String texte;
  const _TitreSection(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(texte, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _CarteStat extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _CarteStat({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icone, color: couleur, size: 22),
            const SizedBox(height: 4),
            Text(titre, style: const TextStyle(color: AppColors.texteClair, fontSize: 12)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valeur,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteStatLarge extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _CarteStatLarge({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: couleur.withValues(alpha: 0.15),
              child: Icon(icone, color: couleur),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: const TextStyle(color: AppColors.texteClair, fontSize: 12)),
                  Text(
                    valeur,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeTopProduits extends StatelessWidget {
  final List<TopProduitVendu> produits;
  const _ListeTopProduits(this.produits);

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return const Text(
        'Aucune vente sur la période.',
        style: TextStyle(color: AppColors.texteClair),
      );
    }
    final maxQte = produits.first.quantiteTotale.toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < produits.length; i++) ...[
            _LigneTopProduit(
              rang: i + 1,
              nom: produits[i].nom,
              quantite: produits[i].quantiteTotale,
              ca: produits[i].chiffreAffaires,
              ratio: produits[i].quantiteTotale / maxQte,
            ),
            if (i < produits.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _LigneTopProduit extends StatelessWidget {
  final int rang;
  final String nom;
  final int quantite;
  final double ca;
  final double ratio;

  const _LigneTopProduit({
    required this.rang,
    required this.nom,
    required this.quantite,
    required this.ca,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '#$rang',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.bleuFonce),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.fond,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$quantite u.', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                Formatters.montant(ca),
                style: const TextStyle(color: AppColors.texteClair, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListeDepensesCategorie extends StatelessWidget {
  final List<DepenseParCategorie> categories;
  const _ListeDepensesCategorie(this.categories);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text(
        'Aucune dépense opérationnelle sur la période.',
        style: TextStyle(color: AppColors.texteClair),
      );
    }
    final maxMontant = categories.map((c) => c.total).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      c.categorie,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (c.total / maxMontant).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.fond,
                        color: AppColors.rouge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: Text(
                      Formatters.montant(c.total),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

class _ListeAchatsFournisseur extends StatelessWidget {
  final List<AchatParFournisseur> fournisseurs;
  const _ListeAchatsFournisseur(this.fournisseurs);

  @override
  Widget build(BuildContext context) {
    if (fournisseurs.isEmpty) {
      return const Text(
        'Aucun achat fournisseur sur la période.',
        style: TextStyle(color: AppColors.texteClair),
      );
    }
    final maxMontant = fournisseurs.map((f) => f.total).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final f in fournisseurs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.fournisseur,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${f.nombreAchats} achat(s)',
                          style: const TextStyle(color: AppColors.texteClair, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (f.total / maxMontant).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.fond,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: Text(
                      Formatters.montant(f.total),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
