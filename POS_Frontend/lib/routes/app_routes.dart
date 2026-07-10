import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/pos/pos_screen.dart';
import '../screens/produits/produits_screen.dart';
import '../screens/produits/produit_form_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/stocks/stocks_screen.dart';
import '../screens/fournisseurs/fournisseurs_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/achats/achats_screen.dart';
import '../screens/depenses/depenses_screen.dart';
import '../screens/utilisateurs/utilisateurs_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/parametres/parametres_screen.dart';

/// Table de routage nommée de l'application.
class AppRoutes {
  AppRoutes._();

  static const String entry = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String produits = '/produits';
  static const String produitForm = '/produits/form';
  static const String categories = '/categories';
  static const String stocks = '/stocks';
  static const String fournisseurs = '/fournisseurs';
  static const String clients = '/clients';
  static const String achats = '/achats';
  static const String depenses = '/depenses';
  static const String utilisateurs = '/utilisateurs';
  static const String rapports = '/rapports';
  static const String parametres = '/parametres';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        dashboard: (context) => const DashboardScreen(),
        pos: (context) => const PosScreen(),
        produits: (context) => const ProduitsScreen(),
        produitForm: (context) => const ProduitFormScreen(),
        categories: (context) => const CategoriesScreen(),
        stocks: (context) => const StocksScreen(),
        fournisseurs: (context) => const FournisseursScreen(),
        clients: (context) => const ClientsScreen(),
        achats: (context) => const AchatsScreen(),
        depenses: (context) => const DepensesScreen(),
        utilisateurs: (context) => const UtilisateursScreen(),
        rapports: (context) => const RapportsScreen(),
        parametres: (context) => const ParametresScreen(),
      };
}
