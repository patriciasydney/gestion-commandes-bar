import 'package:flutter/foundation.dart';

import '../models/caisse.dart';
import '../services/caisse_service.dart';

/// Caisse ouverte de la session POS — requis avant toute vente.
class CaisseProvider extends ChangeNotifier {
  final CaisseService _service = CaisseService();

  Caisse? _caisseOuverte;
  bool chargement = false;
  String? erreur;

  Caisse? get caisseOuverte => _caisseOuverte;
  bool get aCaisseOuverte => _caisseOuverte?.estOuverte == true;

  Future<void> chargerCaisseActive({int? idUtilisateur}) async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      final caisses = await _service.getAll();
      Caisse? ouverte;
      for (final c in caisses) {
        if (!c.estOuverte) continue;
        if (idUtilisateur == null || c.utilisateur == idUtilisateur) {
          ouverte = c;
          break;
        }
      }
      _caisseOuverte = ouverte;
    } catch (e) {
      erreur = "Impossible de charger l'état de la caisse";
      _caisseOuverte = null;
    }

    chargement = false;
    notifyListeners();
  }

  Future<Caisse> ouvrir({double montantInitial = 0}) async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      _caisseOuverte = await _service.ouvrir(montantInitial: montantInitial);
      return _caisseOuverte!;
    } catch (e) {
      erreur = e.toString();
      rethrow;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }

  Future<void> fermer({required double montantFinal}) async {
    if (_caisseOuverte == null) return;
    chargement = true;
    notifyListeners();

    try {
      await _service.fermer(_caisseOuverte!.idCaisse, montantFinal: montantFinal);
      _caisseOuverte = null;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }
}
