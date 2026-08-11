import '../core/utils/date_range.dart';

/// Aligné sur les serializers DRF du module `reports`.
class RapportPeriode {
  final DateTime? debut;
  final DateTime? fin;

  RapportPeriode({this.debut, this.fin});

  factory RapportPeriode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RapportPeriode();
    return RapportPeriode(
      debut: json['debut'] != null ? DateTime.parse(json['debut'].toString()) : null,
      fin: json['fin'] != null ? DateTime.parse(json['fin'].toString()) : null,
    );
  }
}

class RapportVenteJour {
  final DateTime jour;
  final double totalJour;
  final int tickets;

  RapportVenteJour({
    required this.jour,
    required this.totalJour,
    required this.tickets,
  });

  factory RapportVenteJour.fromJson(Map<String, dynamic> json) {
    return RapportVenteJour(
      jour: DateTime.parse(json['jour'].toString()),
      totalJour: double.parse(json['total_jour'].toString()),
      tickets: (json['tickets'] as num).toInt(),
    );
  }
}

class RapportVentes {
  final RapportPeriode periode;
  final double totalVentes;
  final int nombreVentes;
  final List<RapportVenteJour> detailParJour;

  RapportVentes({
    required this.periode,
    required this.totalVentes,
    required this.nombreVentes,
    required this.detailParJour,
  });

  factory RapportVentes.fromJson(Map<String, dynamic> json) {
    return RapportVentes(
      periode: RapportPeriode.fromJson(json['periode'] as Map<String, dynamic>?),
      totalVentes: double.parse(json['total_ventes'].toString()),
      nombreVentes: (json['nombre_ventes'] as num).toInt(),
      detailParJour: (json['detail_par_jour'] as List? ?? [])
          .map((e) => RapportVenteJour.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Séries pour le graphique : 7 valeurs (J-6 … aujourd'hui).
  List<num> ventesSeptJours() {
    final preset = DateRange.septDerniersJours();
    final result = <num>[];
    for (int i = 0; i < 7; i++) {
      final day = preset.debut.add(Duration(days: i));
      RapportVenteJour? match;
      for (final d in detailParJour) {
        if (DateRange.sameDay(d.jour, day)) {
          match = d;
          break;
        }
      }
      result.add(match?.totalJour ?? 0);
    }
    return result;
  }
}

class TopProduitVendu {
  final String nom;
  final int quantiteTotale;
  final double chiffreAffaires;

  TopProduitVendu({
    required this.nom,
    required this.quantiteTotale,
    required this.chiffreAffaires,
  });

  factory TopProduitVendu.fromJson(Map<String, dynamic> json) {
    return TopProduitVendu(
      nom: (json['produit__nom'] ?? json['nom'] ?? '').toString(),
      quantiteTotale: (json['quantite_totale'] as num).toInt(),
      chiffreAffaires: double.parse(json['chiffre_affaires'].toString()),
    );
  }
}

class DepenseParCategorie {
  final String categorie;
  final double total;

  DepenseParCategorie({required this.categorie, required this.total});

  factory DepenseParCategorie.fromJson(Map<String, dynamic> json) {
    return DepenseParCategorie(
      categorie: json['categorie'].toString(),
      total: double.parse((json['total_categorie'] ?? json['montant']).toString()),
    );
  }
}

class AchatParFournisseur {
  final String fournisseur;
  final double total;
  final int nombreAchats;

  AchatParFournisseur({
    required this.fournisseur,
    required this.total,
    required this.nombreAchats,
  });

  factory AchatParFournisseur.fromJson(Map<String, dynamic> json) {
    return AchatParFournisseur(
      fournisseur: (json['fournisseur__raison_sociale'] ?? json['fournisseur'] ?? '')
          .toString(),
      total: double.parse((json['total_fournisseur'] ?? json['total']).toString()),
      nombreAchats: (json['nombre_achats'] as num).toInt(),
    );
  }
}

class RapportAchats {
  final RapportPeriode periode;
  final double totalAchats;
  final int nombreAchats;
  final List<AchatParFournisseur> parFournisseur;

  RapportAchats({
    required this.periode,
    required this.totalAchats,
    required this.nombreAchats,
    required this.parFournisseur,
  });

  factory RapportAchats.fromJson(Map<String, dynamic> json) {
    return RapportAchats(
      periode: RapportPeriode.fromJson(json['periode'] as Map<String, dynamic>?),
      totalAchats: double.parse(json['total_achats'].toString()),
      nombreAchats: (json['nombre_achats'] as num).toInt(),
      parFournisseur: (json['par_fournisseur'] as List? ?? [])
          .map((e) => AchatParFournisseur.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Vue agrégée pour l'écran Rapports (4 endpoints backend).
class RapportComplet {
  final String libellePeriode;
  final double chiffreAffaires;
  final int nombreVentes;
  final double depensesTotal;
  final double achatsTotal;
  final int nombreAchats;
  final List<TopProduitVendu> topProduits;
  final List<DepenseParCategorie> depensesParCategorie;
  final List<AchatParFournisseur> achatsParFournisseur;

  RapportComplet({
    required this.libellePeriode,
    required this.chiffreAffaires,
    required this.nombreVentes,
    required this.depensesTotal,
    required this.achatsTotal,
    required this.nombreAchats,
    required this.topProduits,
    required this.depensesParCategorie,
    required this.achatsParFournisseur,
  });

  double get sortiesTotal => depensesTotal + achatsTotal;

  double get beneficeNet => chiffreAffaires - sortiesTotal;

  double get panierMoyen =>
      nombreVentes > 0 ? chiffreAffaires / nombreVentes : 0;
}
