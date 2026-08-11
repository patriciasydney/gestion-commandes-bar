import '../core/constants/api_constants.dart';
import '../models/categorie.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Categorie.
class CategorieService {
  final ApiService _api = ApiService();

  Future<List<Categorie>> getAll() async {
    final data = await _api.get(ApiConstants.categories);
    return (data as List).map((json) => Categorie.fromJson(json)).toList();
  }

  Future<Categorie> getById(int id) async {
    final data = await _api.get('${ApiConstants.categories}$id/');
    return Categorie.fromJson(data);
  }

  Future<Categorie> create(Categorie item) async {
    final data = await _api.post(ApiConstants.categories, item.toJson());
    return Categorie.fromJson(data);
  }

  Future<Categorie> update(int id, Categorie item) async {
    final data = await _api.put('${ApiConstants.categories}$id/', item.toJson());
    return Categorie.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.categories}$id/');
  }
}
