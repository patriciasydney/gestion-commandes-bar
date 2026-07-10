import '../core/constants/api_constants.dart';
import '../core/utils/date_range.dart';
import '../models/rapport.dart';
import 'api_service.dart';

/// Rapports — `GET /reports/ventes|produits|depenses/` avec `date_debut` / `date_fin`.
class RapportService {
  final ApiService _api = ApiService();

  Future<RapportVentes> getVentes({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final query = DateRange.queryParams(dateDebut: dateDebut, dateFin: dateFin);
    final data = await _api.get('${ApiConstants.reportsVentes}$query');
    return RapportVentes.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TopProduitVendu>> getTopProduits({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final query = DateRange.queryParams(dateDebut: dateDebut, dateFin: dateFin);
    final data = await _api.get('${ApiConstants.reportsProduits}$query');
    final json = data as Map<String, dynamic>;
    return (json['top_produits'] as List? ?? [])
        .map((e) => TopProduitVendu.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DepenseParCategorie>> getDepensesParCategorie({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final query = DateRange.queryParams(dateDebut: dateDebut, dateFin: dateFin);
    final data = await _api.get('${ApiConstants.reportsDepenses}$query');
    final json = data as Map<String, dynamic>;
    return (json['par_categorie'] as List? ?? [])
        .map((e) => DepenseParCategorie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RapportAchats> getAchats({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final query = DateRange.queryParams(dateDebut: dateDebut, dateFin: dateFin);
    final data = await _api.get('${ApiConstants.reportsAchats}$query');
    return RapportAchats.fromJson(data as Map<String, dynamic>);
  }

  /// Agrège les endpoints pour l'écran Rapports.
  Future<RapportComplet> genererRapport({required String periode}) async {
    final preset = DateRange.depuisPreset(periode);

    final ventes = await getVentes(dateDebut: preset.debut, dateFin: preset.fin);
    final topProduits = await getTopProduits(dateDebut: preset.debut, dateFin: preset.fin);
    final depenses = await getDepensesParCategorie(
      dateDebut: preset.debut,
      dateFin: preset.fin,
    );
    final achats = await getAchats(dateDebut: preset.debut, dateFin: preset.fin);

    final depensesTotal = depenses.fold<double>(0, (sum, d) => sum + d.total);

    return RapportComplet(
      libellePeriode: preset.libelle,
      chiffreAffaires: ventes.totalVentes,
      nombreVentes: ventes.nombreVentes,
      depensesTotal: depensesTotal,
      achatsTotal: achats.totalAchats,
      nombreAchats: achats.nombreAchats,
      topProduits: topProduits,
      depensesParCategorie: depenses,
      achatsParFournisseur: achats.parFournisseur,
    );
  }
}
