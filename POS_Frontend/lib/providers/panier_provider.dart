import 'package:flutter/foundation.dart';
import '../models/produit.dart';

/// Un article du panier en cours (POS) : un produit + une quantité.
class ArticlePanier {
  final Produit produit;
  int quantite;

  ArticlePanier({required this.produit, this.quantite = 1});

  double get sousTotal => produit.prixVente * quantite;
}

/// État du panier de la vente en cours — écran POS (§10.4).
class PanierProvider extends ChangeNotifier {
  final List<ArticlePanier> _articles = [];
  double remise = 0;

  List<ArticlePanier> get articles => _articles;

  double get total {
    final sousTotal = _articles.fold<double>(0, (somme, a) => somme + a.sousTotal);
    return sousTotal - remise;
  }

  void ajouterProduit(Produit produit) {
    final index = _articles.indexWhere((a) => a.produit.idProduit == produit.idProduit);
    if (index >= 0) {
      _articles[index].quantite++;
    } else {
      _articles.add(ArticlePanier(produit: produit));
    }
    notifyListeners();
  }

  void modifierQuantite(int idProduit, int quantite) {
    final index = _articles.indexWhere((a) => a.produit.idProduit == idProduit);
    if (index >= 0) {
      if (quantite <= 0) {
        _articles.removeAt(index);
      } else {
        _articles[index].quantite = quantite;
      }
      notifyListeners();
    }
  }

  void retirerArticle(int idProduit) {
    _articles.removeWhere((a) => a.produit.idProduit == idProduit);
    notifyListeners();
  }

  void vider() {
    _articles.clear();
    remise = 0;
    notifyListeners();
  }
}
