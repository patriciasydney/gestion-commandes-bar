import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_helpers.dart';
import '../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/sales_chart.dart';
import '../../widgets/dashboard/stock_alert_tile.dart';
import '../../widgets/dashboard/quick_access_button.dart';

/// Écran : Tableau de bord — cahier des charges §10.3
/// Version améliorée avec design moderne et indicateurs de tendance
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().chargerDonnees();
    });
  }

  Widget _sectionHeader(BuildContext context, String titre, IconData icone, {String? sousTitre}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeHelpers.accent(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: ThemeHelpers.accent(context), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre,
                    style: ThemeHelpers.mutedTextStyle(context, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(currentRoute: '/dashboard'),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.chargement) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeHelpers.accent(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des données...',
                    style: ThemeHelpers.mutedTextStyle(context),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.chargerDonnees(),
            color: ThemeHelpers.accent(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bandeau d'accueil avec date
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.bleuFonce, AppColors.bleuFonce.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bleuFonce.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjour 👋',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.date(DateTime.now()),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: () => provider.chargerDonnees(),
                              tooltip: 'Actualiser',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Message d'erreur si nécessaire
                  if (provider.erreur != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.rouge.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.rouge.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.rouge, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.erreur!,
                              style: const TextStyle(color: AppColors.rouge, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section Accès rapide
                  _sectionHeader(context, 'Accès rapide', Icons.rocket_launch),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      QuickAccessButton(
                        label: "Vente (POS)",
                        icone: Icons.point_of_sale,
                        couleur: AppColors.bleuFonce,
                        onTap: () => Navigator.pushNamed(context, '/pos'),
                      ),
                      QuickAccessButton(
                        label: "Produits",
                        icone: Icons.local_bar,
                        couleur: AppColors.orange,
                        onTap: () => Navigator.pushNamed(context, '/produits'),
                      ),
                      QuickAccessButton(
                        label: "Stocks",
                        icone: Icons.inventory_2,
                        couleur: AppColors.jaune,
                        onTap: () => Navigator.pushNamed(context, '/stocks'),
                      ),
                      QuickAccessButton(
                        label: "Achats",
                        icone: Icons.shopping_cart,
                        couleur: AppColors.vert,
                        onTap: () => Navigator.pushNamed(context, '/achats'),
                      ),
                      QuickAccessButton(
                        label: "Clients",
                        icone: Icons.people,
                        couleur: AppColors.bleuFonce,
                        onTap: () => Navigator.pushNamed(context, '/clients'),
                      ),
                      QuickAccessButton(
                        label: "Rapports",
                        icone: Icons.bar_chart,
                        couleur: AppColors.orange,
                        onTap: () => Navigator.pushNamed(context, '/rapports'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section Aujourd'hui
                  _sectionHeader(
                    context,
                    "Aujourd'hui",
                    Icons.today,
                    sousTitre: 'Performance en temps réel',
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        titre: "Chiffre d'affaires",
                        valeur: Formatters.montant(provider.chiffreAffairesJour),
                        icone: Icons.payments,
                        couleur: AppColors.vert,
                      ),
                      StatCard(
                        titre: "Ventes du jour",
                        valeur: provider.nombreVentes.toString(),
                        icone: Icons.point_of_sale,
                        couleur: AppColors.bleuFonce,
                      ),
                      StatCard(
                        titre: "Stocks en alerte",
                        valeur: provider.stocksFaibles.length.toString(),
                        icone: Icons.warning_amber,
                        couleur: provider.stocksFaibles.isNotEmpty ? AppColors.rouge : AppColors.vert,
                      ),
                      StatCard(
                        titre: "Dépenses du jour",
                        valeur: Formatters.montant(provider.depensesJour),
                        icone: Icons.trending_down,
                        couleur: AppColors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section Ce mois-ci
                  _sectionHeader(
                    context,
                    "Ce mois-ci",
                    Icons.calendar_month,
                    sousTitre: 'Vue d\'ensemble mensuelle',
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        titre: "CA du mois",
                        valeur: Formatters.montant(provider.chiffreAffairesMois),
                        icone: Icons.calendar_month,
                        couleur: AppColors.vert,
                      ),
                      StatCard(
                        titre: "Ventes du mois",
                        valeur: provider.nombreVentesMois.toString(),
                        icone: Icons.receipt_long,
                        couleur: AppColors.bleuFonce,
                      ),
                      StatCard(
                        titre: "Dépenses du mois",
                        valeur: Formatters.montant(provider.depensesMois),
                        icone: Icons.money_off,
                        couleur: AppColors.orange,
                      ),
                      StatCard(
                        titre: "Panier moyen",
                        valeur: Formatters.montant(provider.panierMoyen),
                        icone: Icons.shopping_basket,
                        couleur: AppColors.jaune,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section Graphique
                  _sectionHeader(
                    context,
                    'Évolution des ventes',
                    Icons.trending_up,
                    sousTitre: '7 derniers jours',
                  ),
                  SalesChart(
                    ventesParJour: provider.ventesParJour,
                    labels: provider.labelsGraphique,
                  ),
                  const SizedBox(height: 28),

                  // Alertes stock
                  _sectionHeader(
                    context,
                    'Alertes stock',
                    Icons.inventory_2_outlined,
                    sousTitre: 'Produits sous le seuil minimum',
                  ),
                  if (provider.stocksFaibles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: ThemeHelpers.cardDecoration(context, radius: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.vert),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aucune alerte stock — niveaux OK',
                              style: ThemeHelpers.mutedTextStyle(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: ThemeHelpers.cardDecoration(context, radius: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < provider.stocksFaibles.length; i++) ...[
                            StockAlertTile(alerte: provider.stocksFaibles[i]),
                            if (i < provider.stocksFaibles.length - 1)
                              Divider(
                                height: 1,
                                color: ThemeHelpers.border(context).withValues(alpha: 0.5),
                              ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
