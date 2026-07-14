import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Utilitaires pour éviter les couleurs en dur (blanc, fond clair…) hors thème.
abstract final class ThemeHelpers {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color fill(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color border(BuildContext context) => Theme.of(context).dividerColor;

  static Color mutedText(BuildContext context) =>
      isDark(context) ? AppColors.texteClairSombre : AppColors.texteClair;

  static Color accent(BuildContext context) =>
      isDark(context) ? AppColors.orangeClair : AppColors.bleuFonce;

  static Color onAccent(BuildContext context) =>
      isDark(context) ? AppColors.fondSombre : Colors.white;

  static Color progressTrack(BuildContext context) =>
      isDark(context) ? AppColors.surfaceAltSombre : AppColors.fond;

  static TextStyle? mutedTextStyle(BuildContext context, {double? fontSize}) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
            color: mutedText(context),
            fontSize: fontSize,
          );

  static BoxDecoration cardDecoration(BuildContext context, {double radius = 12}) {
    return BoxDecoration(
      color: surface(context),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border(context)),
      boxShadow: isDark(context)
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  /// Style unifié pour les ChoiceChip / filtres de période ou catégorie.
  static ({
    Color selectedColor,
    Color labelSelected,
    Color labelUnselected,
    Color iconSelected,
    Color iconUnselected,
    BorderSide sideSelected,
    BorderSide sideUnselected,
  }) chipColors(BuildContext context, {required bool selected}) {
    final selectedColor = accent(context);
    return (
      selectedColor: selectedColor,
      labelSelected: onAccent(context),
      labelUnselected: mutedText(context),
      iconSelected: onAccent(context),
      iconUnselected: mutedText(context),
      sideSelected: BorderSide(color: selectedColor),
      sideUnselected: BorderSide(color: border(context)),
    );
  }
}
