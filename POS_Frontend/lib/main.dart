import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_guard.dart';
import 'core/auth/role_guard.dart';
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
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.estSombre ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.estSombre ? Brightness.dark : Brightness.light,
          ));

          return MaterialApp(
            title: 'POS Débits de Boissons',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.entry,
            routes: {
              AppRoutes.entry: (context) => const AppEntry(),
              ...AppRoutes.routes,
            },
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
                final routeName = settings.name!;
                return MaterialPageRoute(
                  builder: (context) => AuthGuard(
                    child: RoleGuard(
                      route: routeName,
                      titre: routeTitles[routeName] ?? 'ATSYS_POS',
                      child: builder(context),
                    ),
                  ),
                  settings: settings,
                );
              }
              return null;
            },
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
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/dashboard'),
                          child: const Text('Retour au tableau de bord'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
