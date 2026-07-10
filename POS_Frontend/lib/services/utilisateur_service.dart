import '../core/constants/api_constants.dart';
import '../models/role.dart';
import '../models/utilisateur.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Utilisateur + lecture des rôles.
class UtilisateurService {
  final ApiService _api = ApiService();

  Future<List<Utilisateur>> getAll() async {
    final data = await _api.get(ApiConstants.utilisateurs);
    return (data as List).map((json) => Utilisateur.fromJson(json)).toList();
  }

  Future<Utilisateur> getById(int id) async {
    final data = await _api.get('${ApiConstants.utilisateurs}$id/');
    return Utilisateur.fromJson(data);
  }

  Future<Utilisateur> create(Utilisateur item, {required String password}) async {
    final data = await _api.post(
      ApiConstants.utilisateurs,
      item.toCreateJson(password: password),
    );
    return Utilisateur.fromJson(data);
  }

  Future<Utilisateur> update(int id, Utilisateur item) async {
    final data = await _api.put('${ApiConstants.utilisateurs}$id/', item.toJson());
    return Utilisateur.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.utilisateurs}$id/');
  }

  Future<List<Role>> getRoles() async {
    final data = await _api.get(ApiConstants.roles);
    return (data as List).map((json) => Role.fromJson(json)).toList();
  }
}
