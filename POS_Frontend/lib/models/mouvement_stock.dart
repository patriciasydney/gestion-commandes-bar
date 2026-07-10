import '../core/utils/json_parse.dart';

/// Aligné sur `MouvementStockSerializer` (DRF, lecture seule).
class MouvementStock {
  final int idMouvement;
  final int produit;
  final String typeMouvement;
  final int quantite;
  final DateTime dateMouvement;
  final int utilisateur;
  final String? referenceOperation;

  MouvementStock({
    required this.idMouvement,
    required this.produit,
    required this.typeMouvement,
    required this.quantite,
    required this.dateMouvement,
    required this.utilisateur,
    this.referenceOperation,
  });

  factory MouvementStock.fromJson(Map<String, dynamic> json) {
    return MouvementStock(
      idMouvement: parseFkId(json['id_mouvement']),
      produit: parseFkId(json['produit'] ?? json['id_produit']),
      typeMouvement: json['type_mouvement'].toString(),
      quantite: parseFkId(json['quantite']),
      dateMouvement: DateTime.parse(json['date_mouvement'].toString()),
      utilisateur: parseFkId(json['utilisateur'] ?? json['id_utilisateur']),
      referenceOperation: json['reference_operation']?.toString(),
    );
  }
}
