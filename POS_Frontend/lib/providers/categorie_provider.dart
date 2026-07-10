import 'package:flutter/foundation.dart';
import '../models/categorie.dart';
import '../services/categorie_service.dart';

/// Liste des catégories — partagée entre le filtre du catalogue produits,
/// le formulaire produit, et l'écran de gestion des catégories.
class CategorieProvider extends ChangeNotifier {
  final CategorieService _service = CategorieService();

  List<Categorie> categories = [];
  bool chargement = false;
  String? erreur;

  Future<void> chargerCategories() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      categories = await _service.getAll();
    } catch (e) {
      erreur = "Impossible de charger les catégories (backend non branché ?)";
    }

    chargement = false;
    notifyListeners();
  }

  Future<void> creer(Categorie categorie) async {
    final cree = await _service.create(categorie);
    categories.add(cree);
    notifyListeners();
  }

  Future<void> modifier(int id, Categorie categorie) async {
    final maj = await _service.update(id, categorie);
    final index = categories.indexWhere((c) => c.idCategorie == id);
    if (index != -1) {
      categories[index] = maj;
      notifyListeners();
    }
  }

  Future<void> supprimer(int id) async {
    await _service.delete(id);
    categories.removeWhere((c) => c.idCategorie == id);
    notifyListeners();
  }

  String nomCategorie(int idCategorie) {
    final trouvee = categories.where((c) => c.idCategorie == idCategorie);
    return trouvee.isEmpty ? 'Inconnue' : trouvee.first.nom;
  }
}
