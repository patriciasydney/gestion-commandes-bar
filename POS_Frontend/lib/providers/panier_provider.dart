import 'package:flutter/foundation.dart';
import '../models/detail_vente.dart';
import '../models/produit.dart';
import '../models/vente.dart';

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

  /// Commande `en_attente` chargée pour consultation / encaissement caissier.
  int? commandeEnAttenteId;
  String? commandeReference;
  String? commandeClientNom;
  bool ouvrirPanierDemande = false;

  List<ArticlePanier> get articles => _articles;

  bool get aCommandeEnAttente => commandeEnAttenteId != null;

  double get total {
    final sousTotal = _articles.fold<double>(0, (somme, a) => somme + a.sousTotal);
    return sousTotal - remise;
  }

  void ajouterProduit(Produit produit) {
    if (aCommandeEnAttente) return;
    final index = _articles.indexWhere((a) => a.produit.idProduit == produit.idProduit);
    if (index >= 0) {
      _articles[index].quantite++;
    } else {
      _articles.add(ArticlePanier(produit: produit));
    }
    notifyListeners();
  }

  void modifierQuantite(int idProduit, int quantite) {
    if (aCommandeEnAttente) return;
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
    if (aCommandeEnAttente) return;
    _articles.removeWhere((a) => a.produit.idProduit == idProduit);
    notifyListeners();
  }

  void vider() {
    _articles.clear();
    remise = 0;
    commandeEnAttenteId = null;
    commandeReference = null;
    commandeClientNom = null;
    notifyListeners();
  }

  /// Charge le panier depuis une commande serveur (détails + prix de la commande).
  void chargerDepuisCommande({
    required Vente commande,
    required Produit Function(DetailVente detail) resoudreProduit,
  }) {
    final details = commande.details ?? const <DetailVente>[];
    _articles
      ..clear()
      ..addAll(
        details.map(
          (d) => ArticlePanier(
            produit: resoudreProduit(d),
            quantite: d.quantite,
          ),
        ),
      );
    remise = commande.remise;
    commandeEnAttenteId = commande.idVente;
    commandeReference = commande.reference;
    commandeClientNom = commande.clientNom;
    ouvrirPanierDemande = true;
    notifyListeners();
  }

  bool consommerDemandeOuverturePanier() {
    if (!ouvrirPanierDemande) return false;
    ouvrirPanierDemande = false;
    return true;
  }
}
