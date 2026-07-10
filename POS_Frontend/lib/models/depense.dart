import '../core/utils/json_parse.dart';

/// Aligné sur `DepenseSerializer` (DRF). `utilisateur` injecté côté serveur.
class Depense {
  final int idDepense;
  final String libelle;
  final String categorie;
  final double montant;
  final DateTime dateDepense;
  final int? utilisateur;

  Depense({
    required this.idDepense,
    required this.libelle,
    required this.categorie,
    required this.montant,
    required this.dateDepense,
    this.utilisateur,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      idDepense: parseFkId(json['id_depense']),
      libelle: json['libelle'].toString(),
      categorie: json['categorie'].toString(),
      montant: double.parse(json['montant'].toString()),
      dateDepense: DateTime.parse(json['date_depense'].toString()),
      utilisateur: parseFkIdNullable(json['utilisateur'] ?? json['id_utilisateur']),
    );
  }

  /// Payload POST/PUT — sans `utilisateur` ni `date_depense` (read-only backend).
  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'categorie': categorie,
      'montant': montant,
    };
  }
}
