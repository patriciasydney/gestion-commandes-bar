import '../core/utils/json_parse.dart';

/// Aligné sur `CaisseSerializer` (DRF).
class Caisse {
  final int idCaisse;
  final DateTime dateOuverture;
  final DateTime? dateFermeture;
  final double montantInitial;
  final double? montantFinal;
  final String statut;
  final int utilisateur;

  Caisse({
    required this.idCaisse,
    required this.dateOuverture,
    this.dateFermeture,
    required this.montantInitial,
    this.montantFinal,
    required this.statut,
    required this.utilisateur,
  });

  bool get estOuverte => statut == 'ouverte';

  factory Caisse.fromJson(Map<String, dynamic> json) {
    return Caisse(
      idCaisse: parseFkId(json['id_caisse']),
      dateOuverture: DateTime.parse(json['date_ouverture'].toString()),
      dateFermeture: json['date_fermeture'] != null
          ? DateTime.parse(json['date_fermeture'].toString())
          : null,
      montantInitial: double.parse(json['montant_initial'].toString()),
      montantFinal: json['montant_final'] != null
          ? double.parse(json['montant_final'].toString())
          : null,
      statut: json['statut'].toString(),
      utilisateur: parseFkId(json['utilisateur'] ?? json['id_utilisateur']),
    );
  }

  /// Payload POST — ouverture caisse (`montant_initial` uniquement).
  static Map<String, dynamic> toOpenJson({required double montantInitial}) {
    return {'montant_initial': montantInitial};
  }
}
