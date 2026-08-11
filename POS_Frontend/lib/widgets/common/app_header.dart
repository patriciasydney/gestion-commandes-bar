import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

/// Header personnalisé qui ajoute automatiquement l'icône de paramètres
/// en haut à droite de chaque écran.
///
/// Utilise-le à la place de `AppBar` dans tous les écrans principaux.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSettingsIcon;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showSettingsIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (actions != null) ...actions!,

        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => IconButton(
            icon: Icon(
              themeProvider.estSombre ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white70,
            ),
            tooltip: themeProvider.estSombre
                ? 'Passer au thème clair'
                : 'Passer au thème sombre',
            onPressed: () => themeProvider.basculer(!themeProvider.estSombre),
          ),
        ),

        if (showSettingsIcon)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white70),
              tooltip: 'Paramètres',
              onPressed: () => Navigator.pushNamed(context, '/parametres'),
            ),
          ),
      ],
    );
  }
}
