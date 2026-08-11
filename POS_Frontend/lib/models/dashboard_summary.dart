/// Aligné sur `DashboardSummarySerializer` (DRF).
class ProduitStockFaible {
  final String produit;
  final int quantite;
  final int seuil;

  ProduitStockFaible({
    required this.produit,
    required this.quantite,
    required this.seuil,
  });

  factory ProduitStockFaible.fromJson(Map<String, dynamic> json) {
    return ProduitStockFaible(
      produit: json['produit'].toString(),
      quantite: (json['quantite'] as num).toInt(),
      seuil: (json['seuil'] as num).toInt(),
    );
  }
}

class DashboardSummary {
  final DateTime date;
  final double chiffreAffairesJour;
  final int nombreTicketsJour;
  final double depensesJour;
  final List<ProduitStockFaible> produitsStockFaible;

  DashboardSummary({
    required this.date,
    required this.chiffreAffairesJour,
    required this.nombreTicketsJour,
    required this.depensesJour,
    required this.produitsStockFaible,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      date: DateTime.parse(json['date'].toString()),
      chiffreAffairesJour: double.parse(json['chiffre_affaires_jour'].toString()),
      nombreTicketsJour: (json['nombre_tickets_jour'] as num).toInt(),
      depensesJour: double.parse(json['depenses_jour'].toString()),
      produitsStockFaible: (json['produits_stock_faible'] as List? ?? [])
          .map((e) => ProduitStockFaible.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
