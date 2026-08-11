import 'package:flutter/material.dart';

import '../../core/theme/theme_helpers.dart';

/// ChoiceChip cohérent avec le thème clair/sombre.
class FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  const FilterChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ThemeHelpers.chipColors(context, selected: selected);

    return ChoiceChip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? colors.iconSelected : colors.iconUnselected,
            ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: colors.selectedColor,
      backgroundColor: ThemeHelpers.fill(context),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? colors.labelSelected : colors.labelUnselected,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: selected ? colors.sideSelected : colors.sideUnselected,
    );
  }
}

/// Champ de recherche avec fond adapté au thème.
InputDecoration themedSearchDecoration(BuildContext context, {required String hint}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: const Icon(Icons.search),
    filled: true,
    fillColor: ThemeHelpers.fill(context),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
