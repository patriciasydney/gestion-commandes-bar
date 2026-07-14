import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/depense.dart';
import '../../services/depense_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../core/theme/theme_helpers.dart';
import '../../widgets/common/filter_choice_chip.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Gestion des dépenses — cahier des charges §10.6 (volet dépenses courantes)
///
/// Liste les dépenses enregistrées et permet d'en ajouter une nouvelle via
/// un formulaire modal (libellé, catégorie, montant, date).
/// Les dépenses sont indépendantes du stock : elles servent à tracer les
/// sorties d'argent qui ne sont pas liées à un achat de marchandise.
class DepensesScreen extends StatefulWidget {
  const DepensesScreen({super.key});

  @override
  State<DepensesScreen> createState() => _DepensesScreenState();
}

class _DepensesScreenState extends State<DepensesScreen> {
  final DepenseService _service = DepenseService();

  List<Depense> _depenses = [];
  bool _chargement = false;
  String? _erreur;
  String _filtreCategorie = 'Toutes';

  static const List<String> _categories = [
    'Toutes',
    'Charges fixes',
    'Carburant',
    'Fournitures',
    'Salaires',
    'Maintenance',
    'Marketing',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _chargerDepenses();
  }

  Future<void> _chargerDepenses() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      _depenses = await _service.getAll();
    } catch (_) {
      _erreur = "Impossible de charger les dépenses (backend non branché ?)";
    }
    if (mounted) setState(() => _chargement = false);
  }

  List<Depense> get _depensesFiltrees {
    if (_filtreCategorie == 'Toutes') return _depenses;
    return _depenses.where((d) => d.categorie == _filtreCategorie).toList();
  }

  double get _totalFiltre {
    double total = 0;
    for (final d in _depensesFiltrees) {
      total += d.montant;
    }
    return total;
  }

  Future<void> _ouvrirFormulaire({Depense? existante}) async {
    final resultat = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FormulaireDepense(depenseExistante: existante),
    );

    if (resultat == true && mounted) _chargerDepenses();
  }

  Future<void> _supprimer(Depense d) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette dépense ?'),
        content: Text('« ${d.libelle} » (${Formatters.montant(d.montant)}) sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.rouge)),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    try {
      await _service.delete(d.idDepense);
      _depenses.removeWhere((x) => x.idDepense == d.idDepense);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dépense supprimée'),
              backgroundColor: AppColors.vert),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'),
              backgroundColor: AppColors.rouge),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'Gestion des dépenses'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/depenses'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle dépense'),
        backgroundColor: AppColors.orange,
      ),
      body: Column(
        children: [
          // Bandeau résumé (total filtré)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.bleuFonce,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total affiché',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                Text(Formatters.montant(_totalFiltre),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Filtre catégorie
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChoiceChip(
                      label: c,
                      selected: _filtreCategorie == c,
                      onSelected: () => setState(() => _filtreCategorie = c),
                    ),
                  ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: Builder(builder: (context) {
              if (_chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_erreur != null) {
                return Center(child: Text(_erreur!,
                    style: const TextStyle(color: AppColors.rouge)));
              }
              if (_depensesFiltrees.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune dépense à afficher',
                    style: ThemeHelpers.mutedTextStyle(context),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _chargerDepenses,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: _depensesFiltrees.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = _depensesFiltrees[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.rouge,
                          child: Icon(Icons.trending_down,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(d.libelle,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(d.categorie,
                                style: const TextStyle(
                                    color: AppColors.bleuFonce, fontSize: 12)),
                            Text(Formatters.date(d.dateDepense),
                                style: const TextStyle(
                                    color: AppColors.texteClair, fontSize: 11)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Formatters.montant(d.montant),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.rouge)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.rouge, size: 20),
                              onPressed: () => _supprimer(d),
                            ),
                          ],
                        ),
                        onTap: () => _ouvrirFormulaire(existante: d),
                      ),
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
// Formulaire d'ajout / modification d'une dépense (bottom sheet)
// ---------------------------------------------------------------------------

class _FormulaireDepense extends StatefulWidget {
  final Depense? depenseExistante;

  const _FormulaireDepense({this.depenseExistante});

  @override
  State<_FormulaireDepense> createState() => _FormulaireDepenseState();
}

class _FormulaireDepenseState extends State<_FormulaireDepense> {
  final DepenseService _service = DepenseService();
  final _formKey = GlobalKey<FormState>();

  final _libelleCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  late DateTime _date;
  String _categorie = 'Charges fixes';
  bool _enregistrement = false;

  static const List<String> _categories = [
    'Charges fixes',
    'Carburant',
    'Fournitures',
    'Salaires',
    'Maintenance',
    'Marketing',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.depenseExistante != null) {
      final d = widget.depenseExistante!;
      _libelleCtrl.text = d.libelle;
      _montantCtrl.text = d.montant.toStringAsFixed(0);
      _date = d.dateDepense;
      _categorie = d.categorie;
    } else {
      _date = DateTime.now();
    }
  }

  Future<void> _choisirDate() async {
    final choix = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (choix != null) setState(() => _date = choix);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enregistrement = true);

    final depense = Depense(
      idDepense: widget.depenseExistante?.idDepense ?? 0,
      libelle: _libelleCtrl.text.trim(),
      categorie: _categorie,
      montant: double.parse(_montantCtrl.text.trim()),
      dateDepense: _date,
    );

    try {
      if (widget.depenseExistante != null) {
        await _service.update(depense.idDepense, depense);
      } else {
        await _service.create(depense);
      }
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
    final modification = widget.depenseExistante != null;
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.texteClair.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(modification ? 'Modifier la dépense' : 'Nouvelle dépense',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _libelleCtrl,
                decoration: const InputDecoration(labelText: 'Libellé'),
                validator: (v) =>
                    Validators.requis(v, champ: 'Le libellé'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: [
                  for (final c in _categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _categorie = v ?? _categorie),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _montantCtrl,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  prefixIcon: Icon(Icons.payments),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.nombrePositif(v, champ: 'Le montant'),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _choisirDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(Formatters.date(_date)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enregistrement ? null : _enregistrer,
                child: _enregistrement
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(modification
                        ? 'Enregistrer les modifications'
                        : 'Ajouter la dépense'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
