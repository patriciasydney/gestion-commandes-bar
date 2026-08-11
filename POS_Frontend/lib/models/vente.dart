import '../core/utils/json_parse.dart';
import 'detail_vente.dart';

/// Aligné sur `VenteSerializer` / `VenteCreateSerializer` (DRF).
class Vente {
  final int idVente;
  final String reference;
  final DateTime dateVente;
  final double montantTotal;
  final double remise;
  final String statut;
  final int utilisateur;
  final int? client;
  final int caisse;
  final List<DetailVente>? details;

  Vente({
    required this.idVente,
    required this.reference,
    required this.dateVente,
    required this.montantTotal,
    required this.remise,
    required this.statut,
    required this.utilisateur,
    this.client,
    required this.caisse,
    this.details,
  });

  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      idVente: parseFkId(json['id_vente']),
      reference: json['reference'].toString(),
      dateVente: DateTime.parse(json['date_vente'].toString()),
      montantTotal: double.parse(json['montant_total'].toString()),
      remise: double.parse(json['remise'].toString()),
      statut: json['statut'].toString(),
      utilisateur: parseFkId(json['utilisateur'] ?? json['id_utilisateur']),
      client: parseFkIdNullable(json['client'] ?? json['id_client']),
      caisse: parseFkId(json['caisse'] ?? json['id_caisse']),
      details: json['details'] is List
          ? (json['details'] as List)
              .map((e) => DetailVente.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Payload POST — `VenteCreateSerializer`.
  static Map<String, dynamic> toCreateJson({
    required String reference,
    required double remise,
    required int caisse,
    int? client,
    required List<Map<String, dynamic>> details,
  }) {
    return {
      'reference': reference,
      'remise': remise,
      'caisse': caisse,
      'client': ?client,
      'details': details,
    };
  }
}
