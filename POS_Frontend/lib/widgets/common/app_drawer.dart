import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';

/// Menu latéral de navigation — items filtrés selon le rôle connecté.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _icones = {
    '/dashboard': Icons.dashboard,
    '/pos': Icons.point_of_sale,
    '/produits': Icons.local_bar,
    '/categories': Icons.category,
    '/stocks': Icons.inventory_2,
    '/fournisseurs': Icons.local_shipping,
    '/clients': Icons.people,
    '/achats': Icons.shopping_cart,
    '/depenses': Icons.receipt_long,
    '/utilisateurs': Icons.admin_panel_settings,
    '/rapports': Icons.bar_chart,
    '/parametres': Icons.settings,
  };

  Future<void> _deconnecter(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion", style: TextStyle(color: AppColors.rouge)),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;

    context.read<AuthProvider>().deconnecter();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final utilisateur = auth.utilisateur;
    final items = RolePermissions.itemsMenuLateral(utilisateur);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.bleuFonce),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/logo_atsys.png',
                  height: 48,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.local_bar, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 8),
                const Text(
                  "ATSYS_POS",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (utilisateur != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${utilisateur.prenom} ${utilisateur.nom}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (utilisateur.nomRole.isNotEmpty)
                    Text(
                      utilisateur.nomRole,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                ],
              ],
            ),
          ),
          for (final item in items)
            ListTile(
              leading: Icon(_icones[item.route] ?? Icons.circle_outlined),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name == item.route) return;
                Navigator.pushReplacementNamed(context, item.route);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.rouge),
            title: const Text("Déconnexion", style: TextStyle(color: AppColors.rouge)),
            onTap: () => _deconnecter(context),
          ),
        ],
      ),
    );
  }
}
