import 'package:flutter/foundation.dart';

import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';
import '../services/rapport_service.dart';
import '../core/utils/date_range.dart';

/// État du tableau de bord — aligné sur `/dashboard/summary/` + rapports mois / 7j.
class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();
  final RapportService _rapportService = RapportService();

  bool chargement = false;
  String? erreur;

  DateTime? dateJour;
  double chiffreAffairesJour = 0;
  int nombreVentes = 0;
  double depensesJour = 0;
  List<ProduitStockFaible> stocksFaibles = [];

  double chiffreAffairesMois = 0;
  int nombreVentesMois = 0;
  double depensesMois = 0;
  double panierMoyen = 0;

  List<num> ventesParJour = List.filled(7, 0);
  List<String> labelsGraphique = const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  Future<void> chargerDonnees() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      final summary = await _dashboardService.getSummary();
      dateJour = summary.date;
      chiffreAffairesJour = summary.chiffreAffairesJour;
      nombreVentes = summary.nombreTicketsJour;
      depensesJour = summary.depensesJour;
      stocksFaibles = summary.produitsStockFaible;

      final presetMois = DateRange.depuisPreset('mois');
      final rapportMois = await _rapportService.getVentes(
        dateDebut: presetMois.debut,
        dateFin: presetMois.fin,
      );
      chiffreAffairesMois = rapportMois.totalVentes;
      nombreVentesMois = rapportMois.nombreVentes;
      panierMoyen = nombreVentesMois > 0 ? chiffreAffairesMois / nombreVentesMois : 0;

      final depensesMoisList = await _rapportService.getDepensesParCategorie(
        dateDebut: presetMois.debut,
        dateFin: presetMois.fin,
      );
      depensesMois = depensesMoisList.fold<double>(0, (s, d) => s + d.total);

      final preset7j = DateRange.septDerniersJours();
      final rapport7j = await _rapportService.getVentes(
        dateDebut: preset7j.debut,
        dateFin: preset7j.fin,
      );
      ventesParJour = rapport7j.ventesSeptJours();
      labelsGraphique = _labelsSeptJours(preset7j.debut);
    } catch (e) {
      erreur = e.toString();
    }

    chargement = false;
    notifyListeners();
  }

  List<String> _labelsSeptJours(DateTime debut) {
    const jours = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return List.generate(7, (i) {
      final d = debut.add(Duration(days: i));
      return jours[d.weekday - 1];
    });
  }
}
