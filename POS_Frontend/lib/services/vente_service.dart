import '../core/constants/api_constants.dart';
import '../models/paiement.dart';
import '../models/vente.dart';
import 'api_service.dart';
import 'paiement_service.dart';

/// Ligne de vente depuis le panier POS.
class LigneVente {
  final int produit;
  final int quantite;
  final double prixUnitaire;

  LigneVente({
    required this.produit,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get sousTotal => prixUnitaire * quantite;

  Map<String, dynamic> toDetailJson() => {
        'produit': produit,
        'quantite': quantite,
        'prix_unitaire': prixUnitaire,
      };
}

/// Ventes — aligné sur `VenteCreateSerializer` + paiement séparé.
class VenteService {
  final ApiService _api = ApiService();
  final PaiementService _paiementService = PaiementService();

  Future<List<Vente>> getAll() async {
    final data = await _api.get(ApiConstants.ventes);
    return (data as List).map((json) => Vente.fromJson(json)).toList();
  }

  Future<Vente> getById(int id) async {
    final data = await _api.get('${ApiConstants.ventes}$id/');
    return Vente.fromJson(data);
  }

  /// Génère une référence unique côté client (champ requis par le backend).
  static String genererReference() {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '-${now.millisecondsSinceEpoch}';
    return 'VTE-$stamp';
  }

  /// Flux POS : 1 POST vente avec `details[]`, puis 1 POST paiement.
  Future<Vente> creerVenteComplete({
    required List<LigneVente> lignes,
    required double remise,
    required int caisse,
    int? client,
    required String modePaiement,
    String? referenceTransaction,
  }) async {
    final reference = genererReference();

    final data = await _api.post(
      ApiConstants.ventes,
      Vente.toCreateJson(
        reference: reference,
        remise: remise,
        caisse: caisse,
        client: client,
        details: lignes.map((l) => l.toDetailJson()).toList(),
      ),
    );
    final vente = Vente.fromJson(data as Map<String, dynamic>);

    await _paiementService.create(Paiement(
      idPaiement: 0,
      vente: vente.idVente,
      modePaiement: modePaiement,
      montant: vente.montantTotal,
      referenceTransaction: referenceTransaction,
      datePaiement: DateTime.now(),
    ));

    return vente;
  }
}
