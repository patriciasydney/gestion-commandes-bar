import '../core/constants/api_constants.dart';
import '../models/depense.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Depense.
class DepenseService {
  final ApiService _api = ApiService();

  Future<List<Depense>> getAll() async {
    final data = await _api.get(ApiConstants.depenses);
    return (data as List).map((json) => Depense.fromJson(json)).toList();
  }

  Future<Depense> getById(int id) async {
    final data = await _api.get('${ApiConstants.depenses}$id/');
    return Depense.fromJson(data);
  }

  Future<Depense> create(Depense item) async {
    final data = await _api.post(ApiConstants.depenses, item.toJson());
    return Depense.fromJson(data);
  }

  Future<Depense> update(int id, Depense item) async {
    final data = await _api.put('${ApiConstants.depenses}$id/', item.toJson());
    return Depense.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.depenses}$id/');
  }
}
