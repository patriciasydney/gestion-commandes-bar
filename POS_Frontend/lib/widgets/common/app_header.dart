import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';

/// Header avec cloche de notifications (tous les rôles) + thème + paramètres.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSettingsIcon;
  final bool showNotificationsIcon;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showSettingsIcon = true,
    this.showNotificationsIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (actions != null) ...actions!,

        if (showNotificationsIcon)
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              final count = notifProvider.nonLues;
              return IconButton(
                tooltip: 'Notifications',
                onPressed: () =>
                    Navigator.pushNamed(context, '/notifications'),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: Icon(
                    count > 0
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          ),

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
