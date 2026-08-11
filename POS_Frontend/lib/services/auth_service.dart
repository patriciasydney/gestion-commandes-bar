import '../core/constants/api_constants.dart';
import 'api_service.dart';

/// Gère la connexion/déconnexion auprès du backend Django (SimpleJWT).
class AuthService {
  AuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  /// Payload attendu par `POST /api/auth/login/` : username + password.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _api.post(ApiConstants.login, {
      'username': username,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    // Invalidation côté serveur : à brancher si un endpoint blacklist est ajouté.
  }
}
