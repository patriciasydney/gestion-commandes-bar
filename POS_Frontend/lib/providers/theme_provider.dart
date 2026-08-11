import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le thème choisi explicitement par l'utilisateur (clair / sombre)
/// et le persiste localement, indépendamment du thème système du téléphone.
class ThemeProvider extends ChangeNotifier {
  static const _cle = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get estSombre => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _charger();
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final valeur = prefs.getString(_cle);
    _themeMode = (valeur == 'dark') ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> basculer(bool sombre) async {
    _themeMode = sombre ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, sombre ? 'dark' : 'light');
  }
}
