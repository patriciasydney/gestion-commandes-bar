import '../core/constants/api_constants.dart';
import '../models/caisse.dart';
import 'api_service.dart';

/// Caisses — aligné sur `CaisseViewSet` (DRF).
class CaisseService {
  final ApiService _api = ApiService();

  Future<List<Caisse>> getAll() async {
    final data = await _api.get(ApiConstants.caisses);
    return (data as List).map((json) => Caisse.fromJson(json)).toList();
  }

  Future<Caisse> getById(int id) async {
    final data = await _api.get('${ApiConstants.caisses}$id/');
    return Caisse.fromJson(data);
  }

  /// Ouvre une caisse — `utilisateur` injecté côté serveur.
  Future<Caisse> ouvrir({double montantInitial = 0}) async {
    final data = await _api.post(
      ApiConstants.caisses,
      Caisse.toOpenJson(montantInitial: montantInitial),
    );
    return Caisse.fromJson(data);
  }

  /// `POST /caisses/{id}/fermer/`
  Future<Caisse> fermer(int idCaisse, {required double montantFinal}) async {
    final data = await _api.post(
      '${ApiConstants.caisses}$idCaisse/fermer/',
      {'montant_final': montantFinal},
    );
    return Caisse.fromJson(data);
  }
}
