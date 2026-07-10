import 'package:flutter/foundation.dart';
import '../models/utilisateur.dart';
import '../services/utilisateur_service.dart';

/// Liste des comptes utilisateurs — écran §10.7 (admin uniquement).
class UtilisateurProvider extends ChangeNotifier {
  final UtilisateurService _service = UtilisateurService();

  List<Utilisateur> _utilisateurs = [];
  bool chargement = false;
  String? erreur;
  String recherche = "";

  List<Utilisateur> get utilisateurs => _utilisateurs.where((u) {
        if (recherche.trim().isEmpty) return true;
        final texte = recherche.toLowerCase();
        return u.nom.toLowerCase().contains(texte) ||
            u.prenom.toLowerCase().contains(texte) ||
            u.username.toLowerCase().contains(texte) ||
            u.email.toLowerCase().contains(texte);
      }).toList();

  Future<void> chargerUtilisateurs() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      _utilisateurs = await _service.getAll();
    } catch (e) {
      erreur = "Impossible de charger les utilisateurs";
    }

    chargement = false;
    notifyListeners();
  }

  Future<void> creer(Utilisateur utilisateur, {required String password}) async {
    final cree = await _service.create(utilisateur, password: password);
    _utilisateurs.add(cree);
    notifyListeners();
  }

  Future<void> modifier(int id, Utilisateur utilisateur) async {
    final maj = await _service.update(id, utilisateur);
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _utilisateurs[index] = maj;
      notifyListeners();
    }
  }

  Future<void> basculerStatut(Utilisateur u) async {
    final nouveauStatut = u.statut == 'actif' ? 'inactif' : 'actif';
    final maj = u.copyWith(statut: nouveauStatut);
    await _service.update(u.id, maj);
    final index = _utilisateurs.indexWhere((x) => x.id == u.id);
    if (index != -1) {
      _utilisateurs[index] = maj;
      notifyListeners();
    }
  }

  Future<void> supprimer(int id) async {
    await _service.delete(id);
    _utilisateurs.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  void rechercher(String texte) {
    recherche = texte;
    notifyListeners();
  }
}
