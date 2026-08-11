import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/parametre_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Paramètres — cahier des charges §10.9
/// Persisté via `/api/parametres/` (écriture admin) + sauvegardes admin.
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final _service = ParametreService();
  final _entrepriseFormKey = GlobalKey<FormState>();
  final _nomEntrepriseCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _rccmCtrl = TextEditingController();
  final _nifCtrl = TextEditingController();

  bool _chargement = true;
  bool _tvaActive = true;
  double _tvaTaux = 19.25;
  bool _taxeBoissonActive = false;
  double _taxeBoissonTaux = 5.0;
  final List<Map<String, dynamic>> _imprimantes = [];
  bool _sauvegardeAuto = true;
  String _derniereSauvegarde = '—';
  List<Map<String, dynamic>> _sauvegardes = [];
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

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

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final data = await _service.getParametres();
      _appliquer(data);
      if (!mounted) return;
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (RolePermissions.canManageParametresSysteme(utilisateur)) {
        _sauvegardes = await _service.listSauvegardes();
      }
    } catch (e) {
      _erreur = '$e';
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  void _appliquer(Map<String, dynamic> data) {
    _nomEntrepriseCtrl.text = data['nom_entreprise']?.toString() ?? '';
    _adresseCtrl.text = data['adresse']?.toString() ?? '';
    _telephoneCtrl.text = data['telephone']?.toString() ?? '';
    _emailCtrl.text = data['email']?.toString() ?? '';
    _rccmCtrl.text = data['rccm']?.toString() ?? '';
    _nifCtrl.text = data['nif']?.toString() ?? '';
    _tvaActive = data['tva_active'] == true;
    _tvaTaux = double.tryParse(data['tva_taux']?.toString() ?? '') ?? 19.25;
    _taxeBoissonActive = data['taxe_boisson_active'] == true;
    _taxeBoissonTaux =
        double.tryParse(data['taxe_boisson_taux']?.toString() ?? '') ?? 5.0;
    _sauvegardeAuto = data['sauvegarde_auto'] != false;
    final derniere = data['derniere_sauvegarde']?.toString();
    _derniereSauvegarde = (derniere == null || derniere.isEmpty)
        ? '—'
        : Formatters.dateHeure(DateTime.tryParse(derniere) ?? DateTime.now());
    _imprimantes
      ..clear()
      ..addAll(
        ((data['imprimantes'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
  }

  Map<String, dynamic> _payload() => {
        'nom_entreprise': _nomEntrepriseCtrl.text.trim(),
        'adresse': _adresseCtrl.text.trim(),
        'telephone': _telephoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'rccm': _rccmCtrl.text.trim(),
        'nif': _nifCtrl.text.trim(),
        'tva_active': _tvaActive,
        'tva_taux': _tvaTaux.toStringAsFixed(2),
        'taxe_boisson_active': _taxeBoissonActive,
        'taxe_boisson_taux': _taxeBoissonTaux.toStringAsFixed(2),
        'imprimantes': _imprimantes,
        'sauvegarde_auto': _sauvegardeAuto,
      };

  Future<void> _enregistrerEntreprise() async {
    if (!_entrepriseFormKey.currentState!.validate()) return;
    try {
      final data = await _service.updateParametres(_payload());
      _appliquer(data);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres enregistrés'),
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

  Future<void> _exporterSauvegarde() async {
    try {
      final meta = await _service.creerSauvegarde();
      _sauvegardes = await _service.listSauvegardes();
      setState(() {
        _derniereSauvegarde = Formatters.dateHeure(DateTime.now());
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sauvegarde créée'),
          content: Text('Fichier : ${meta['nom']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.rouge),
      );
    }
  }

  Future<void> _importerSauvegarde() async {
    if (_sauvegardes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune sauvegarde disponible. Exportez d\'abord.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    String? selection = _sauvegardes.first['nom']?.toString();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurer une sauvegarde'),
        content: DropdownButtonFormField<String>(
          initialValue: selection,
          items: [
            for (final s in _sauvegardes)
              DropdownMenuItem(
                value: s['nom']?.toString(),
                child: Text(s['nom']?.toString() ?? ''),
              ),
          ],
          onChanged: (v) => selection = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );

    if (confirme != true || selection == null || !mounted) return;
    try {
      await _service.restaurerSauvegarde(selection!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restauration effectuée : $selection'),
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
          'defaut': _imprimantes.isEmpty,
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
    final peutModifier = RolePermissions.canManageParametresSysteme(utilisateur);

    return Scaffold(
      appBar: AppHeader(title: 'Paramètres'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/parametres'),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : _erreur != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_erreur!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _charger,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    if (!peutModifier)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline,
                                size: 16, color: AppColors.texteClair),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lecture seule — la modification est réservée aux administrateurs.',
                                style: TextStyle(
                                    color: AppColors.texteClair, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _TitreSection('Apparence', Icons.palette_outlined),
                    const SizedBox(height: 8),
                    Card(
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) => SwitchListTile(
                          secondary: Icon(
                            themeProvider.estSombre
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Thème sombre'),
                          subtitle: Text(
                            themeProvider.estSombre
                                ? 'Mode sombre activé'
                                : 'Mode clair activé',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: themeProvider.estSombre,
                          onChanged: themeProvider.basculer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _TitreSection(
                        'Informations de l\'entreprise', Icons.business),
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
                                enabled: peutModifier,
                                decoration: const InputDecoration(
                                  labelText: 'Nom de l\'établissement',
                                  prefixIcon: Icon(Icons.storefront),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Le nom est requis'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _adresseCtrl,
                                enabled: peutModifier,
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
                                      enabled: peutModifier,
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
                                      enabled: peutModifier,
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
                                      enabled: peutModifier,
                                      decoration:
                                          const InputDecoration(labelText: 'RCCM'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nifCtrl,
                                      enabled: peutModifier,
                                      decoration:
                                          const InputDecoration(labelText: 'NIF'),
                                    ),
                                  ),
                                ],
                              ),
                              if (peutModifier) ...[
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            onChanged: peutModifier
                                ? (v) => setState(() => _tvaActive = v)
                                : null,
                            activeThumbColor: AppColors.vert,
                          ),
                          if (_tvaActive)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                      onChanged: peutModifier
                                          ? (v) => setState(() => _tvaTaux = v)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '${_tvaTaux.toStringAsFixed(2)} %',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            onChanged: peutModifier
                                ? (v) => setState(() => _taxeBoissonActive = v)
                                : null,
                            activeThumbColor: AppColors.vert,
                          ),
                          if (_taxeBoissonActive)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Text('Taux taxe boisson'),
                                  Expanded(
                                    child: Slider(
                                      value: _taxeBoissonTaux,
                                      min: 0,
                                      max: 20,
                                      divisions: 40,
                                      label:
                                          '${_taxeBoissonTaux.toStringAsFixed(1)} %',
                                      activeColor: AppColors.orange,
                                      onChanged: peutModifier
                                          ? (v) => setState(
                                              () => _taxeBoissonTaux = v)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '${_taxeBoissonTaux.toStringAsFixed(1)} %',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                              trailing: peutModifier
                                  ? PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (v) {
                                        if (v == 'defaut') {
                                          _definirImprimanteParDefaut(i);
                                        }
                                        if (v == 'supprimer') {
                                          _supprimerImprimante(i);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        if (_imprimantes[i]['defaut'] != true)
                                          const PopupMenuItem(
                                            value: 'defaut',
                                            child: Text('Définir par défaut'),
                                          ),
                                        const PopupMenuItem(
                                          value: 'supprimer',
                                          child: Text(
                                            'Supprimer',
                                            style:
                                                TextStyle(color: AppColors.rouge),
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                            if (i < _imprimantes.length - 1)
                              const Divider(height: 1),
                          ],
                          if (_imprimantes.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Aucune imprimante configurée.',
                                style: TextStyle(color: AppColors.texteClair),
                              ),
                            ),
                          if (peutModifier)
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
                    if (peutModifier) ...[
                      const SizedBox(height: 24),
                      _TitreSection('Sauvegardes', Icons.backup),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Sauvegarde automatique'),
                              subtitle: const Text(
                                'Planification indicative (export manuel disponible)',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: _sauvegardeAuto,
                              onChanged: (v) =>
                                  setState(() => _sauvegardeAuto = v),
                              activeThumbColor: AppColors.vert,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.history,
                                  color: AppColors.texteClair),
                              title: const Text('Dernière sauvegarde'),
                              trailing: Text(
                                _derniereSauvegarde,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (_sauvegardes.isNotEmpty) ...[
                              const Divider(height: 1),
                              for (final s in _sauvegardes.take(5))
                                ListTile(
                                  dense: true,
                                  title: Text(s['nom']?.toString() ?? ''),
                                  subtitle: Text('${s['taille'] ?? 0} octets'),
                                ),
                            ],
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _importerSauvegarde,
                                      icon: const Icon(Icons.upload, size: 18),
                                      label: const Text('Restaurer'),
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
                    ],
                    const SizedBox(height: 24),
                    _TitreSection('À propos', Icons.info_outline),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            leading:
                                Icon(Icons.apps, color: AppColors.bleuFonce),
                            title: Text('Application'),
                            subtitle: Text('POS Débits de Boissons'),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading:
                                Icon(Icons.tag, color: AppColors.texteClair),
                            title: Text('Version'),
                            trailing: Text('1.0.0'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.person,
                                color: AppColors.texteClair),
                            title: const Text('Connecté en tant que'),
                            trailing: Text(
                              utilisateur != null
                                  ? '${utilisateur.prenom} ${utilisateur.nom}'
                                  : '—',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
        Icon(icone, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(texte, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
