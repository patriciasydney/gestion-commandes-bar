import '../core/utils/json_parse.dart';

/// Aligné sur `StockSerializer` (DRF).
class Stock {
  final int idStock;
  /// FK `produit` exposée par le backend.
  final int produit;
  final int quantiteDisponible;
  final int seuilAlerte;
  final bool enAlerte;
  final DateTime? dateMaj;

  Stock({
    required this.idStock,
    required this.produit,
    required this.quantiteDisponible,
    required this.seuilAlerte,
    this.enAlerte = false,
    this.dateMaj,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: parseFkId(json['id_stock']),
      produit: parseFkId(json['produit'] ?? json['id_produit']),
      quantiteDisponible: parseFkId(json['quantite_disponible']),
      seuilAlerte: parseFkId(json['seuil_alerte']),
      enAlerte: json['en_alerte'] as bool? ?? false,
      dateMaj: json['date_maj'] != null
          ? DateTime.tryParse(json['date_maj'].toString())
          : null,
    );
  }
}
