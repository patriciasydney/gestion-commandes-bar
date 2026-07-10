import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/role.dart';
import '../../models/utilisateur.dart';
import '../../providers/auth_provider.dart';
import '../../providers/utilisateur_provider.dart';
import '../../services/utilisateur_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_bottom_nav.dart';

/// Écran : Gestion des utilisateurs — cahier des charges §10.7
///
/// Réservé au rôle Administrateur (id_role == 1). Si un utilisateur non-admin
/// tente d'y accéder (via le drawer par exemple), un écran d'avertissement
/// s'affiche à la place de la liste.
class UtilisateursScreen extends StatefulWidget {
  const UtilisateursScreen({super.key});

  @override
  State<UtilisateursScreen> createState() => _UtilisateursScreenState();
}

class _UtilisateursScreenState extends State<UtilisateursScreen> {
  List<Role> _roles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.utilisateur?.isAdministrateur == true) {
        context.read<UtilisateurProvider>().chargerUtilisateurs();
        _chargerRoles();
      }
    });
  }

  Future<void> _chargerRoles() async {
    try {
      final liste = await UtilisateurService().getRoles();
      if (mounted) setState(() => _roles = liste);
    } catch (_) {
      // Silent : on garde une liste de rôles vide, l'UI dégrade proprement.
    }
  }

  String _nomRole(int idRole) {
    final trouve = _roles.where((r) => r.idRole == idRole);
    return trouve.isEmpty ? 'Rôle #$idRole' : trouve.first.nomRole;
  }

  Color _couleurRole(int idRole) {
    switch (idRole) {
      case 1:
        return AppColors.bleuFonce; // Admin
      case 2:
        return AppColors.orange; // Gérant
      case 3:
        return AppColors.vert; // Caissier
      default:
        return AppColors.texteClair;
    }
  }

  Future<void> _ouvrirFormulaire({Utilisateur? existant}) async {
    final resultat = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FormulaireUtilisateur(
        utilisateurExistant: existant,
        roles: _roles,
      ),
    );

    if (resultat == true && mounted) {
      context.read<UtilisateurProvider>().chargerUtilisateurs();
    }
  }

  Future<void> _basculerStatut(Utilisateur u) async {
    try {
      await context.read<UtilisateurProvider>().basculerStatut(u);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(u.statut == 'actif'
                ? 'Compte « ${u.username} » désactivé'
                : 'Compte « ${u.username} » réactivé'),
            backgroundColor: AppColors.vert,
          ),
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
    final auth = context.watch<AuthProvider>();

    // Garde-fou : seul l'administrateur peut accéder à cet écran.
    if (auth.utilisateur?.isAdministrateur != true) {
      return Scaffold(
        appBar: AppHeader(title: 'Gestion des utilisateurs'),
        drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/utilisateurs'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: AppColors.rouge),
                const SizedBox(height: 16),
                Text(
                  'Accès refusé',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seul un compte Administrateur peut accéder à la gestion des utilisateurs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.texteClair),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = context.watch<UtilisateurProvider>();

    return Scaffold(
      appBar: AppHeader(title: 'Gestion des utilisateurs'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/utilisateurs'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nouvel utilisateur'),
        backgroundColor: AppColors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher (nom, prénom, identifiant, email)…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: provider.rechercher,
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (provider.chargement) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.erreur != null) {
                return Center(child: Text(provider.erreur!,
                    style: const TextStyle(color: AppColors.rouge)));
              }
              if (provider.utilisateurs.isEmpty) {
                return const Center(
                  child: Text('Aucun utilisateur trouvé',
                      style: TextStyle(color: AppColors.texteClair)),
                );
              }
              return RefreshIndicator(
                onRefresh: provider.chargerUtilisateurs,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: provider.utilisateurs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final u = provider.utilisateurs[i];
                    final couleur = _couleurRole(u.roleId);
                    final actif = u.statut == 'actif';

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: couleur,
                          child: Text(
                            '${u.prenom.isNotEmpty ? u.prenom[0] : ''}${u.nom.isNotEmpty ? u.nom[0] : ''}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${u.prenom} ${u.nom}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: actif
                                      ? AppColors.texte
                                      : AppColors.texteClair,
                                ),
                              ),
                            ),
                            if (!actif)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.texteClair.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Désactivé',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.texteClair),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('@${u.username}',
                                style: const TextStyle(
                                    color: AppColors.bleuFonce, fontSize: 12)),
                            if (u.email.isNotEmpty)
                              Text(u.email,
                                  style: const TextStyle(
                                      color: AppColors.texteClair, fontSize: 11)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: couleur.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _nomRole(u.roleId),
                                style: TextStyle(
                                    color: couleur, fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (v) {
                            if (v == 'modifier') {
                              _ouvrirFormulaire(existant: u);
                            } else if (v == 'statut') {
                              _basculerStatut(u);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'modifier',
                              child: ListTile(
                                leading: Icon(Icons.edit, size: 18),
                                title: Text('Modifier'),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'statut',
                              child: ListTile(
                                leading: Icon(
                                  actif ? Icons.block : Icons.check_circle,
                                  size: 18,
                                  color: actif ? AppColors.rouge : AppColors.vert,
                                ),
                                title: Text(actif ? 'Désactiver' : 'Activer'),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
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
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulaire d'ajout / modification d'un utilisateur (bottom sheet)
// ---------------------------------------------------------------------------

class _FormulaireUtilisateur extends StatefulWidget {
  final Utilisateur? utilisateurExistant;
  final List<Role> roles;

  const _FormulaireUtilisateur({
    this.utilisateurExistant,
    required this.roles,
  });

  @override
  State<_FormulaireUtilisateur> createState() => _FormulaireUtilisateurState();
}

class _FormulaireUtilisateurState extends State<_FormulaireUtilisateur> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nomUtilisateurCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();

  int? _idRole;
  bool _actif = true;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    if (widget.utilisateurExistant != null) {
      final u = widget.utilisateurExistant!;
      _nomCtrl.text = u.nom;
      _prenomCtrl.text = u.prenom;
      _telephoneCtrl.text = u.telephone ?? '';
      _emailCtrl.text = u.email;
      _nomUtilisateurCtrl.text = u.username;
      _idRole = u.roleId;
      _actif = u.statut == 'actif';
    } else if (widget.roles.isNotEmpty) {
      // Par défaut : Caissier (id_role = 3 si présent, sinon premier rôle).
      _idRole = widget.roles.any((r) => r.idRole == 3) ? 3 : widget.roles.first.idRole;
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez un rôle'),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }

    setState(() => _enregistrement = true);

    final roleSelectionne = widget.roles.firstWhere(
      (r) => r.idRole == _idRole,
      orElse: () => Role(idRole: _idRole!, nomRole: '', actif: true),
    );

    final u = Utilisateur(
      id: widget.utilisateurExistant?.id ?? 0,
      username: _nomUtilisateurCtrl.text.trim(),
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      telephone: _telephoneCtrl.text.trim().isEmpty ? null : _telephoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      statut: _actif ? 'actif' : 'inactif',
      role: roleSelectionne,
    );

    try {
      final provider = context.read<UtilisateurProvider>();
      if (widget.utilisateurExistant != null) {
        await provider.modifier(widget.utilisateurExistant!.id, u);
      } else {
        await provider.creer(
          u,
          password: _motDePasseCtrl.text,
        );
      }
      // Note : en mode démo, le mot de passe saisi n'est pas transmis
      // (la gestion sécurisée des mots de passe se fait côté backend Django).
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
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _nomUtilisateurCtrl.dispose();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modification = widget.utilisateurExistant != null;
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
              Text(
                modification ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prenomCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (v) =>
                          Validators.requis(v, champ: 'Le prénom'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _nomCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) =>
                          Validators.requis(v, champ: 'Le nom'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nomUtilisateurCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur (identifiant de connexion)',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (v) =>
                    Validators.requis(v, champ: 'Le nom d\'utilisateur'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => Validators.email(v),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telephoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Téléphone (optionnel)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              if (!modification)
                TextFormField(
                  controller: _motDePasseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe initial',
                    prefixIcon: Icon(Icons.lock_outline),
                    helperText: 'Sera hashé et stocké côté backend Django',
                  ),
                  obscureText: true,
                  validator: (v) => Validators.motDePasse(v),
                ),
              if (!modification) const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _idRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                items: [
                  for (final r in widget.roles)
                    DropdownMenuItem(value: r.idRole, child: Text(r.nomRole)),
                ],
                onChanged: (v) => setState(() => _idRole = v),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Compte actif'),
                subtitle: const Text(
                  'Un compte désactivé ne peut plus se connecter',
                  style: TextStyle(fontSize: 12),
                ),
                value: _actif,
                onChanged: (v) => setState(() => _actif = v),
                activeThumbColor: AppColors.vert,
              ),
              const SizedBox(height: 16),
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
                        : 'Créer l\'utilisateur'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
