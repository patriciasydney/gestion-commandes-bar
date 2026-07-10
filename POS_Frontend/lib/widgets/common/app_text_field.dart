import 'package:flutter/material.dart';

/// Champ de texte stylé réutilisable, avec validation intégrée.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool motDePasse;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.motDePasse = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: motDePasse,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
