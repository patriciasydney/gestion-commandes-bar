import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';

/// Barre de navigation basse, persistante sur tous les écrans principaux.
class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  static const _items = [
    (route: '/dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Accueil'),
    (route: '/pos', icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale, label: 'Vente'),
    (route: '/produits', icon: Icons.local_bar_outlined, activeIcon: Icons.local_bar, label: 'Produits'),
    (route: '/stocks', icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Stocks'),
    (route: '/clients', icon: Icons.people_outline, activeIcon: Icons.people, label: 'Clients'),
    (route: '/rapports', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Rapports'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _items.indexWhere((i) => i.route == currentRoute);
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
              selectedIndex: selected == -1 ? 0 : selected,
              backgroundColor: couleurFond,
              indicatorColor: (estSombre ? AppColors.orangeClair : AppColors.bleuFonce)
                  .withValues(alpha: 0.12),
              elevation: 0,
              height: 66,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) {
                if (_items[i].route == currentRoute) return;
                Navigator.pushReplacementNamed(context, _items[i].route);
              },
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon, color: iconeInactive),
                    selectedIcon: Icon(item.activeIcon, color: iconeActive),
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
