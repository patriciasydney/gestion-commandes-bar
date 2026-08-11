import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/role_permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

/// Barre de navigation basse — destinations courtes par rôle + responsive.
class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  static const _icones = {
    '/dashboard': (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    '/pos': (
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale,
    ),
    '/commandes-attente': (
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    '/ventes': (
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
    ),
    '/produits': (
      icon: Icons.local_bar_outlined,
      activeIcon: Icons.local_bar,
    ),
    '/stocks': (
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
    ),
    '/achats': (
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
    ),
    '/clients': (
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    '/depenses': (
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
    ),
    '/rapports': (
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final items = RolePermissions.itemsNavigationPrincipale(utilisateur);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = items.indexWhere((i) => i.route == currentRoute);
    final routeDansBarre = selected >= 0;

    final estSombre = Theme.of(context).brightness == Brightness.dark;
    final couleurFond = Theme.of(context).colorScheme.surface;
    final couleurOmbre = estSombre
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.06);
    final iconeInactive =
        estSombre ? AppColors.texteClairSombre : AppColors.texteClair;
    final iconeActive =
        estSombre ? AppColors.orangeClair : AppColors.bleuFonce;
    final accent = estSombre ? AppColors.orangeClair : AppColors.bleuFonce;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeur = MediaQuery.sizeOf(context).width;
        final phone = largeur < ResponsiveBreakpoints.phone;
        final compact = phone && items.length >= 4;

        return Container(
          decoration: BoxDecoration(
            color: couleurFond,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: couleurOmbre,
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: NavigationBar(
              selectedIndex: routeDansBarre ? selected : 0,
              backgroundColor: couleurFond,
              indicatorColor: routeDansBarre
                  ? accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              elevation: 0,
              height: phone ? 64 : 72,
              labelBehavior: compact
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) {
                if (items[i].route == currentRoute) return;
                Navigator.pushReplacementNamed(context, items[i].route);
              },
              destinations: [
                for (var i = 0; i < items.length; i++)
                  NavigationDestination(
                    icon: Icon(
                      _icones[items[i].route]?.icon ?? Icons.circle_outlined,
                      color: iconeInactive,
                      size: phone ? 22 : 24,
                    ),
                    selectedIcon: Icon(
                      _icones[items[i].route]?.activeIcon ?? Icons.circle,
                      color: routeDansBarre ? iconeActive : iconeInactive,
                      size: phone ? 22 : 24,
                    ),
                    label: items[i].label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
