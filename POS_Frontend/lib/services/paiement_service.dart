import '../core/constants/api_constants.dart';
import '../models/paiement.dart';
import 'api_service.dart';

/// Appels CRUD vers l'API Django pour Paiement.
class PaiementService {
  final ApiService _api = ApiService();

  Future<List<Paiement>> getAll() async {
    final data = await _api.get(ApiConstants.paiements);
    return (data as List).map((json) => Paiement.fromJson(json)).toList();
  }

  Future<Paiement> create(Paiement item) async {
    final data = await _api.post(ApiConstants.paiements, item.toJson());
    return Paiement.fromJson(data);
  }
}
