import 'package:flutter_test/flutter_test.dart';
import 'package:front_boisson/core/auth/role_permissions.dart';
import 'package:front_boisson/models/role.dart';
import 'package:front_boisson/models/utilisateur.dart';
import 'package:front_boisson/routes/app_routes.dart';

Utilisateur _user(int roleId, String nomRole) => Utilisateur(
      id: roleId,
      username: 'user$roleId',
      nom: 'Test',
      prenom: nomRole,
      email: '$roleId@test.cm',
      statut: 'actif',
      role: Role(idRole: roleId, nomRole: nomRole, actif: true),
    );

void main() {
  group('RolePermissions — accès routes', () {
    test('administrateur accède à tous les modules', () {
      final admin = _user(1, 'Administrateur');
      for (final route in AppRoutes.routes.keys) {
        expect(RolePermissions.canAccessRoute(route, admin), isTrue,
            reason: 'admin devrait accéder à $route');
      }
    });

    test('caissier : POS oui, utilisateurs non', () {
      final caissier = _user(3, 'Caissier');
      expect(RolePermissions.canAccessRoute(AppRoutes.pos, caissier), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.dashboard, caissier), isFalse);
      expect(RolePermissions.canAccessRoute(AppRoutes.utilisateurs, caissier), isFalse);
      expect(RolePermissions.canAccessRoute(AppRoutes.rapports, caissier), isFalse);
    });

    test('magasinier : stocks et achats oui, POS non', () {
      final magasinier = _user(4, 'Magasinier');
      expect(RolePermissions.canAccessRoute(AppRoutes.stocks, magasinier), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.achats, magasinier), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.pos, magasinier), isFalse);
    });

    test('serveur : POS et clients oui, achats non', () {
      final serveur = _user(5, 'Serveur');
      expect(RolePermissions.canAccessRoute(AppRoutes.pos, serveur), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.clients, serveur), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.achats, serveur), isFalse);
    });

    test('comptable : rapports et dépenses oui, POS non', () {
      final comptable = _user(6, 'Comptable');
      expect(RolePermissions.canAccessRoute(AppRoutes.rapports, comptable), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.depenses, comptable), isTrue);
      expect(RolePermissions.canAccessRoute(AppRoutes.pos, comptable), isFalse);
    });
  });

  group('RolePermissions — écriture', () {
    test('caissier peut créer des clients mais pas des produits', () {
      final caissier = _user(3, 'Caissier');
      expect(RolePermissions.canWrite(AppModule.clients, caissier), isTrue);
      expect(RolePermissions.canWrite(AppModule.produits, caissier), isFalse);
    });

    test('magasinier peut ajuster les stocks', () {
      final magasinier = _user(4, 'Magasinier');
      expect(RolePermissions.canWrite(AppModule.stocks, magasinier), isTrue);
      expect(RolePermissions.canWrite(AppModule.fournisseurs, magasinier), isFalse);
    });
  });

  group('RolePermissions — route accueil', () {
    test('redirige selon le rôle', () {
      expect(RolePermissions.routeAccueil(_user(3, 'Caissier')), AppRoutes.pos);
      expect(RolePermissions.routeAccueil(_user(4, 'Magasinier')), AppRoutes.stocks);
      expect(RolePermissions.routeAccueil(_user(6, 'Comptable')), AppRoutes.rapports);
      expect(RolePermissions.routeAccueil(_user(2, 'Gérant')), AppRoutes.dashboard);
    });
  });
}
