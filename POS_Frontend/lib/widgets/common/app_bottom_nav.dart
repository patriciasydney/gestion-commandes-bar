import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

/// Barre de navigation basse — destinations filtrées selon le rôle.
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
    '/produits': (
      icon: Icons.local_bar_outlined,
      activeIcon: Icons.local_bar,
    ),
    '/stocks': (
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
    ),
    '/clients': (
      icon: Icons.people_outline,
      activeIcon: Icons.people,
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

    var selected = items.indexWhere((i) => i.route == currentRoute);
    if (selected == -1) selected = 0;

    final estSombre = Theme.of(context).brightness == Brightness.dark;

    final couleurFond = Theme.of(context).colorScheme.surface;
    final couleurOmbre = estSombre
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.06);
    final iconeInactive = estSombre ? AppColors.texteClairSombre : AppColors.texteClair;
    final iconeActive = estSombre ? AppColors.orangeClair : AppColors.bleuFonce;
    final couleurToggle = estSombre ? AppColors.orangeClair : AppColors.bleuFonce;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
              selectedIndex: selected,
              backgroundColor: couleurFond,
              indicatorColor: (estSombre ? AppColors.orangeClair : AppColors.bleuFonce)
                  .withValues(alpha: 0.12),
              elevation: 0,
              height: 66,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) {
                if (items[i].route == currentRoute) return;
                Navigator.pushReplacementNamed(context, items[i].route);
              },
              destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: Icon(
                      _icones[item.route]?.icon ?? Icons.circle_outlined,
                      color: iconeInactive,
                    ),
                    selectedIcon: Icon(
                      _icones[item.route]?.activeIcon ?? Icons.circle,
                      color: iconeActive,
                    ),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -16,
          right: 12,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => Material(
              color: couleurFond,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => themeProvider.basculer(!themeProvider.estSombre),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    themeProvider.estSombre ? Icons.light_mode : Icons.dark_mode,
                    size: 20,
                    color: couleurToggle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
