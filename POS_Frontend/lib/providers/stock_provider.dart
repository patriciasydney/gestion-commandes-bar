import 'package:flutter/foundation.dart';
import '../models/stock.dart';
import '../models/mouvement_stock.dart';
import '../services/stock_service.dart';

/// État des stocks — écran Stocks (§10.6).
class StockProvider extends ChangeNotifier {
  final StockService _service = StockService();

  List<Stock> _stocks = [];
  List<MouvementStock> _mouvements = [];
  bool chargement = false;
  bool enregistrMouvementEnCours = false;
  String? erreur;

  bool _filtreAlerteSeulement = false;

  List<Stock> get stocks => _stocks.where((s) {
        if (_filtreAlerteSeulement && !s.enAlerte && s.quantiteDisponible > s.seuilAlerte) {
          return false;
        }
        return true;
      }).toList();

  List<Stock> get tousLesStocks => List.unmodifiable(_stocks);

  List<MouvementStock> get mouvements =>
      List<MouvementStock>.from(_mouvements)
        ..sort((a, b) => b.dateMouvement.compareTo(a.dateMouvement));

  List<Stock> get stocksEnAlerte =>
      _stocks.where((s) => s.enAlerte || s.quantiteDisponible <= s.seuilAlerte).toList();

  bool get filtreAlerteSeulement => _filtreAlerteSeulement;

  Stock? stockParProduit(int idProduit) {
    for (final s in _stocks) {
      if (s.produit == idProduit) return s;
    }
    return null;
  }

  Future<void> chargerStocks() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      _stocks = await _service.getAll();
    } catch (e) {
      erreur = "Impossible de charger les stocks";
    }

    chargement = false;
    notifyListeners();
  }

  Future<void> chargerMouvements() async {
    try {
      _mouvements = await _service.getMouvements();
      notifyListeners();
    } catch (_) {}
  }

  void basculerFiltreAlerte(bool valeur) {
    _filtreAlerteSeulement = valeur;
    notifyListeners();
  }

  /// Ajuste la quantité via `POST /stocks/{id}/ajuster/`.
  /// [quantite] signée : positif = entrée, négatif = sortie.
  Future<void> ajusterQuantite({
    required int idStock,
    required int quantite,
    String? referenceOperation,
  }) async {
    enregistrMouvementEnCours = true;
    notifyListeners();

    try {
      await _service.ajuster(
        idStock,
        quantite: quantite,
        referenceOperation: referenceOperation,
      );
      await chargerStocks();
      await chargerMouvements();
    } finally {
      enregistrMouvementEnCours = false;
      notifyListeners();
    }
  }
}
