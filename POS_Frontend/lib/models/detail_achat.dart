import '../core/utils/json_parse.dart';

/// Aligné sur `DetailAchatSerializer` (DRF).
class DetailAchat {
  final int idDetail;
  final int produit;
  final String? produitNom;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;

  DetailAchat({
    required this.idDetail,
    required this.produit,
    this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal,
  });

  factory DetailAchat.fromJson(Map<String, dynamic> json) {
    return DetailAchat(
      idDetail: parseFkId(json['id_detail']),
      produit: parseFkId(json['produit'] ?? json['id_produit']),
      produitNom: json['produit_nom']?.toString(),
      quantite: parseFkId(json['quantite']),
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      sousTotal: double.parse(json['sous_total'].toString()),
    );
  }

  String get libelleProduit =>
      (produitNom != null && produitNom!.isNotEmpty)
          ? produitNom!
          : 'Produit #$produit';
}
