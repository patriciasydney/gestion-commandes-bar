import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: NavigationBar(
          selectedIndex: selected == -1 ? 0 : selected,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.bleuFonce.withValues(alpha: 0.12),
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
                icon: Icon(item.icon, color: AppColors.texteClair),
                selectedIcon: Icon(item.activeIcon, color: AppColors.bleuFonce),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
