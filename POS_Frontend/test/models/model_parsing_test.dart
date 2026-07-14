import 'package:flutter_test/flutter_test.dart';
import 'package:front_boisson/models/dashboard_summary.dart';
import 'package:front_boisson/models/produit.dart';
import 'package:front_boisson/models/rapport.dart';
import 'package:front_boisson/models/vente.dart';

import '../fixtures/api_fixtures.dart';

void main() {
  group('Produit.fromJson', () {
    test('parse FK categorie et fournisseur', () {
      final p = Produit.fromJson(ApiFixtures.produit);
      expect(p.idProduit, 10);
      expect(p.categorie, 2);
      expect(p.fournisseur, 1);
      expect(p.prixVente, 800);
    });
  });

  group('Vente.fromJson', () {
    test('parse FK utilisateur, caisse et details nested', () {
      final v = Vente.fromJson(ApiFixtures.vente);
      expect(v.reference, startsWith('VTE-'));
      expect(v.utilisateur, 1);
      expect(v.caisse, 2);
      expect(v.client, isNull);
      expect(v.details, hasLength(1));
      expect(v.details!.first.produit, 10);
      expect(v.montantTotal, 3800);
    });

    test('toCreateJson sans client optionnel', () {
      final json = Vente.toCreateJson(
        reference: 'VTE-TEST',
        remise: 0,
        caisse: 1,
        details: [
          {'produit': 10, 'quantite': 1, 'prix_unitaire': 800},
        ],
      );
      expect(json['reference'], 'VTE-TEST');
      expect(json.containsKey('client'), isFalse);
      expect(json['details'], hasLength(1));
    });
  });

  group('DashboardSummary.fromJson', () {
    test('parse clés backend summary', () {
      final s = DashboardSummary.fromJson(ApiFixtures.dashboardSummary);
      expect(s.chiffreAffairesJour, 133500);
      expect(s.nombreTicketsJour, 3);
      expect(s.produitsStockFaible, hasLength(1));
      expect(s.produitsStockFaible.first.produit, 'Whisky 70cl');
    });
  });

  group('RapportAchats.fromJson', () {
    test('parse total et par_fournisseur', () {
      final r = RapportAchats.fromJson(ApiFixtures.rapportAchats);
      expect(r.totalAchats, 125250);
      expect(r.nombreAchats, 1);
      expect(r.parFournisseur.first.fournisseur, 'Cave Import Spiritueux');
    });
  });

  group('RapportComplet', () {
    test('beneficeNet inclut achats et depenses', () {
      final rapport = RapportComplet(
        libellePeriode: 'Test',
        chiffreAffaires: 200000,
        nombreVentes: 10,
        depensesTotal: 30000,
        achatsTotal: 50000,
        nombreAchats: 2,
        topProduits: const [],
        depensesParCategorie: const [],
        achatsParFournisseur: const [],
      );
      expect(rapport.sortiesTotal, 80000);
      expect(rapport.beneficeNet, 120000);
      expect(rapport.panierMoyen, 20000);
    });
  });
}
