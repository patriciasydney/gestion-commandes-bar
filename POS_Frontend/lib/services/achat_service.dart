import '../core/constants/api_constants.dart';
import '../core/utils/date_range.dart';
import '../models/achat.dart';
import 'api_service.dart';

/// Achats — aligné sur `AchatCreateSerializer` (DRF).
class AchatService {
  final ApiService _api = ApiService();

  Future<List<Achat>> getAll({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final query = DateRange.queryParams(
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    final data = await _api.get('${ApiConstants.achats}$query');
    return (data as List)
        .map((json) => Achat.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Achat> getById(int id) async {
    final data = await _api.get('${ApiConstants.achats}$id/');
    return Achat.fromJson(data as Map<String, dynamic>);
  }

  /// Crée un achat : `fournisseur` + `details[]` (`produit`, `quantite`, `prix_unitaire`).
  Future<Achat> creerAvecDetails({
    required int fournisseur,
    required List<Map<String, dynamic>> details,
  }) async {
    final data = await _api.post(
      ApiConstants.achats,
      Achat.toCreateJson(fournisseur: fournisseur, details: details),
    );
    return Achat.fromJson(data as Map<String, dynamic>);
  }
}
