import '../core/constants/api_constants.dart';
import '../models/produit.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Produit.
class ProduitService {
  final ApiService _api = ApiService();

  Future<List<Produit>> getAll() async {
    final data = await _api.get(ApiConstants.produits);
    return (data as List).map((json) => Produit.fromJson(json)).toList();
  }

  Future<Produit> getById(int id) async {
    final data = await _api.get('${ApiConstants.produits}$id/');
    return Produit.fromJson(data);
  }

  Future<Produit> create(Produit item) async {
    final data = await _api.post(ApiConstants.produits, item.toJson());
    return Produit.fromJson(data);
  }

  Future<Produit> update(int id, Produit item) async {
    final data = await _api.put('${ApiConstants.produits}$id/', item.toJson());
    return Produit.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConstants.produits}$id/');
  }
}
