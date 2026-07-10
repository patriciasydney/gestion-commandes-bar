import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/utilisateur.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

const _cleAccessToken = 'access_token';
const _cleRefreshToken = 'refresh_token';
const _cleUtilisateur = 'utilisateur';

/// État de connexion, partagé dans toute l'application via Provider.
class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? api, AuthService? authService})
      : _api = api ?? ApiService(),
        _authService = authService ?? AuthService(api: api ?? ApiService()) {
    _restaurerSession();
  }

  final ApiService _api;
  final AuthService _authService;

  Utilisateur? _utilisateurConnecte;
  String? _token;
  String? _refreshToken;
  bool chargement = false;
  bool sessionInitialisee = false;
  String? erreur;

  bool get estConnecte => _token != null;
  Utilisateur? get utilisateur => _utilisateurConnecte;

  Future<void> _restaurerSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final access = prefs.getString(_cleAccessToken);
      if (access != null) {
        _token = access;
        _refreshToken = prefs.getString(_cleRefreshToken);
        _api.setToken(_token);

        final utilisateurJson = prefs.getString(_cleUtilisateur);
        if (utilisateurJson != null) {
          _utilisateurConnecte = Utilisateur.fromJson(
            jsonDecode(utilisateurJson) as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      await _effacerSession(silencieux: true);
    } finally {
      sessionInitialisee = true;
      notifyListeners();
    }
  }

  Future<bool> connecter(String username, String motDePasse) async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      final data = await _authService.login(username, motDePasse);
      _token = data['access'] as String?;
      _refreshToken = data['refresh'] as String?;
      _utilisateurConnecte = data['utilisateur'] != null
          ? Utilisateur.fromJson(data['utilisateur'] as Map<String, dynamic>)
          : null;

      _api.setToken(_token);
      await _persisterSession(data['utilisateur'] as Map<String, dynamic>?);

      chargement = false;
      notifyListeners();
      return _token != null;
    } catch (e) {
      erreur = "Identifiant ou mot de passe incorrect";
      chargement = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deconnecter() async {
    await _authService.logout();
    await _effacerSession();
    notifyListeners();
  }

  Future<void> _persisterSession(Map<String, dynamic>? utilisateurBackend) async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_cleAccessToken, _token!);
    } else {
      await prefs.remove(_cleAccessToken);
    }
    if (_refreshToken != null) {
      await prefs.setString(_cleRefreshToken, _refreshToken!);
    } else {
      await prefs.remove(_cleRefreshToken);
    }
    if (utilisateurBackend != null) {
      await prefs.setString(_cleUtilisateur, jsonEncode(utilisateurBackend));
    } else {
      await prefs.remove(_cleUtilisateur);
    }
  }

  Future<void> _effacerSession({bool silencieux = false}) async {
    _token = null;
    _refreshToken = null;
    _utilisateurConnecte = null;
    _api.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cleAccessToken);
    await prefs.remove(_cleRefreshToken);
    await prefs.remove(_cleUtilisateur);

    if (!silencieux) notifyListeners();
  }
}
