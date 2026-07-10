import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_guard.dart';
import 'core/theme/app_theme.dart';
import 'providers/caisse_provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'providers/dashboard_provider.dart';
import 'providers/produit_provider.dart';
import 'providers/categorie_provider.dart';
import 'providers/panier_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/utilisateur_provider.dart';
import 'routes/app_routes.dart';

void main() {
  // Verrouille l'orientation en mode portrait uniquement
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure le style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const FrontBoissonApp());
}

class FrontBoissonApp extends StatelessWidget {
  const FrontBoissonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(api: api)),
        ChangeNotifierProvider(create: (_) => CaisseProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProduitProvider()),
        ChangeNotifierProvider(create: (_) => CategorieProvider()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => UtilisateurProvider()),
      ],
      child: MaterialApp(
        title: 'POS Débits de Boissons',
        debugShowCheckedModeBanner: false,
        
        // Thème clair (par défaut)
        theme: AppTheme.theme,
        
        // Thème sombre (automatique selon le système)
        darkTheme: AppTheme.darkTheme,
        
        // Mode de thème : auto (suit les préférences système)
        // Tu peux changer pour ThemeMode.light ou ThemeMode.dark si besoin
        themeMode: ThemeMode.system,
        
        // Point d'entrée : session JWT ou login
        initialRoute: AppRoutes.entry,

        // Table de routage
        routes: {
          AppRoutes.entry: (context) => const AppEntry(),
          ...AppRoutes.routes,
        },

        // Configuration des transitions de page
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.entry) {
            return MaterialPageRoute(
              builder: (_) => const AppEntry(),
              settings: settings,
            );
          }

          final builder = AppRoutes.routes[settings.name];
          if (builder != null) {
            if (settings.name == AppRoutes.login) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }
            return MaterialPageRoute(
              builder: (context) => AuthGuard(child: builder(context)),
              settings: settings,
            );
          }
          return null;
        },
        
        // Gestion des routes inconnues
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Page introuvable')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'La route "${settings.name}" n\'existe pas',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                      child: const Text('Retour au tableau de bord'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
