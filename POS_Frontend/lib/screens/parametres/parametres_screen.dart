import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Paramètres — cahier des charges §10.9
///
/// Centralise les configurations générales de l'application :
/// - Informations de l'entreprise (nom, adresse, RCCM, NIF, contacts)
/// - Configuration des taxes (TVA, taxes additionnelles)
/// - Imprimantes thermiques connectées (nom, IP, port)
/// - Sauvegardes (export, import, planification automatique)
///
/// En mode démo, les paramètres sont stockés en mémoire (perdus au redémarrage).
/// Une fois le backend Django branché, ils seront persistés via un endpoint
/// `/parametres/` dédié. Pour une persistance locale entre les redémarrages,
/// il faudra ajouter le package `shared_preferences` au pubspec.yaml.
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  // ---- Infos entreprise ----
  final _entrepriseFormKey = GlobalKey<FormState>();
  final _nomEntrepriseCtrl = TextEditingController(text: 'Bar Le Relais');
  final _adresseCtrl = TextEditingController(text: 'Avenue Kennedy, Yaoundé');
  final _telephoneCtrl = TextEditingController(text: '233 42 10 00');
  final _emailCtrl = TextEditingController(text: 'contact@relais.cm');
  final _rccmCtrl = TextEditingController(text: 'RC/YAO/2018/B/1234');
  final _nifCtrl = TextEditingController(text: 'P0123456789012');

  // ---- Taxes ----
  bool _tvaActive = true;
  double _tvaTaux = 19.25; // TVA Cameroun
  bool _taxeBoissonActive = false;
  double _taxeBoissonTaux = 5.0;

  // ---- Imprimantes ----
  final List<Map<String, dynamic>> _imprimantes = [
    {'nom': 'Caisse 1 - Cuisine', 'ip': '192.168.1.50', 'port': 9100, 'defaut': true},
    {'nom': 'Caisse 2 - Bar', 'ip': '192.168.1.51', 'port': 9100, 'defaut': false},
  ];

  // ---- Sauvegardes ----
  bool _sauvegardeAuto = true;
  String _derniereSauvegarde = '07/07/2026 23:00';

  @override
  void dispose() {
    _nomEntrepriseCtrl.dispose();
    _adresseCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _rccmCtrl.dispose();
    _nifCtrl.dispose();
    super.dispose();
  }

  void _enregistrerEntreprise() {
    if (_entrepriseFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations de l\'entreprise enregistrées'),
          backgroundColor: AppColors.vert,
        ),
      );
    }
  }

  Future<void> _exporterSauvegarde() async {
    // En mode démo : on simule l'export en affichant un dialogue de confirmation.
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sauvegarde exportée'),
        content: const Text(
          'La sauvegarde des données a été générée avec succès. '
          'Une fois le backend Django connecté, un fichier .json ou .zip '
          'sera téléchargeable ici.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    setState(() => _derniereSauvegarde = Formatters.dateHeure(DateTime.now()));
  }

  Future<void> _importerSauvegarde() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importer une sauvegarde'),
        content: const Text(
          'Sélectionnez un fichier de sauvegarde (.json ou .zip) à restaurer. '
          'Cette action remplacera les données actuelles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import simulé (backend non branché)'),
                  backgroundColor: AppColors.bleuFonce,
                ),
              );
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  Future<void> _ajouterImprimante() async {
    final nomCtrl = TextEditingController();
    final ipCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '9100');
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une imprimante'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom (ex: Caisse 3)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ipCtrl,
                decoration: const InputDecoration(labelText: 'Adresse IP'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'L\'IP est requise' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: portCtrl,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Le port est requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirme == true && mounted) {
      setState(() {
        _imprimantes.add({
          'nom': nomCtrl.text.trim(),
          'ip': ipCtrl.text.trim(),
          'port': int.tryParse(portCtrl.text.trim()) ?? 9100,
          'defaut': false,
        });
      });
    }
  }

  void _definirImprimanteParDefaut(int index) {
    setState(() {
      for (int i = 0; i < _imprimantes.length; i++) {
        _imprimantes[i]['defaut'] = (i == index);
      }
    });
  }

  void _supprimerImprimante(int index) {
    setState(() => _imprimantes.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final estAdmin = utilisateur?.isAdministrateur ?? false;

    return Scaffold(
      appBar: AppHeader(title: 'Paramètres'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/parametres'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Section Entreprise ----
          _TitreSection('Informations de l\'entreprise', Icons.business),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _entrepriseFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomEntrepriseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'établissement',
                        prefixIcon: Icon(Icons.storefront),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _adresseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        prefixIcon: Icon(Icons.place),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _telephoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rccmCtrl,
                            decoration: const InputDecoration(labelText: 'RCCM'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _nifCtrl,
                            decoration: const InputDecoration(labelText: 'NIF'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _enregistrerEntreprise,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          // ---- Section Taxes ----
          _TitreSection('Taxes', Icons.percent),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('TVA active'),
                  subtitle: const Text(
                    'Appliquer la TVA sur les ventes',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _tvaActive,
                  onChanged: (v) => setState(() => _tvaActive = v),
                  activeThumbColor: AppColors.vert,
                ),
                if (_tvaActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('Taux de TVA'),
                        Expanded(
                          child: Slider(
                            value: _tvaTaux,
                            min: 0,
                            max: 30,
                            divisions: 60,
                            label: '${_tvaTaux.toStringAsFixed(2)} %',
                            activeColor: AppColors.orange,
                            onChanged: (v) => setState(() => _tvaTaux = v),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '${_tvaTaux.toStringAsFixed(2)} %',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Taxe boisson'),
                  subtitle: const Text(
                    'Taxe communale additionnelle sur les boissons',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _taxeBoissonActive,
                  onChanged: (v) => setState(() => _taxeBoissonActive = v),
                  activeThumbColor: AppColors.vert,
                ),
                if (_taxeBoissonActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('Taux taxe boisson'),
                        Expanded(
                          child: Slider(
                            value: _taxeBoissonTaux,
                            min: 0,
                            max: 20,
                            divisions: 40,
                            label: '${_taxeBoissonTaux.toStringAsFixed(1)} %',
                            activeColor: AppColors.orange,
                            onChanged: (v) => setState(() => _taxeBoissonTaux = v),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '${_taxeBoissonTaux.toStringAsFixed(1)} %',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // ---- Section Imprimantes ----
          _TitreSection('Imprimantes thermiques', Icons.print),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (int i = 0; i < _imprimantes.length; i++) ...[
                  ListTile(
                    leading: Icon(
                      _imprimantes[i]['defaut'] == true
                          ? Icons.print
                          : Icons.print_outlined,
                      color: _imprimantes[i]['defaut'] == true
                          ? AppColors.vert
                          : AppColors.texteClair,
                    ),
                    title: Text(_imprimantes[i]['nom'].toString()),
                    subtitle: Text(
                      '${_imprimantes[i]['ip']}:${_imprimantes[i]['port']}'
                      '${_imprimantes[i]['defaut'] == true ? ' · Par défaut' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) {
                        if (v == 'defaut') _definirImprimanteParDefaut(i);
                        if (v == 'supprimer') _supprimerImprimante(i);
                      },
                      itemBuilder: (_) => [
                        if (_imprimantes[i]['defaut'] != true)
                          const PopupMenuItem(
                            value: 'defaut',
                            child: ListTile(
                              leading: Icon(Icons.star, size: 18),
                              title: Text('Définir par défaut'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'supprimer',
                          child: ListTile(
                            leading: Icon(Icons.delete, size: 18, color: AppColors.rouge),
                            title: Text('Supprimer',
                                style: TextStyle(color: AppColors.rouge)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _imprimantes.length - 1) const Divider(height: 1),
                ],
                if (_imprimantes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Aucune imprimante configurée.',
                      style: TextStyle(color: AppColors.texteClair),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _ajouterImprimante,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Ajouter une imprimante'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // ---- Section Sauvegardes ----
          _TitreSection('Sauvegardes', Icons.backup),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sauvegarde automatique'),
                  subtitle: const Text(
                    'Exporter les données chaque soir à 23h00',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _sauvegardeAuto,
                  onChanged: (v) => setState(() => _sauvegardeAuto = v),
                  activeThumbColor: AppColors.vert,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.texteClair),
                  title: const Text('Dernière sauvegarde'),
                  trailing: Text(_derniereSauvegarde,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importerSauvegarde,
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Importer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exporterSauvegarde,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Exporter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // ---- Section À propos ----
          _TitreSection('À propos', Icons.info_outline),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apps, color: AppColors.bleuFonce),
                  title: const Text('Application'),
                  subtitle: const Text('POS Débits de Boissons'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tag, color: AppColors.texteClair),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0 (mode démo)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.texteClair),
                  title: const Text('Connecté en tant que'),
                  trailing: Text(
                    utilisateur != null
                        ? '${utilisateur.prenom} ${utilisateur.nom}'
                        : '—',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (!estAdmin)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline,
                            size: 16, color: AppColors.texteClair),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'La modification des paramètres est réservée aux administrateurs.',
                            style: TextStyle(
                                color: AppColors.texteClair, fontSize: 12),
                          ),
                        ),
                      ],
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

class _TitreSection extends StatelessWidget {
  final String texte;
  final IconData icone;

  const _TitreSection(this.texte, this.icone);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: AppColors.bleuFonce, size: 20),
        const SizedBox(width: 8),
        Text(texte, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
