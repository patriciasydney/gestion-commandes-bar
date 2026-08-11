// ============================================================================
// Modèle DetailAchat — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class DetailAchat {
  final int idDetail;
  final int idAchat;
  final int idProduit;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;

  DetailAchat({
    required this.idDetail,
    required this.idAchat,
    required this.idProduit,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal
  });

  /// Construit un DetailAchat à partir du JSON renvoyé par l'API.
  factory DetailAchat.fromJson(Map<String, dynamic> json) {
    return DetailAchat(
      idDetail: json['id_detail'] is int ? json['id_detail'] as int : int.parse(json['id_detail'].toString()),
      idAchat: json['id_achat'] is int ? json['id_achat'] as int : int.parse(json['id_achat'].toString()),
      idProduit: json['id_produit'] is int ? json['id_produit'] as int : int.parse(json['id_produit'].toString()),
      quantite: json['quantite'] is int ? json['quantite'] as int : int.parse(json['quantite'].toString()),
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      sousTotal: double.parse(json['sous_total'].toString())
    );
  }

  /// Transforme ce DetailAchat en JSON pour l'envoyer à l'API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'id_detail': idDetail,
      'id_achat': idAchat,
      'id_produit': idProduit,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'sous_total': sousTotal
    };
  }
}
