import '../core/constants/api_constants.dart';

/// Simule les réponses de l'API Django tant que le backend réel n'est pas prêt.
/// Chaque endpoint retourne un JSON de la même forme que ce qu'enverra Django,
/// pour que le passage au vrai backend ne nécessite qu'un changement de
/// `ApiConstants.modeDemo` (aucune modification des services/providers/screens).
class MockApi {
  // --------------------------------------------------------------------
  // Données en mémoire (réinitialisées à chaque redémarrage de l'app)
  // --------------------------------------------------------------------

  static final List<Map<String, dynamic>> _categories = [
    {'id_categorie': 1, 'nom': 'Bières', 'description': 'Bières en bouteille et canette', 'actif': true},
    {'id_categorie': 2, 'nom': 'Boissons gazeuses', 'description': 'Sodas et boissons sucrées', 'actif': true},
    {'id_categorie': 3, 'nom': 'Jus & Eaux', 'description': 'Jus naturels et eaux minérales', 'actif': true},
    {'id_categorie': 4, 'nom': 'Spiritueux', 'description': 'Whisky, vodka, liqueurs', 'actif': true},
  ];

  static final List<Map<String, dynamic>> _fournisseurs = [
    {'id_fournisseur': 1, 'raison_sociale': 'Brasseries du Cameroun', 'telephone': '233421000', 'adresse': 'Douala', 'email': 'contact@brasseries.cm', 'actif': true},
    {'id_fournisseur': 2, 'raison_sociale': 'Société Anonyme des Boissons', 'telephone': '233502000', 'adresse': 'Yaoundé', 'email': null, 'actif': true},
  ];

  static final List<Map<String, dynamic>> _produits = [
    {'id_produit': 1, 'code': 'BIE-001', 'code_barres': '6001234500017', 'nom': '33 Export 65cl', 'description': null, 'prix_achat': 550, 'prix_vente': 750, 'contenance': '65cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 1, 'id_fournisseur': 1, 'photo_base64': null},
    {'id_produit': 2, 'code': 'BIE-002', 'code_barres': '6001234500024', 'nom': 'Castel Beer 65cl', 'description': null, 'prix_achat': 550, 'prix_vente': 750, 'contenance': '65cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 1, 'id_fournisseur': 1, 'photo_base64': null},
    {'id_produit': 3, 'code': 'BIE-003', 'code_barres': '6001234500031', 'nom': 'Guinness 33cl', 'description': null, 'prix_achat': 600, 'prix_vente': 850, 'contenance': '33cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 1, 'id_fournisseur': 1, 'photo_base64': null},
    {'id_produit': 4, 'code': 'BIE-004', 'code_barres': '6001234500048', 'nom': 'Beaufort 65cl', 'description': null, 'prix_achat': 550, 'prix_vente': 750, 'contenance': '65cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 1, 'id_fournisseur': 1, 'photo_base64': null},
    {'id_produit': 5, 'code': 'SOD-001', 'code_barres': '6001234500055', 'nom': 'Coca-Cola 50cl', 'description': null, 'prix_achat': 350, 'prix_vente': 500, 'contenance': '50cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 2, 'id_fournisseur': 2, 'photo_base64': null},
    {'id_produit': 6, 'code': 'SOD-002', 'code_barres': '6001234500062', 'nom': 'Fanta Orange 50cl', 'description': null, 'prix_achat': 350, 'prix_vente': 500, 'contenance': '50cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 2, 'id_fournisseur': 2, 'photo_base64': null},
    {'id_produit': 7, 'code': 'SOD-003', 'code_barres': '6001234500079', 'nom': 'Sprite 50cl', 'description': null, 'prix_achat': 350, 'prix_vente': 500, 'contenance': '50cl', 'stock_minimum': 24, 'actif': true, 'id_categorie': 2, 'id_fournisseur': 2, 'photo_base64': null},
    {'id_produit': 8, 'code': 'JUS-001', 'code_barres': '6001234500086', 'nom': 'Jus de gingembre 1L', 'description': null, 'prix_achat': 800, 'prix_vente': 1200, 'contenance': '1L', 'stock_minimum': 12, 'actif': true, 'id_categorie': 3, 'id_fournisseur': null, 'photo_base64': null},
    {'id_produit': 9, 'code': 'EAU-001', 'code_barres': '6001234500093', 'nom': 'Eau minérale 1.5L', 'description': null, 'prix_achat': 300, 'prix_vente': 500, 'contenance': '1.5L', 'stock_minimum': 24, 'actif': true, 'id_categorie': 3, 'id_fournisseur': null, 'photo_base64': null},
    {'id_produit': 10, 'code': 'SPI-001', 'code_barres': '6001234500109', 'nom': 'Whisky 70cl', 'description': null, 'prix_achat': 6500, 'prix_vente': 9000, 'contenance': '70cl', 'stock_minimum': 6, 'actif': true, 'id_categorie': 4, 'id_fournisseur': null, 'photo_base64': null},
    {'id_produit': 11, 'code': 'SPI-002', 'code_barres': '6001234500116', 'nom': 'Vodka 70cl', 'description': null, 'prix_achat': 5500, 'prix_vente': 8000, 'contenance': '70cl', 'stock_minimum': 6, 'actif': true, 'id_categorie': 4, 'id_fournisseur': null, 'photo_base64': null},
  ];

  static final List<Map<String, dynamic>> _clients = [
    {'id_client': 1, 'nom': 'Nguemo', 'prenom': 'Jean', 'telephone': '677111222', 'email': null, 'adresse': 'Etoug-Ebe, Yaoundé', 'actif': true},
    {'id_client': 2, 'nom': 'Belinga', 'prenom': 'Marie', 'telephone': '699333444', 'email': null, 'adresse': 'Mvan, Yaoundé', 'actif': true},
    {'id_client': 3, 'nom': 'Essomba', 'prenom': 'Paul', 'telephone': '655666777', 'email': null, 'adresse': null, 'actif': true},
  ];

  // ---- Stocks : une ligne par produit ----
  static final List<Map<String, dynamic>> _stocks = [
    {'id_stock': 1, 'id_produit': 1, 'quantite_disponible': 96, 'seuil_alerte': 24},
    {'id_stock': 2, 'id_produit': 2, 'quantite_disponible': 72, 'seuil_alerte': 24},
    {'id_stock': 3, 'id_produit': 3, 'quantite_disponible': 18, 'seuil_alerte': 24},  // en alerte
    {'id_stock': 4, 'id_produit': 4, 'quantite_disponible': 120, 'seuil_alerte': 24},
    {'id_stock': 5, 'id_produit': 5, 'quantite_disponible': 48, 'seuil_alerte': 24},
    {'id_stock': 6, 'id_produit': 6, 'quantite_disponible': 60, 'seuil_alerte': 24},
    {'id_stock': 7, 'id_produit': 7, 'quantite_disponible': 12, 'seuil_alerte': 24},  // en alerte
    {'id_stock': 8, 'id_produit': 8, 'quantite_disponible': 30, 'seuil_alerte': 12},
    {'id_stock': 9, 'id_produit': 9, 'quantite_disponible': 84, 'seuil_alerte': 24},
    {'id_stock': 10, 'id_produit': 10, 'quantite_disponible': 4, 'seuil_alerte': 6},  // en alerte
    {'id_stock': 11, 'id_produit': 11, 'quantite_disponible': 9, 'seuil_alerte': 6},
  ];

  // ---- Mouvements de stock (entrées/sorties) ----
  static final List<Map<String, dynamic>> _mouvements = [
    {'id_mouvement': 1, 'id_produit': 1, 'type_mouvement': 'entree', 'quantite': 120, 'date_mouvement': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'id_utilisateur': 1, 'reference_operation': 'ACH-001'},
    {'id_mouvement': 2, 'id_produit': 1, 'type_mouvement': 'sortie', 'quantite': 24, 'date_mouvement': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(), 'id_utilisateur': 1, 'reference_operation': 'VTE-0001'},
    {'id_mouvement': 3, 'id_produit': 5, 'type_mouvement': 'entree', 'quantite': 72, 'date_mouvement': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(), 'id_utilisateur': 1, 'reference_operation': 'ACH-002'},
    {'id_mouvement': 4, 'id_produit': 3, 'type_mouvement': 'sortie', 'quantite': 36, 'date_mouvement': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(), 'id_utilisateur': 2, 'reference_operation': 'VTE-0002'},
    {'id_mouvement': 5, 'id_produit': 7, 'type_mouvement': 'sortie', 'quantite': 12, 'date_mouvement': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(), 'id_utilisateur': 1, 'reference_operation': 'VTE-0003'},
    {'id_mouvement': 6, 'id_produit': 10, 'type_mouvement': 'sortie', 'quantite': 2, 'date_mouvement': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(), 'id_utilisateur': 1, 'reference_operation': 'VTE-0004'},
  ];

  // ---- Achats / approvisionnements ----
  static final List<Map<String, dynamic>> _achats = [
    {'id_achat': 1, 'date_achat': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'montant_total': 66000, 'statut': 'recu', 'id_fournisseur': 1, 'id_utilisateur': 1},
    {'id_achat': 2, 'date_achat': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(), 'montant_total': 25200, 'statut': 'recu', 'id_fournisseur': 2, 'id_utilisateur': 1},
  ];

  static final List<Map<String, dynamic>> _detailsAchat = [
    {'id_detail': 1, 'id_achat': 1, 'id_produit': 1, 'quantite': 120, 'prix_unitaire': 550, 'sous_total': 66000},
    {'id_detail': 2, 'id_achat': 2, 'id_produit': 5, 'quantite': 72, 'prix_unitaire': 350, 'sous_total': 25200},
  ];

  // ---- Dépenses courantes ----
  static final List<Map<String, dynamic>> _depenses = [
    {'id_depense': 1, 'libelle': 'Facture électricité', 'categorie': 'Charges fixes', 'montant': 45000, 'date_depense': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(), 'id_utilisateur': 1},
    {'id_depense': 2, 'libelle': 'Carburant groupe électrogène', 'categorie': 'Carburant', 'montant': 15000, 'date_depense': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'id_utilisateur': 1},
    {'id_depense': 3, 'libelle': 'Sacs plastiques', 'categorie': 'Fournitures', 'montant': 5000, 'date_depense': DateTime.now().toIso8601String(), 'id_utilisateur': 1},
  ];

  // ---- Rôles ----
  static final List<Map<String, dynamic>> _roles = [
    {'id_role': 1, 'nom_role': 'Administrateur', 'description': 'Accès complet à toutes les fonctionnalités', 'actif': true},
    {'id_role': 2, 'nom_role': 'Gérant', 'description': 'Gestion des ventes, stocks et rapports', 'actif': true},
    {'id_role': 3, 'nom_role': 'Caissier', 'description': 'Encaissement et consultation du catalogue', 'actif': true},
    {'id_role': 4, 'nom_role': 'Magasinier', 'description': 'Approvisionnements et mouvements de stock', 'actif': true},
    {'id_role': 5, 'nom_role': 'Serveur', 'description': 'Prise de commandes clients', 'actif': true},
    {'id_role': 6, 'nom_role': 'Comptable', 'description': 'Rapports financiers et dépenses', 'actif': true},
  ];

  // ---- Utilisateurs ----
  static final List<Map<String, dynamic>> _utilisateurs = [
    {'id_utilisateur': 1, 'nom': 'Masse', 'prenom': 'Paulo', 'telephone': '699000000', 'email': 'admin@front-boisson.test', 'nom_utilisateur': 'admin', 'statut': 'actif', 'id_role': 1},
    {'id_utilisateur': 2, 'nom': 'Ngono', 'prenom': 'Alice', 'telephone': '677123456', 'email': 'alice@front-boisson.test', 'nom_utilisateur': 'alice', 'statut': 'actif', 'id_role': 2},
    {'id_utilisateur': 3, 'nom': 'Foka', 'prenom': 'Jean', 'telephone': '655987654', 'email': 'jean@front-boisson.test', 'nom_utilisateur': 'jean', 'statut': 'actif', 'id_role': 3},
    {'id_utilisateur': 4, 'nom': 'Atangana', 'prenom': 'Marie', 'telephone': '690111222', 'email': 'marie@front-boisson.test', 'nom_utilisateur': 'marie', 'statut': 'inactif', 'id_role': 3},
  ];

  static final List<Map<String, dynamic>> _ventes = [
    {
      'id_vente': 1,
      'reference': 'V2026-0001',
      'date_vente': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      'montant_total': 2750,
      'remise': 0,
      'statut': 'validee',
      'id_utilisateur': 1,
      'id_client': 1,
      'id_caisse': 1,
    },
    {
      'id_vente': 2,
      'reference': 'V2026-0002',
      'date_vente': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'montant_total': 9500,
      'remise': 500,
      'statut': 'validee',
      'id_utilisateur': 1,
      'id_client': 1,
      'id_caisse': 1,
    },
    {
      'id_vente': 3,
      'reference': 'V2026-0003',
      'date_vente': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'montant_total': 1500,
      'remise': 0,
      'statut': 'validee',
      'id_utilisateur': 1,
      'id_client': 2,
      'id_caisse': 1,
    },
  ];
  static final List<Map<String, dynamic>> _paiements = [];

  static int _prochainIdVente = 4;
  static int _prochainIdPaiement = 1;
  static int _prochainIdProduit = 12;
  static int _prochainIdCategorie = 5;
  static int _prochainIdFournisseur = 3;
  static int _prochainIdStock = 12;
  static int _prochainIdMouvement = 7;
  static int _prochainIdAchat = 3;
  static int _prochainIdDetailAchat = 3;
  static int _prochainIdDepense = 4;
  static int _prochainIdUtilisateur = 5;

  // --------------------------------------------------------------------
  // Routeur
  // --------------------------------------------------------------------

  static Future<dynamic> handle(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simule la latence réseau

    if (endpoint == ApiConstants.login && method == 'POST') {
      return _login(body ?? {});
    }

    if (endpoint == ApiConstants.dashboard && method == 'GET') {
      return _dashboard();
    }

    if (endpoint.startsWith(ApiConstants.reportsVentes) && method == 'GET') {
      return _rapportVentes(endpoint);
    }
    if (endpoint.startsWith(ApiConstants.reportsProduits) && method == 'GET') {
      return _rapportProduits(endpoint);
    }
    if (endpoint.startsWith(ApiConstants.reportsDepenses) && method == 'GET') {
      return _rapportDepenses(endpoint);
    }
    if (endpoint.startsWith(ApiConstants.reportsAchats) && method == 'GET') {
      return _rapportAchats(endpoint);
    }

    // ---- Rapports legacy (mode démo) ----
    if (endpoint.startsWith('/rapports') && method == 'GET') {
      final periode = _extraireParam(endpoint, 'periode') ?? 'jour';
      return _genererRapportLegacy(periode);
    }

    // ---- Produits : collection + détail (avec ID dans l'URL) ----
    final produitDetail = _extraireId(endpoint, ApiConstants.produits);
    if (produitDetail != null) {
      if (method == 'PUT') return _mettreAJour(_produits, produitDetail, 'id_produit', body ?? {});
      if (method == 'DELETE') return _supprimer(_produits, produitDetail, 'id_produit');
      if (method == 'GET') return _trouver(_produits, produitDetail, 'id_produit');
    } else if (endpoint == ApiConstants.produits) {
      if (method == 'GET') return _produits;
      if (method == 'POST') return _creer(_produits, body ?? {}, 'id_produit', () => _prochainIdProduit++);
    }

    // ---- Catégories : collection + détail ----
    final categorieDetail = _extraireId(endpoint, ApiConstants.categories);
    if (categorieDetail != null) {
      if (method == 'PUT') return _mettreAJour(_categories, categorieDetail, 'id_categorie', body ?? {});
      if (method == 'DELETE') return _supprimer(_categories, categorieDetail, 'id_categorie');
      if (method == 'GET') return _trouver(_categories, categorieDetail, 'id_categorie');
    } else if (endpoint == ApiConstants.categories) {
      if (method == 'GET') return _categories;
      if (method == 'POST') return _creer(_categories, body ?? {}, 'id_categorie', () => _prochainIdCategorie++);
    }

    // ---- Fournisseurs : collection + détail ----
    final fournisseurDetail = _extraireId(endpoint, ApiConstants.fournisseurs);
    if (fournisseurDetail != null) {
      if (method == 'PUT') return _mettreAJour(_fournisseurs, fournisseurDetail, 'id_fournisseur', body ?? {});
      if (method == 'DELETE') return _supprimer(_fournisseurs, fournisseurDetail, 'id_fournisseur');
      if (method == 'GET') return _trouver(_fournisseurs, fournisseurDetail, 'id_fournisseur');
    } else if (endpoint == ApiConstants.fournisseurs) {
      if (method == 'GET') return _fournisseurs;
      if (method == 'POST') return _creer(_fournisseurs, body ?? {}, 'id_fournisseur', () => _prochainIdFournisseur++);
    }

    if (endpoint == ApiConstants.clients && method == 'GET') {
      return _clients;
    }

    // ---- Stocks : collection + détail ----
    final stockDetail = _extraireId(endpoint, ApiConstants.stocks);
    if (stockDetail != null) {
      if (method == 'PUT') return _mettreAJour(_stocks, stockDetail, 'id_stock', body ?? {});
      if (method == 'DELETE') return _supprimer(_stocks, stockDetail, 'id_stock');
      if (method == 'GET') return _trouver(_stocks, stockDetail, 'id_stock');
    } else if (endpoint == ApiConstants.stocks) {
      if (method == 'GET') return _stocks;
      if (method == 'POST') return _creer(_stocks, body ?? {}, 'id_stock', () => _prochainIdStock++);
    }

    // ---- Mouvements de stock ----
    if (endpoint == ApiConstants.mouvementsStock) {
      if (method == 'GET') return _mouvements;
      if (method == 'POST') {
        final nouveau = _creer(_mouvements, body ?? {}, 'id_mouvement', () => _prochainIdMouvement++);
        // Met à jour automatiquement la quantité disponible du produit concerné.
        _appliquerMouvementSurStock(nouveau);
        return nouveau;
      }
    }

    // ---- Achats : collection + détail ----
    final achatDetail = _extraireId(endpoint, ApiConstants.achats);
    if (achatDetail != null) {
      if (method == 'PUT') return _mettreAJour(_achats, achatDetail, 'id_achat', body ?? {});
      if (method == 'DELETE') return _supprimer(_achats, achatDetail, 'id_achat');
      if (method == 'GET') return _trouver(_achats, achatDetail, 'id_achat');
    } else if (endpoint == ApiConstants.achats) {
      if (method == 'GET') return _achats;
      if (method == 'POST') return _creerAchat(body ?? {});
    }

    // ---- Dépenses : collection + détail ----
    final depenseDetail = _extraireId(endpoint, ApiConstants.depenses);
    if (depenseDetail != null) {
      if (method == 'PUT') return _mettreAJour(_depenses, depenseDetail, 'id_depense', body ?? {});
      if (method == 'DELETE') return _supprimer(_depenses, depenseDetail, 'id_depense');
      if (method == 'GET') return _trouver(_depenses, depenseDetail, 'id_depense');
    } else if (endpoint == ApiConstants.depenses) {
      if (method == 'GET') return _depenses;
      if (method == 'POST') return _creer(_depenses, body ?? {}, 'id_depense', () => _prochainIdDepense++);
    }

    // ---- Utilisateurs : collection + détail ----
    final utilisateurDetail = _extraireId(endpoint, ApiConstants.utilisateurs);
    if (utilisateurDetail != null) {
      if (method == 'PUT') return _mettreAJour(_utilisateurs, utilisateurDetail, 'id_utilisateur', body ?? {});
      if (method == 'DELETE') return _supprimer(_utilisateurs, utilisateurDetail, 'id_utilisateur');
      if (method == 'GET') return _trouver(_utilisateurs, utilisateurDetail, 'id_utilisateur');
    } else if (endpoint == ApiConstants.utilisateurs) {
      if (method == 'GET') return _utilisateurs;
      if (method == 'POST') return _creer(_utilisateurs, body ?? {}, 'id_utilisateur', () => _prochainIdUtilisateur++);
    }

    // ---- Rôles ----
    if (endpoint == '/roles/' && method == 'GET') {
      return _roles;
    }

    // ---- Ventes / détails / paiements ----
    if (endpoint == ApiConstants.ventes && method == 'POST') {
      return _creerVente(body ?? {});
    }

    if (endpoint == ApiConstants.paiements && method == 'POST') {
      return _creerPaiement(body ?? {});
    }

    if (endpoint == ApiConstants.ventes && method == 'GET') {
      return _ventes;
    }

    throw Exception('Endpoint mock non implémenté : $method $endpoint');
  }

  // --------------------------------------------------------------------
  // Helpers CRUD génériques (utilisés par produits/catégories/fournisseurs/...)
  // --------------------------------------------------------------------

  /// Si [endpoint] est de la forme "$base$id/", retourne l'id (int), sinon null.
  static int? _extraireId(String endpoint, String base) {
    if (!endpoint.startsWith(base)) return null;
    final reste = endpoint.substring(base.length);
    final nettoye = reste.endsWith('/') ? reste.substring(0, reste.length - 1) : reste;
    if (nettoye.isEmpty) return null;
    return int.tryParse(nettoye);
  }

  /// Extrait la valeur d'un paramètre de query string, ex: "/rapports/?periode=mois" → "mois".
  static String? _extraireParam(String endpoint, String cle) {
    final q = endpoint.split('?').last;
    for (final part in q.split('&')) {
      final kv = part.split('=');
      if (kv.length == 2 && kv[0] == cle) return kv[1];
    }
    return null;
  }

  static Map<String, dynamic> _creer(
    List<Map<String, dynamic>> liste,
    Map<String, dynamic> body,
    String cleId,
    int Function() prochainId,
  ) {
    final nouveau = Map<String, dynamic>.from(body);
    nouveau[cleId] = prochainId();
    liste.add(nouveau);
    return nouveau;
  }

  static Map<String, dynamic> _mettreAJour(
    List<Map<String, dynamic>> liste,
    int id,
    String cleId,
    Map<String, dynamic> body,
  ) {
    final index = liste.indexWhere((e) => e[cleId] == id);
    if (index == -1) throw Exception('Élément $id introuvable');
    final maj = Map<String, dynamic>.from(body);
    maj[cleId] = id;
    liste[index] = maj;
    return maj;
  }

  static Map<String, dynamic> _trouver(List<Map<String, dynamic>> liste, int id, String cleId) {
    return liste.firstWhere((e) => e[cleId] == id, orElse: () => throw Exception('Élément $id introuvable'));
  }

  static Map<String, dynamic> _supprimer(List<Map<String, dynamic>> liste, int id, String cleId) {
    final index = liste.indexWhere((e) => e[cleId] == id);
    if (index == -1) throw Exception('Élément $id introuvable');
    final supprime = liste.removeAt(index);
    return supprime;
  }

  // --------------------------------------------------------------------
  // Logique métier spécifique
  // --------------------------------------------------------------------

  static Map<String, dynamic> _login(Map<String, dynamic> body) {
    final username = body['username'];
    final password = body['password'];

    if (username == 'admin' && password == 'admin123') {
      return {
        'access': 'mock-access-token',
        'refresh': 'mock-refresh-token',
        'utilisateur': {
          'id': 1,
          'username': 'admin',
          'nom': 'Masse',
          'prenom': 'Paulo',
          'telephone': '699000000',
          'email': 'admin@front-boisson.test',
          'statut': 'actif',
          'role': {
            'id_role': 1,
            'nom_role': 'Administrateur',
            'description': null,
            'actif': true,
          },
        },
      };
    }

    throw Exception('Identifiants invalides (mode démo : admin / admin123)');
  }

  static Map<String, dynamic> _dashboard() {
    final maintenant = DateTime.now();
    return {
      'date':
          '${maintenant.year}-${maintenant.month.toString().padLeft(2, '0')}-${maintenant.day.toString().padLeft(2, '0')}',
      'chiffre_affaires_jour': 125000,
      'nombre_tickets_jour': 34,
      'depenses_jour': 15000,
      'produits_stock_faible': [
        {'produit': 'Whisky 70cl', 'quantite': 3, 'seuil': 10},
        {'produit': 'Bière 33cl', 'quantite': 8, 'seuil': 20},
      ],
    };
  }

  static Map<String, dynamic> _rapportVentes(String endpoint) {
    return {
      'periode': {
        'debut': _extraireParam(endpoint, 'date_debut'),
        'fin': _extraireParam(endpoint, 'date_fin'),
      },
      'total_ventes': 780000,
      'nombre_ventes': 218,
      'detail_par_jour': [
        for (int i = 6; i >= 0; i--)
          {
            'jour': DateTime.now()
                .subtract(Duration(days: i))
                .toIso8601String()
                .substring(0, 10),
            'total_jour': 95000 + (i * 5000),
            'tickets': 24 + i,
          },
      ],
    };
  }

  static Map<String, dynamic> _rapportProduits(String endpoint) {
    return {
      'periode': {
        'debut': _extraireParam(endpoint, 'date_debut'),
        'fin': _extraireParam(endpoint, 'date_fin'),
      },
      'top_produits': [
        {'produit__nom': 'Bière 33cl', 'quantite_totale': 420, 'chiffre_affaires': 210000},
        {'produit__nom': 'Whisky 70cl', 'quantite_totale': 85, 'chiffre_affaires': 425000},
      ],
    };
  }

  static Map<String, dynamic> _rapportDepenses(String endpoint) {
    return {
      'periode': {
        'debut': _extraireParam(endpoint, 'date_debut'),
        'fin': _extraireParam(endpoint, 'date_fin'),
      },
      'total_depenses': 245000,
      'par_categorie': [
        {'categorie': 'Électricité', 'total_categorie': 45000},
        {'categorie': 'Salaires', 'total_categorie': 120000},
      ],
    };
  }

  static Map<String, dynamic> _rapportAchats(String endpoint) {
    return {
      'periode': {
        'debut': _extraireParam(endpoint, 'date_debut'),
        'fin': _extraireParam(endpoint, 'date_fin'),
      },
      'total_achats': 125250,
      'nombre_achats': 1,
      'par_fournisseur': [
        {
          'fournisseur__raison_sociale': 'Brasseries du Cameroun',
          'total_fournisseur': 125250,
          'nombre_achats': 1,
        },
      ],
    };
  }

  /// Applique l'effet d'un mouvement sur la ligne de stock correspondante.
  /// - `entree` : la quantité est ajoutée à `quantite_disponible`.
  /// - `sortie` : la quantité est soustraite.
  /// - `ajustement` : la quantité remplace `quantite_disponible` (inventaire).
  static void _appliquerMouvementSurStock(Map<String, dynamic> mouvement) {
    final idProduit = mouvement['id_produit'] as int;
    final type = mouvement['type_mouvement'].toString();
    final quantite = mouvement['quantite'] as int;

    final index = _stocks.indexWhere((s) => s['id_produit'] == idProduit);
    if (index == -1) {
      // Pas encore de ligne de stock pour ce produit : on en crée une.
      _stocks.add({
        'id_stock': _prochainIdStock++,
        'id_produit': idProduit,
        'quantite_disponible': type == 'sortie' ? 0 : quantite,
        'seuil_alerte': 0,
      });
      return;
    }

    final stock = _stocks[index];
    final actuel = stock['quantite_disponible'] as int;
    if (type == 'entree') {
      stock['quantite_disponible'] = actuel + quantite;
    } else if (type == 'sortie') {
      stock['quantite_disponible'] = (actuel - quantite).clamp(0, 1 << 31);
    } else if (type == 'ajustement') {
      stock['quantite_disponible'] = quantite;
    }
  }

  /// Crée un achat, ses lignes de détail, et alimente automatiquement le stock
  /// avec un mouvement d'entrée pour chaque produit de la commande.
  static Map<String, dynamic> _creerAchat(Map<String, dynamic> body) {
    final idAchat = _prochainIdAchat++;
    final lignes = (body['lignes'] as List?) ?? const [];
    double total = 0;

    for (final ligne in lignes) {
      final qte = (ligne['quantite'] as num).toInt();
      final pu = (ligne['prix_unitaire'] as num).toDouble();
      total += qte * pu;
    }

    final achat = {
      'id_achat': idAchat,
      'date_achat': DateTime.now().toIso8601String(),
      'montant_total': total,
      'statut': body['statut'] ?? 'recu',
      'id_fournisseur': body['id_fournisseur'],
      'id_utilisateur': body['id_utilisateur'] ?? 1,
    };
    _achats.add(achat);

    // Crée les lignes de détail + les mouvements de stock associés.
    for (final ligne in lignes) {
      final idDetail = _prochainIdDetailAchat++;
      final qte = (ligne['quantite'] as num).toInt();
      final pu = (ligne['prix_unitaire'] as num).toDouble();
      _detailsAchat.add({
        'id_detail': idDetail,
        'id_achat': idAchat,
        'id_produit': ligne['id_produit'],
        'quantite': qte,
        'prix_unitaire': pu,
        'sous_total': qte * pu,
      });

      // Mouvement d'entrée automatique, référencé à l'achat.
      final idMvt = _prochainIdMouvement++;
      _mouvements.add({
        'id_mouvement': idMvt,
        'id_produit': ligne['id_produit'],
        'type_mouvement': 'entree',
        'quantite': qte,
        'date_mouvement': DateTime.now().toIso8601String(),
        'id_utilisateur': body['id_utilisateur'] ?? 1,
        'reference_operation': 'ACH-${idAchat.toString().padLeft(3, '0')}',
      });
      _appliquerMouvementSurStock(_mouvements.last);
    }

    return achat;
  }

  /// Génère un rapport agrégé sur la période demandée.
  /// Périodes supportées : `jour`, `semaine`, `mois`, `annee`.
  static Map<String, dynamic> _genererRapportLegacy(String periode) {
    // Les chiffres ci-dessous sont des constantes réalistes pour la démo ;
    // ils seront remplacés par les vraies agrégations Django une fois le backend branché.
    final maintenant = DateTime.now();
    final Map<String, dynamic> base = {
      'periode': periode,
      'date_generation': maintenant.toIso8601String(),
      'top_produits': [
        {'id_produit': 1, 'nom': '33 Export 65cl', 'quantite_vendue': 48, 'ca': 36000},
        {'id_produit': 5, 'nom': 'Coca-Cola 50cl', 'quantite_vendue': 36, 'ca': 18000},
        {'id_produit': 3, 'nom': 'Guinness 33cl', 'quantite_vendue': 28, 'ca': 23800},
        {'id_produit': 10, 'nom': 'Whisky 70cl', 'quantite_vendue': 6, 'ca': 54000},
        {'id_produit': 8, 'nom': 'Jus de gingembre 1L', 'quantite_vendue': 15, 'ca': 18000},
      ],
      'ventes_par_mode_paiement': [
        {'mode': 'espèces', 'nombre': 28, 'montant': 95000},
        {'mode': 'mobile money', 'nombre': 6, 'montant': 30000},
      ],
      'depenses_par_categorie': [
        {'categorie': 'Charges fixes', 'montant': 45000},
        {'categorie': 'Carburant', 'montant': 15000},
        {'categorie': 'Fournitures', 'montant': 5000},
      ],
    };

    switch (periode) {
      case 'jour':
        return {
          ...base,
          'libelle_periode': "Aujourd'hui (${_formatDate(maintenant)})",
          'chiffre_affaires': 125000.0,
          'nombre_ventes': 34,
          'depenses_total': 65000.0,
          'benefice_net': 60000.0,
          'panier_moyen': 3676.0,
        };
      case 'semaine':
        return {
          ...base,
          'libelle_periode': 'Cette semaine',
          'chiffre_affaires': 780000.0,
          'nombre_ventes': 218,
          'depenses_total': 245000.0,
          'benefice_net': 535000.0,
          'panier_moyen': 3578.0,
        };
      case 'mois':
        return {
          ...base,
          'libelle_periode': 'Ce mois-ci',
          'chiffre_affaires': 2450000.0,
          'nombre_ventes': 612,
          'depenses_total': 380000.0,
          'benefice_net': 2070000.0,
          'panier_moyen': 4003.0,
        };
      case 'annee':
        return {
          ...base,
          'libelle_periode': 'Cette année',
          'chiffre_affaires': 28500000.0,
          'nombre_ventes': 7340,
          'depenses_total': 4600000.0,
          'benefice_net': 23900000.0,
          'panier_moyen': 3883.0,
        };
      default:
        return {...base, 'libelle_periode': periode, 'chiffre_affaires': 0.0, 'nombre_ventes': 0, 'depenses_total': 0.0, 'benefice_net': 0.0, 'panier_moyen': 0.0};
    }
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  static Map<String, dynamic> _creerVente(Map<String, dynamic> body) {
    final id = _prochainIdVente++;
    final details = (body['details'] as List?) ?? [];
    var montant = 0.0;
    for (final d in details) {
      if (d is Map) {
        montant += (d['quantite'] as num) * (d['prix_unitaire'] as num);
      }
    }
    final remise = (body['remise'] as num?)?.toDouble() ?? 0;
    final vente = {
      'id_vente': id,
      'reference': body['reference'] ?? 'V${DateTime.now().year}-${id.toString().padLeft(4, '0')}',
      'date_vente': DateTime.now().toIso8601String(),
      'montant_total': montant - remise,
      'remise': remise,
      'statut': 'validee',
      'utilisateur': 1,
      'client': body['client'],
      'caisse': body['caisse'],
      'details': details,
    };
    _ventes.add(vente);
    return vente;
  }

  static Map<String, dynamic> _creerPaiement(Map<String, dynamic> body) {
    final id = _prochainIdPaiement++;
    final paiement = {
      'id_paiement': id,
      'vente': body['vente'] ?? body['id_vente'],
      'mode_paiement': body['mode_paiement'],
      'montant': body['montant'],
      'reference_transaction': body['reference_transaction'],
      'date_paiement': DateTime.now().toIso8601String(),
    };
    _paiements.add(paiement);
    return paiement;
  }
}
