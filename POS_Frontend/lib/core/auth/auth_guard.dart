import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../screens/auth/login_screen.dart';

/// Redirige vers le login si la session JWT n'est pas active.
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.sessionInitialisee) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!auth.estConnecte) {
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}

/// Point d'entrée : restaure la session puis route login ou dashboard.
class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.sessionInitialisee) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.estConnecte) {
          return AppRoutes.routes[AppRoutes.dashboard]!(context);
        }
        return const LoginScreen();
      },
    );
  }
}
