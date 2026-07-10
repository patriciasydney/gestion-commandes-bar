import '../core/utils/json_parse.dart';

/// Aligné sur `PaiementSerializer` (DRF).
class Paiement {
  final int idPaiement;
  final int vente;
  final String modePaiement;
  final double montant;
  final String? referenceTransaction;
  final DateTime datePaiement;

  Paiement({
    required this.idPaiement,
    required this.vente,
    required this.modePaiement,
    required this.montant,
    this.referenceTransaction,
    required this.datePaiement,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      idPaiement: parseFkId(json['id_paiement']),
      vente: parseFkId(json['vente'] ?? json['id_vente']),
      modePaiement: json['mode_paiement'].toString(),
      montant: double.parse(json['montant'].toString()),
      referenceTransaction: json['reference_transaction']?.toString(),
      datePaiement: DateTime.parse(json['date_paiement'].toString()),
    );
  }

  /// Payload POST — `PaiementSerializer` (écriture).
  Map<String, dynamic> toJson() {
    return {
      'vente': vente,
      'mode_paiement': modePaiement,
      'montant': montant,
      if (referenceTransaction != null) 'reference_transaction': referenceTransaction,
    };
  }
}
