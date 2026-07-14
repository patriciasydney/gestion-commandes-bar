/// JSON de référence alignés sur les réponses DRF (tests unitaires).
class ApiFixtures {
  ApiFixtures._();

  static Map<String, dynamic> loginResponse = {
    'access': 'eyJ.test.access',
    'refresh': 'eyJ.test.refresh',
    'utilisateur': {
      'id': 1,
      'username': 'admin',
      'nom': 'Admin',
      'prenom': 'Test',
      'email': 'admin@pos.test',
      'telephone': '+237690000000',
      'statut': 'actif',
      'role': {
        'id_role': 1,
        'nom_role': 'Administrateur',
        'description': 'Accès complet',
        'actif': true,
      },
    },
  };

  static Map<String, dynamic> produit = {
    'id_produit': 10,
    'code': 'BIR-001',
    'nom': 'Bière 33cl',
    'prix_achat': '500.00',
    'prix_vente': '800.00',
    'stock_minimum': 20,
    'actif': true,
    'categorie': 2,
    'fournisseur': 1,
    'image': null,
  };

  static Map<String, dynamic> vente = {
    'id_vente': 6,
    'reference': 'VTE-20260710-123',
    'date_vente': '2026-07-10T09:00:00+01:00',
    'montant_total': '3800.00',
    'remise': '0.00',
    'statut': 'validee',
    'utilisateur': 1,
    'client': null,
    'caisse': 2,
    'details': [
      {
        'id_detail': 1,
        'produit': 10,
        'quantite': 2,
        'prix_unitaire': '1500.00',
        'sous_total': '3000.00',
      },
    ],
  };

  static Map<String, dynamic> dashboardSummary = {
    'date': '2026-07-10',
    'chiffre_affaires_jour': '133500.00',
    'nombre_tickets_jour': 3,
    'depenses_jour': '0.00',
    'produits_stock_faible': [
      {'produit': 'Whisky 70cl', 'quantite': 3, 'seuil': 10},
    ],
  };

  static Map<String, dynamic> rapportAchats = {
    'periode': {'debut': '2026-07-10', 'fin': '2026-07-10'},
    'total_achats': '125250.00',
    'nombre_achats': 1,
    'par_fournisseur': [
      {
        'fournisseur__raison_sociale': 'Cave Import Spiritueux',
        'total_fournisseur': '125250.00',
        'nombre_achats': 1,
      },
    ],
  };
}
