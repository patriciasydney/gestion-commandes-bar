import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'role_permissions.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_header.dart';

/// Écran affiché lorsqu'un utilisateur tente d'accéder à un module non autorisé.
class AccessDeniedScaffold extends StatelessWidget {
  const AccessDeniedScaffold({
    super.key,
    required this.titre,
    required this.currentRoute,
    this.message,
  });

  final String titre;
  final String currentRoute;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;

    return Scaffold(
      appBar: AppHeader(title: titre),
      drawer: const AppDrawer(),
      bottomNavigationBar: AppBottomNav(currentRoute: currentRoute),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.rouge),
              const SizedBox(height: 16),
              Text(
                'Accès refusé',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    'Votre rôle (${utilisateur?.nomRole.isNotEmpty == true ? utilisateur!.nomRole : 'non défini'}) '
                        'ne permet pas d\'accéder à ce module.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  final route = RolePermissions.routeAccueil(utilisateur);
                  Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vérifie les droits d'accès à une route avant d'afficher l'écran enfant.
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.route,
    required this.titre,
    required this.child,
  });

  final String route;
  final String titre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;

    if (!RolePermissions.canAccessRoute(route, utilisateur)) {
      return AccessDeniedScaffold(titre: titre, currentRoute: route);
    }

    return child;
  }
}

/// Titres affichés dans la barre d'en-tête par route.
const routeTitles = <String, String>{
  '/dashboard': 'Tableau de bord',
  '/pos': 'Point de vente',
  '/produits': 'Produits',
  '/produits/form': 'Produit',
  '/categories': 'Catégories',
  '/stocks': 'Stocks',
  '/fournisseurs': 'Fournisseurs',
  '/clients': 'Clients',
  '/achats': 'Achats',
  '/depenses': 'Dépenses',
  '/utilisateurs': 'Utilisateurs',
  '/rapports': 'Rapports',
  '/parametres': 'Paramètres',
};
