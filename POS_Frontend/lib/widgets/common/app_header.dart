import 'package:flutter/material.dart';

/// Header personnalisé qui ajoute automatiquement l'icône de paramètres
/// en haut à droite de chaque écran.
///
/// Utilise-le à la place de `AppBar` dans tous les écrans principaux.
///
/// Exemple :
/// ```dart
/// appBar: const AppHeader(title: 'Gestion des produits'),
/// ```
///
/// Pour ajouter des actions supplémentaires :
/// ```dart
/// appBar: AppHeader(
///   title: 'Rapports',
///   actions: [
///     IconButton(icon: Icon(Icons.download), onPressed: _exporter),
///   ],
/// ),
/// ```
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
        // Actions personnalisées de l'écran (ex: bouton export)
        if (actions != null) ...actions!,

        // Icône paramètres (toujours en dernier, à droite)
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
