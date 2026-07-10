import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Menu latéral de navigation entre les modules de l'application.
/// Permet de tester la navigation entre tous les écrans dès aujourd'hui,
/// même avant que chaque écran soit pleinement fonctionnel.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _items = [
    ("Tableau de bord", Icons.dashboard, "/dashboard"),
    ("Point de vente", Icons.point_of_sale, "/pos"),
    ("Produits", Icons.local_bar, "/produits"),
    ("Catégories", Icons.category, "/categories"),
    ("Stocks", Icons.inventory_2, "/stocks"),
    ("Fournisseurs", Icons.local_shipping, "/fournisseurs"),
    ("Clients", Icons.people, "/clients"),
    ("Achats", Icons.shopping_cart, "/achats"),
    ("Dépenses", Icons.receipt_long, "/depenses"),
    ("Utilisateurs", Icons.admin_panel_settings, "/utilisateurs"),
    ("Rapports", Icons.bar_chart, "/rapports"),
    ("Paramètres", Icons.settings, "/parametres"),
  ];

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
    final utilisateur = context.watch<AuthProvider>().utilisateur;

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
                ],
              ],
            ),
          ),
          for (final (label, icone, route) in _items)
            ListTile(
              leading: Icon(icone),
              title: Text(label),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, route);
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
