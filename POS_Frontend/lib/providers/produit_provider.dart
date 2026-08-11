import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../services/produit_service.dart';

/// Liste des produits, recherche et filtres — utilisé par le POS et l'écran Produits.
class ProduitProvider extends ChangeNotifier {
  final ProduitService _service = ProduitService();

  List<Produit> _produits = [];
  bool chargement = false;
  String? erreur;
  String recherche = "";
  int? filtreCategorie;

  List<Produit> get produits => _produits.where((p) {
        if (filtreCategorie != null && p.categorie != filtreCategorie) return false;
        final texte = recherche.toLowerCase();
        if (texte.isEmpty) return true;
        return p.nom.toLowerCase().contains(texte) ||
            (p.codeBarres?.toLowerCase().contains(texte) ?? false) ||
            p.code.toLowerCase().contains(texte);
      }).toList();

  Future<void> chargerProduits() async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      _produits = await _service.getAll();
    } catch (e) {
      erreur = "Impossible de charger les produits (backend non branché ?)";
    }

    chargement = false;
    notifyListeners();
  }

  void rechercher(String texte) {
    recherche = texte;
    notifyListeners();
  }

  void filtrerParCategorie(int? idCategorie) {
    filtreCategorie = idCategorie;
    notifyListeners();
  }

  /// Recherche un produit par son ID dans la liste **non filtrée**.
  /// Utilisé par les écrans Stocks / Achats qui ont besoin d'accéder à un
  /// produit précis même si l'utilisateur a tapé une recherche dans l'écran
  /// Produits (la recherche modifie le getter `produits`, pas `_produits`).
  Produit? produitParId(int idProduit) {
    for (final p in _produits) {
      if (p.idProduit == idProduit) return p;
    }
    return null;
  }

  /// Renvoie la liste **complète** (non filtrée) des produits chargés.
  /// À utiliser quand on a besoin de tous les produits, indépendamment du
  /// filtre recherche/catégorie actif dans l'écran Produits.
  List<Produit> get tousLesProduits => List.unmodifiable(_produits);

  /// Crée un produit via l'API puis l'ajoute à la liste locale.
  Future<void> creer(Produit produit) async {
    final cree = await _service.create(produit);
    _produits.add(cree);
    notifyListeners();
  }

  /// Met à jour un produit existant, côté API puis dans la liste locale.
  Future<void> modifier(int id, Produit produit) async {
    final maj = await _service.update(id, produit);
    final index = _produits.indexWhere((p) => p.idProduit == id);
    if (index != -1) {
      _produits[index] = maj;
      notifyListeners();
    }
  }

  /// Supprime un produit, côté API puis dans la liste locale.
  Future<void> supprimer(int id) async {
    await _service.delete(id);
    _produits.removeWhere((p) => p.idProduit == id);
    notifyListeners();
  }
}
