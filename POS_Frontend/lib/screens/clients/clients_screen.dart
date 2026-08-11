import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/client.dart';
import '../../models/vente.dart';
import '../../services/client_service.dart';
import '../../services/vente_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/filter_choice_chip.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Gestion des clients — cahier des charges §5.7
///
/// Liste les clients enregistrés et permet d'en créer / modifier / supprimer.
/// Un clic sur un client permet de consulter son historique d'achats.
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientService _service = ClientService();
  final VenteService _venteService = VenteService();
  
  List<Client> _clients = [];
  List<Client> _clientsFiltres = [];
  String _recherche = '';
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      _clients = await _service.getAll();
      _appliquerFiltre();
    } catch (e) {
      _erreur = "Impossible de charger les clients (backend non branché ?)";
    }
    if (mounted) setState(() => _chargement = false);
  }

  void _appliquerFiltre() {
    if (_recherche.trim().isEmpty) {
      _clientsFiltres = _clients;
    } else {
      final q = _recherche.toLowerCase();
      _clientsFiltres = _clients.where((c) {
        return c.nom.toLowerCase().contains(q) ||
            (c.prenom?.toLowerCase().contains(q) ?? false) ||
            (c.telephone?.contains(q) ?? false) ||
            (c.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
  }

  Future<void> _ouvrirFormulaire({Client? client}) async {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: client?.nom ?? '');
    final prenomCtrl = TextEditingController(text: client?.prenom ?? '');
    final telCtrl = TextEditingController(text: client?.telephone ?? '');
    final emailCtrl = TextEditingController(text: client?.email ?? '');
    final adresseCtrl = TextEditingController(text: client?.adresse ?? '');
    bool actif = client?.actif ?? true;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(client == null ? 'Nouveau client' : 'Modifier le client'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: prenomCtrl,
                          decoration: const InputDecoration(labelText: 'Prénom (optionnel)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: nomCtrl,
                          decoration: const InputDecoration(labelText: 'Nom *'),
                          validator: (v) => Validators.requis(v, champ: 'Le nom'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone (optionnel)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email (optionnel)',
                      prefixIcon: Icon(Icons.mail),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adresseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Adresse (optionnel)',
                      prefixIcon: Icon(Icons.place),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Client actif'),
                    subtitle: const Text(
                      'Un client inactif n\'apparaîtra plus dans le POS',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: actif,
                    onChanged: (v) => setStateDialog(() => actif = v),
                    activeThumbColor: AppColors.vert,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
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

    final nouveau = Client(
      idClient: client?.idClient ?? 0,
      nom: nomCtrl.text.trim(),
      prenom: prenomCtrl.text.trim().isEmpty ? null : prenomCtrl.text.trim(),
      telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      adresse: adresseCtrl.text.trim().isEmpty ? null : adresseCtrl.text.trim(),
      actif: actif,
    );

    try {
      if (client != null) {
        await _service.update(client.idClient, nouveau);
      } else {
        await _service.create(nouveau);
      }
      await _charger();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(client == null ? 'Client ajouté' : 'Client modifié'),
            backgroundColor: AppColors.vert,
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

  Future<void> _confirmerSuppression(Client client) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce client ?'),
        content: Text('« ${client.nom} ${client.prenom ?? ''} » sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.rouge)),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    try {
      await _service.delete(client.idClient);
      await _charger();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client supprimé'),
            backgroundColor: AppColors.vert,
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

  Future<void> _voirHistorique(Client client) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DialogHistorique(
        client: client,
        venteService: _venteService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final peutModifier = RolePermissions.canWrite(
      AppModule.clients,
      context.watch<AuthProvider>().utilisateur,
    );

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des clients'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/clients'),
      floatingActionButton: peutModifier
          ? FloatingActionButton.extended(
              onPressed: () => _ouvrirFormulaire(),
              icon: const Icon(Icons.person_add),
              label: const Text('Nouveau client'),
              backgroundColor: AppColors.orange,
            )
          : null,
      body: Column(
        children: [
          // Bandeau résumé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.bleuFonce,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total clients',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                Text(
                  '${_clients.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24),
                const Text('Actifs',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  '${_clients.where((c) => c.actif).length}',
                  style: const TextStyle(
                    color: AppColors.vert,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: themedSearchDecoration(
                context,
                hint: 'Rechercher (nom, prénom, téléphone, email)…',
              ),
              onChanged: (v) {
                setState(() => _recherche = v);
                _appliquerFiltre();
              },
            ),
          ),
          // Liste
          Expanded(
            child: Builder(builder: (context) {
              if (_chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_erreur != null) {
                return Center(
                  child: Text(_erreur!, style: const TextStyle(color: AppColors.rouge)),
                );
              }
              if (_clientsFiltres.isEmpty) {
                return Center(
                  child: Text(
                    _recherche.isEmpty ? 'Aucun client' : 'Aucun résultat',
                    style: const TextStyle(color: AppColors.texteClair),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _charger,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: _clientsFiltres.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = _clientsFiltres[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _voirHistorique(c),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: c.actif
                              ? AppColors.bleuFonce.withValues(alpha: 0.12)
                              : AppColors.texteClair.withValues(alpha: 0.12),
                          child: Text(
                            '${c.prenom?.isNotEmpty == true ? c.prenom![0] : ''}${c.nom.isNotEmpty ? c.nom[0] : ''}'.toUpperCase(),
                            style: TextStyle(
                              color: c.actif ? AppColors.bleuFonce : AppColors.texteClair,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${c.prenom ?? ''} ${c.nom}'.trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: c.actif ? null : AppColors.texteClair,
                                ),
                              ),
                            ),
                            if (!c.actif)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.texteClair.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Inactif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.texteClair,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (c.telephone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: AppColors.texteClair),
                                  const SizedBox(width: 4),
                                  Text(
                                    c.telephone!,
                                    style: const TextStyle(
                                      color: AppColors.texteClair,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            if (c.email != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.mail, size: 14, color: AppColors.texteClair),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      c.email!,
                                      style: const TextStyle(
                                        color: AppColors.texteClair,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Modifier',
                              icon: const Icon(Icons.edit_outlined, color: AppColors.texteClair),
                              onPressed: () => _ouvrirFormulaire(client: c),
                            ),
                            IconButton(
                              tooltip: 'Supprimer',
                              icon: const Icon(Icons.delete_outline, color: AppColors.rouge),
                              onPressed: () => _confirmerSuppression(c),
                            ),
                          ],
                        ),
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

/// Dialogue affichant l'historique des ventes d'un client.
class _DialogHistorique extends StatefulWidget {
  final Client client;
  final VenteService venteService;

  const _DialogHistorique({required this.client, required this.venteService});

  @override
  State<_DialogHistorique> createState() => _DialogHistoriqueState();
}

class _DialogHistoriqueState extends State<_DialogHistorique> {
  List<Vente> _ventes = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  Future<void> _chargerHistorique() async {
    try {
      final toutes = await widget.venteService.getAll();
      // Filtre côté client : on garde uniquement les ventes de ce client
      _ventes = toutes
          .where((v) => v.client == widget.client.idClient)
          .toList()
        ..sort((a, b) => b.dateVente.compareTo(a.dateVente));
    } catch (e) {
      _erreur = 'Erreur : $e';
    }
    if (mounted) setState(() => _chargement = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalDepense = _ventes.fold<double>(0, (s, v) => s + v.montantTotal);

    return AlertDialog(
      title: Text('Historique — ${widget.client.nom} ${widget.client.prenom ?? ''}'.trim()),
      content: SizedBox(
        width: double.maxFinite,
        child: _chargement
            ? const Center(child: CircularProgressIndicator())
            : _erreur != null
                ? Center(child: Text(_erreur!, style: const TextStyle(color: AppColors.rouge)))
                : _ventes.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun achat enregistré pour ce client.',
                          style: TextStyle(color: AppColors.texteClair),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bleuFonce.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_ventes.length} achat(s)',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Total : ${Formatters.montant(totalDepense)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bleuFonce,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _ventes.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final v = _ventes[i];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.receipt,
                                    size: 20,
                                    color: AppColors.bleuFonce,
                                  ),
                                  title: Text(
                                    v.reference,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(Formatters.dateHeure(v.dateVente)),
                                  trailing: Text(
                                    Formatters.montant(v.montantTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.vert,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
