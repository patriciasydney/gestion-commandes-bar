import 'package:flutter/foundation.dart';
import '../models/categorie.dart';
import '../services/categorie_service.dart';

/// Liste des catégories — partagée entre filtre catalogue, formulaire produit,
/// POS et écran de gestion.
class CategorieProvider extends ChangeNotifier {
  final CategorieService _service = CategorieService();

  List<Categorie> categories = [];
  bool chargement = false;
  String? erreur;
  String recherche = '';

  List<Categorie> get categoriesFiltrees {
    final q = recherche.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(categories);
    return categories
        .where(
          (c) =>
              c.nom.toLowerCase().contains(q) ||
              (c.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  List<Categorie> get categoriesActives =>
      categories.where((c) => c.actif).toList();

  Future<void> chargerCategories() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      categories = await _service.getAll();
    } catch (e) {
      erreur = 'Impossible de charger les catégories';
    }

    chargement = false;
    notifyListeners();
  }

  void rechercher(String texte) {
    recherche = texte;
    notifyListeners();
  }

  Future<void> creer(Categorie categorie) async {
    final cree = await _service.create(categorie);
    categories.add(cree);
    categories.sort((a, b) => a.nom.compareTo(b.nom));
    notifyListeners();
  }

  Future<void> modifier(int id, Categorie categorie) async {
    final maj = await _service.update(id, categorie);
    final index = categories.indexWhere((c) => c.idCategorie == id);
    if (index != -1) {
      categories[index] = maj.copyWith(
        nombreProduits: categories[index].nombreProduits,
      );
      categories.sort((a, b) => a.nom.compareTo(b.nom));
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
