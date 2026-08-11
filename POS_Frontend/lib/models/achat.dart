import '../core/utils/json_parse.dart';
import 'detail_achat.dart';

/// Aligné sur `AchatSerializer` / `AchatCreateSerializer` (DRF).
class Achat {
  final int idAchat;
  final DateTime dateAchat;
  final double montantTotal;
  final String statut;
  final int fournisseur;
  final String? fournisseurNom;
  final int utilisateur;
  final List<DetailAchat>? details;

  Achat({
    required this.idAchat,
    required this.dateAchat,
    required this.montantTotal,
    required this.statut,
    required this.fournisseur,
    this.fournisseurNom,
    required this.utilisateur,
    this.details,
  });

  factory Achat.fromJson(Map<String, dynamic> json) {
    return Achat(
      idAchat: parseFkId(json['id_achat']),
      dateAchat: DateTime.parse(json['date_achat'].toString()),
      montantTotal: double.parse(json['montant_total'].toString()),
      statut: json['statut'].toString(),
      fournisseur: parseFkId(json['fournisseur'] ?? json['id_fournisseur']),
      fournisseurNom: json['fournisseur_nom']?.toString(),
      utilisateur: parseFkId(json['utilisateur'] ?? json['id_utilisateur']),
      details: json['details'] is List
          ? (json['details'] as List)
              .map((e) => DetailAchat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get libelleFournisseur =>
      (fournisseurNom != null && fournisseurNom!.isNotEmpty)
          ? fournisseurNom!
          : 'Fournisseur #$fournisseur';

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
