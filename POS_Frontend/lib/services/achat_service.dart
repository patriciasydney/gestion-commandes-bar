import '../core/constants/api_constants.dart';
import '../models/achat.dart';
import 'api_service.dart';

/// Achats — aligné sur `AchatCreateSerializer` (DRF).
class AchatService {
  final ApiService _api = ApiService();

  Future<List<Achat>> getAll() async {
    final data = await _api.get(ApiConstants.achats);
    return (data as List).map((json) => Achat.fromJson(json)).toList();
  }

  Future<Achat> getById(int id) async {
    final data = await _api.get('${ApiConstants.achats}$id/');
    return Achat.fromJson(data);
  }

  /// Crée un achat : `fournisseur` + `details[]` (`produit`, `quantite`, `prix_unitaire`).
  /// `utilisateur` et `statut` sont gérés côté backend.
  Future<Achat> creerAvecDetails({
    required int fournisseur,
    required List<Map<String, dynamic>> details,
  }) async {
    final data = await _api.post(
      ApiConstants.achats,
      Achat.toCreateJson(fournisseur: fournisseur, details: details),
    );
    return Achat.fromJson(data);
  }
}
