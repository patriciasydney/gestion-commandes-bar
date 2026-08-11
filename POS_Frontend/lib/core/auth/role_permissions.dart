import '../../models/utilisateur.dart';
import '../../routes/app_routes.dart';

/// Modules applicatifs — alignés sur le cahier des charges §4.1 et §8.2.
enum AppModule {
  dashboard,
  pos,
  produits,
  categories,
  stocks,
  fournisseurs,
  clients,
  achats,
  depenses,
  utilisateurs,
  rapports,
  parametres,
}

/// Matrice d'accès par rôle (lecture des écrans / routes).
class RolePermissions {
  RolePermissions._();

  static const _dashboard = {1, 2, 6};
  static const _pos = {1, 2, 3, 5};
  static const _catalogRead = {1, 2, 3, 4, 5, 6};
  static const _catalogWrite = {1, 2};
  static const _stocksRead = {1, 2, 3, 4, 5, 6};
  static const _stocksWrite = {1, 2, 4};
  static const _fournisseursRead = {1, 2, 4, 6};
  static const _fournisseursWrite = {1, 2};
  static const _clientsRead = {1, 2, 3, 5, 6};
  static const _clientsWrite = {1, 2, 3, 5};
  static const _achatsRead = {1, 2, 4, 6};
  static const _achatsWrite = {1, 2, 4};
  static const _depenses = {1, 2, 6};
  static const _utilisateurs = {1};
  static const _rapports = {1, 2, 6};
  static const _parametres = {1, 2, 3, 4, 5, 6};

  static bool canAccessRoute(String? route, Utilisateur? user) {
    if (route == null || route == AppRoutes.login || route == AppRoutes.entry) {
      return true;
    }
    return canAccess(_moduleFromRoute(route), user);
  }

  static bool canAccess(AppModule module, Utilisateur? user) {
    if (user == null) return false;
    final roleId = user.roleId;
    if (roleId <= 0) return false;

    final allowed = switch (module) {
      AppModule.dashboard => _dashboard,
      AppModule.pos => _pos,
      AppModule.produits => _catalogRead,
      AppModule.categories => _catalogRead,
      AppModule.stocks => _stocksRead,
      AppModule.fournisseurs => _fournisseursRead,
      AppModule.clients => _clientsRead,
      AppModule.achats => _achatsRead,
      AppModule.depenses => _depenses,
      AppModule.utilisateurs => _utilisateurs,
      AppModule.rapports => _rapports,
      AppModule.parametres => _parametres,
    };
    return allowed.contains(roleId) || _fallbackByNomRole(module, user);
  }

  static bool canWrite(AppModule module, Utilisateur? user) {
    if (user == null) return false;
    if (module == AppModule.dashboard ||
        module == AppModule.pos ||
        module == AppModule.rapports ||
        module == AppModule.parametres) {
      return canAccess(module, user);
    }

    final roleId = user.roleId;
    final Set<int> allowed = switch (module) {
      AppModule.produits || AppModule.categories => _catalogWrite,
      AppModule.stocks => _stocksWrite,
      AppModule.fournisseurs => _fournisseursWrite,
      AppModule.clients => _clientsWrite,
      AppModule.achats => _achatsWrite,
      AppModule.depenses => _depenses,
      AppModule.utilisateurs => _utilisateurs,
      AppModule.dashboard ||
      AppModule.pos ||
      AppModule.rapports ||
      AppModule.parametres =>
        const {},
    };
    return allowed.contains(roleId) || _fallbackWriteByNomRole(module, user);
  }

  /// Route d'accueil après connexion selon le rôle.
  static String routeAccueil(Utilisateur? user) {
    if (user == null) return AppRoutes.login;
    if (user.isCaissier || user.isServeur) return AppRoutes.pos;
    if (user.isMagasinier) return AppRoutes.stocks;
    if (user.isComptable) return AppRoutes.rapports;
    return AppRoutes.dashboard;
  }

  static List<({String route, String label})> itemsNavigationPrincipale(
    Utilisateur? user,
  ) {
    const candidats = [
      (route: AppRoutes.dashboard, label: 'Accueil', module: AppModule.dashboard),
      (route: AppRoutes.pos, label: 'Vente', module: AppModule.pos),
      (route: AppRoutes.produits, label: 'Produits', module: AppModule.produits),
      (route: AppRoutes.stocks, label: 'Stocks', module: AppModule.stocks),
      (route: AppRoutes.clients, label: 'Clients', module: AppModule.clients),
      (route: AppRoutes.rapports, label: 'Rapports', module: AppModule.rapports),
    ];

    return candidats
        .where((item) => canAccess(item.module, user))
        .map((item) => (route: item.route, label: item.label))
        .toList();
  }

  static List<({String label, String route})> itemsMenuLateral(
    Utilisateur? user,
  ) {
    const candidats = [
      ('Tableau de bord', AppRoutes.dashboard, AppModule.dashboard),
      ('Point de vente', AppRoutes.pos, AppModule.pos),
      ('Produits', AppRoutes.produits, AppModule.produits),
      ('Catégories', AppRoutes.categories, AppModule.categories),
      ('Stocks', AppRoutes.stocks, AppModule.stocks),
      ('Fournisseurs', AppRoutes.fournisseurs, AppModule.fournisseurs),
      ('Clients', AppRoutes.clients, AppModule.clients),
      ('Achats', AppRoutes.achats, AppModule.achats),
      ('Dépenses', AppRoutes.depenses, AppModule.depenses),
      ('Utilisateurs', AppRoutes.utilisateurs, AppModule.utilisateurs),
      ('Rapports', AppRoutes.rapports, AppModule.rapports),
      ('Paramètres', AppRoutes.parametres, AppModule.parametres),
    ];

    return candidats
        .where((item) => canAccess(item.$3, user))
        .map((item) => (label: item.$1, route: item.$2))
        .toList();
  }

  static AppModule _moduleFromRoute(String route) {
    if (route.startsWith(AppRoutes.produitForm)) {
      return AppModule.produits;
    }
    return switch (route) {
      AppRoutes.dashboard => AppModule.dashboard,
      AppRoutes.pos => AppModule.pos,
      AppRoutes.produits => AppModule.produits,
      AppRoutes.categories => AppModule.categories,
      AppRoutes.stocks => AppModule.stocks,
      AppRoutes.fournisseurs => AppModule.fournisseurs,
      AppRoutes.clients => AppModule.clients,
      AppRoutes.achats => AppModule.achats,
      AppRoutes.depenses => AppModule.depenses,
      AppRoutes.utilisateurs => AppModule.utilisateurs,
      AppRoutes.rapports => AppModule.rapports,
      AppRoutes.parametres => AppModule.parametres,
      _ => AppModule.parametres,
    };
  }

  static bool _fallbackByNomRole(AppModule module, Utilisateur user) {
    return switch (module) {
      AppModule.dashboard => user.isAdministrateur || user.isGerant || user.isComptable,
      AppModule.pos =>
        user.isAdministrateur || user.isGerant || user.isCaissier || user.isServeur,
      AppModule.produits || AppModule.categories => true,
      AppModule.stocks =>
        user.isAdministrateur ||
        user.isGerant ||
        user.isMagasinier ||
        user.isComptable ||
        user.isCaissier ||
        user.isServeur,
      AppModule.fournisseurs =>
        user.isAdministrateur || user.isGerant || user.isMagasinier || user.isComptable,
      AppModule.clients =>
        user.isAdministrateur ||
        user.isGerant ||
        user.isCaissier ||
        user.isServeur ||
        user.isComptable,
      AppModule.achats =>
        user.isAdministrateur || user.isGerant || user.isMagasinier || user.isComptable,
      AppModule.depenses =>
        user.isAdministrateur || user.isGerant || user.isComptable,
      AppModule.utilisateurs => user.isAdministrateur,
      AppModule.rapports =>
        user.isAdministrateur || user.isGerant || user.isComptable,
      AppModule.parametres => true,
    };
  }

  static bool _fallbackWriteByNomRole(AppModule module, Utilisateur user) {
    return switch (module) {
      AppModule.produits || AppModule.categories =>
        user.isAdministrateur || user.isGerant,
      AppModule.stocks =>
        user.isAdministrateur || user.isGerant || user.isMagasinier,
      AppModule.fournisseurs => user.isAdministrateur || user.isGerant,
      AppModule.clients =>
        user.isAdministrateur ||
        user.isGerant ||
        user.isCaissier ||
        user.isServeur,
      AppModule.achats =>
        user.isAdministrateur || user.isGerant || user.isMagasinier,
      AppModule.depenses =>
        user.isAdministrateur || user.isGerant || user.isComptable,
      AppModule.utilisateurs => user.isAdministrateur,
      _ => _fallbackByNomRole(module, user),
    };
  }
}
