import '../core/utils/json_parse.dart';

/// Aligné sur `AchatSerializer` / `AchatCreateSerializer` (DRF).
class Achat {
  final int idAchat;
  final DateTime dateAchat;
  final double montantTotal;
  final String statut;
  final int fournisseur;
  final int utilisateur;

  Achat({
    required this.idAchat,
    required this.dateAchat,
    required this.montantTotal,
    required this.statut,
    required this.fournisseur,
    required this.utilisateur,
  });

  factory Achat.fromJson(Map<String, dynamic> json) {
    return Achat(
      idAchat: parseFkId(json['id_achat']),
      dateAchat: DateTime.parse(json['date_achat'].toString()),
      montantTotal: double.parse(json['montant_total'].toString()),
      statut: json['statut'].toString(),
      fournisseur: parseFkId(json['fournisseur'] ?? json['id_fournisseur']),
      utilisateur: parseFkId(json['utilisateur'] ?? json['id_utilisateur']),
    );
  }

  /// Payload POST — `AchatCreateSerializer` (`fournisseur` + `details[]`).
  static Map<String, dynamic> toCreateJson({
    required int fournisseur,
    required List<Map<String, dynamic>> details,
  }) {
    return {
      'fournisseur': fournisseur,
      'details': details,
    };
  }
}
