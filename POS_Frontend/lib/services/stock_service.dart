import '../core/constants/api_constants.dart';
import '../models/stock.dart';
import '../models/mouvement_stock.dart';
import 'api_service.dart';

/// Stocks et mouvements — aligné sur `StockViewSet` / `MouvementStockViewSet` (DRF).
class StockService {
  final ApiService _api = ApiService();

  Future<List<Stock>> getAll() async {
    final data = await _api.get(ApiConstants.stocks);
    return (data as List).map((json) => Stock.fromJson(json)).toList();
  }

  Future<Stock> getById(int id) async {
    final data = await _api.get('${ApiConstants.stocks}$id/');
    return Stock.fromJson(data);
  }

  Future<Stock?> getByProduit(int idProduit) async {
    final tous = await getAll();
    for (final s in tous) {
      if (s.produit == idProduit) return s;
    }
    return null;
  }

  /// `POST /stocks/{id}/ajuster/` — `AjustementStockSerializer`.
  /// [quantite] signée : positif = entrée, négatif = sortie.
  Future<Stock> ajuster(
    int idStock, {
    required int quantite,
    String? referenceOperation,
  }) async {
    final payload = <String, dynamic>{'quantite': quantite};
    if (referenceOperation != null && referenceOperation.isNotEmpty) {
      payload['reference_operation'] = referenceOperation;
    }
    final data = await _api.post('${ApiConstants.stocks}$idStock/ajuster/', payload);
    return Stock.fromJson(data);
  }

  Future<List<MouvementStock>> getMouvements({int? produitId}) async {
    final endpoint = produitId != null
        ? '${ApiConstants.mouvementsStock}?produit=$produitId'
        : ApiConstants.mouvementsStock;
    final data = await _api.get(endpoint);
    return (data as List).map((json) => MouvementStock.fromJson(json)).toList();
  }
}
