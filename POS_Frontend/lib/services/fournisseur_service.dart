import '../core/constants/api_constants.dart';
import '../models/fournisseur.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Fournisseur.
class FournisseurService {
  final ApiService _api = ApiService();

  Future<List<Fournisseur>> getAll() async {
    final data = await _api.get(ApiConstants.fournisseurs);
    return (data as List).map((json) => Fournisseur.fromJson(json)).toList();
  }

  Future<Fournisseur> getById(int id) async {
    final data = await _api.get('${ApiConstants.fournisseurs}$id/');
    return Fournisseur.fromJson(data);
  }

  Future<Fournisseur> create(Fournisseur item) async {
    final data = await _api.post(ApiConstants.fournisseurs, item.toJson());
    return Fournisseur.fromJson(data);
  }

  Future<Fournisseur> update(int id, Fournisseur item) async {
    final data = await _api.put('${ApiConstants.fournisseurs}$id/', item.toJson());
    return Fournisseur.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.fournisseurs}$id/');
  }
}
