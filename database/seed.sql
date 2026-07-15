-- ============================================================================
-- seeds.sql
-- Application POS - Débits de Boissons
-- Phase 4 - Jeu de données de test (Seeding)
-- Prérequis : schema.sql doit avoir été exécuté au préalable
-- Convention monétaire : Franc CFA (XAF), NUMERIC(10,2)
-- ============================================================================

-- ============================================================================
-- 1. RÔLES
-- ============================================================================
INSERT INTO roles (nom_role, description, actif) VALUES
('Administrateur', 'Accès complet à la configuration et à la supervision du système', TRUE),
('Gérant',         'Supervision commerciale, produits, fournisseurs et stocks',          TRUE),
('Caissier',       'Enregistrement des ventes, paiements et gestion de caisse',          TRUE),
('Magasinier',     'Gestion des approvisionnements, mouvements de stock et inventaires', TRUE),
('Serveur',        'Prise de commandes clients et transmission au caissier',             TRUE),
('Comptable',      'Consultation des rapports financiers, dépenses et achats',           TRUE);

-- ============================================================================
-- 2. CATÉGORIES DE PRODUITS
-- ============================================================================
INSERT INTO categories (nom, description, actif) VALUES
('Bières',          'Bières locales et importées',            TRUE),
('Sodas',            'Boissons gazeuses',                       TRUE),
('Jus',              'Jus de fruits',                           TRUE),
('Eaux minérales',   'Eaux plates et gazeuses',                 TRUE),
('Spiritueux',       'Whisky, pastis et autres alcools forts',  TRUE),
('Vins',             'Vins rouges, blancs et rosés',             TRUE);

-- ============================================================================
-- 3. FOURNISSEURS
-- ============================================================================
INSERT INTO fournisseurs (raison_sociale, telephone, adresse, email, actif) VALUES
('Brasseries du Cameroun SA',     '+237699000001', 'Zone Industrielle, Douala',   'contact@brasseries-cm.com', TRUE),
('Distributeur Boissons Sarl',    '+237699000002', 'Marché Central, Yaoundé',     'contact@distrib-boissons.cm', TRUE),
('Cave Import Spiritueux',        '+237699000003', 'Bastos, Yaoundé',             'contact@cave-import.cm', TRUE);

-- ============================================================================
-- 4. CLIENTS
-- ============================================================================
INSERT INTO clients (nom, prenom, telephone, email, adresse, actif) VALUES
('Mballa',  'Jean',   '+237677111111', 'jean.mballa@mail.com',  'Bastos, Yaoundé',     TRUE),
('Ateba',   'Chantal','+237677222222', 'chantal.ateba@mail.com','Mvog-Mbi, Yaoundé',   TRUE);

-- ============================================================================
-- 5. UTILISATEURS (mots de passe simulés = hash factice, à remplacer par bcrypt/argon2)
-- ============================================================================
INSERT INTO utilisateurs (nom, prenom, telephone, email, nom_utilisateur, mot_de_passe, statut, id_role) VALUES
('Fotso',  'Michel',  '+237690111111', 'michel.fotso@possarl.cm',  'admin',
    '$2b$12$FAKEHASHADMIN0000000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Administrateur')),
('Nguema', 'Sylvie',  '+237690222222', 'sylvie.nguema@possarl.cm', 'gerant1',
    '$2b$12$FAKEHASHGERANT00000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Gérant')),
('Biya',   'Paul',    '+237690333333', 'paul.biya.k@possarl.cm',   'caissier1',
    '$2b$12$FAKEHASHCAISSIER000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Caissier')),
('Ekanga', 'Brice',   '+237690444444', 'brice.ekanga@possarl.cm',  'magasinier1',
    '$2b$12$FAKEHASHMAGASIN000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Magasinier')),
('Manga',  'Claire',  '+237690555555', 'claire.manga@possarl.cm',  'serveur1',
    '$2b$12$FAKEHASHSERVEUR000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Serveur')),
('Owona',  'Denise',  '+237690666666', 'denise.owona@possarl.cm',  'comptable1',
    '$2b$12$FAKEHASHCOMPTAB000000000000000000000000000000000', 'actif',
    (SELECT id_role FROM roles WHERE nom_role = 'Comptable'));

-- ============================================================================
-- 6. PRODUITS (15 articles réalistes)
-- ============================================================================
INSERT INTO produits (code, code_barres, nom, description, prix_achat, prix_vente, contenance, stock_minimum, id_categorie, id_fournisseur) VALUES
('BIE-001', '6161101000011', 'Castel Beer 33cl',       'Bière locale blonde',         350.00,  500.00,  '33cl', 20,
    (SELECT id_categorie FROM categories WHERE nom = 'Bières'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('BIE-002', '6161101000028', 'Guinness 33cl',          'Bière brune stout',           450.00,  700.00,  '33cl', 20,
    (SELECT id_categorie FROM categories WHERE nom = 'Bières'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('BIE-003', '6161101000035', '33 Export 65cl',        'Bière locale format familial', 600.00,  900.00,  '65cl', 15,
    (SELECT id_categorie FROM categories WHERE nom = 'Bières'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('BIE-004', '6161101000042', 'Booster 65cl',           'Bière forte locale',          650.00, 1000.00,  '65cl', 15,
    (SELECT id_categorie FROM categories WHERE nom = 'Bières'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('SOD-001', '6161102000011', 'Coca-Cola 33cl',         'Boisson gazeuse cola',        300.00,  500.00,  '33cl', 30,
    (SELECT id_categorie FROM categories WHERE nom = 'Sodas'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('SOD-002', '6161102000028', 'Fanta Orange 33cl',      'Boisson gazeuse orange',      300.00,  500.00,  '33cl', 30,
    (SELECT id_categorie FROM categories WHERE nom = 'Sodas'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('SOD-003', '6161102000035', 'Sprite 33cl',            'Boisson gazeuse citron-lime', 300.00,  500.00,  '33cl', 30,
    (SELECT id_categorie FROM categories WHERE nom = 'Sodas'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('SOD-004', '6161102000042', 'Malta Guinness 33cl',    'Boisson maltée sans alcool',  400.00,  600.00,  '33cl', 20,
    (SELECT id_categorie FROM categories WHERE nom = 'Sodas'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')),
('JUS-001', '6161103000011', 'Djino Ananas 33cl',      'Jus de fruit ananas',         350.00,  550.00,  '33cl', 20,
    (SELECT id_categorie FROM categories WHERE nom = 'Jus'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Distributeur Boissons Sarl')),
('JUS-002', '6161103000028', 'Planet Pomme 1L',        'Jus de pomme 100%',           900.00, 1300.00,  '1L',   10,
    (SELECT id_categorie FROM categories WHERE nom = 'Jus'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Distributeur Boissons Sarl')),
('EAU-001', '6161104000011', 'Supermont 1.5L',         'Eau minérale plate',          350.00,  500.00,  '1.5L', 25,
    (SELECT id_categorie FROM categories WHERE nom = 'Eaux minérales'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Distributeur Boissons Sarl')),
('EAU-002', '6161104000028', 'Tangui 1.5L',            'Eau minérale plate',          350.00,  500.00,  '1.5L', 25,
    (SELECT id_categorie FROM categories WHERE nom = 'Eaux minérales'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Distributeur Boissons Sarl')),
('SPI-001', '6161105000011', 'Whisky Jameson 70cl',    'Whisky irlandais',          12000.00, 18000.00, '70cl',  5,
    (SELECT id_categorie FROM categories WHERE nom = 'Spiritueux'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Cave Import Spiritueux')),
('SPI-002', '6161105000028', 'Pastis 51 70cl',         'Apéritif anisé',             8000.00, 12000.00, '70cl',  5,
    (SELECT id_categorie FROM categories WHERE nom = 'Spiritueux'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Cave Import Spiritueux')),
('VIN-001', '6161106000011', 'Vin Rouge Baron 75cl',   'Vin rouge de table',         2500.00,  4000.00, '75cl',  8,
    (SELECT id_categorie FROM categories WHERE nom = 'Vins'), (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Cave Import Spiritueux'));

-- ============================================================================
-- 7. STOCKS INITIAUX (une fiche stock par produit)
-- ============================================================================
INSERT INTO stocks (id_produit, quantite_disponible, seuil_alerte)
SELECT id_produit,
       CASE
           WHEN code IN ('BIE-001','SOD-001','SOD-002','SOD-003') THEN 150
           WHEN code IN ('BIE-002','SOD-004','JUS-001')            THEN 100
           WHEN code IN ('BIE-003','BIE-004','EAU-001','EAU-002')  THEN 80
           WHEN code IN ('JUS-002')                                 THEN 40
           WHEN code IN ('VIN-001')                                 THEN 20
           WHEN code IN ('SPI-001','SPI-002')                       THEN 10
       END AS quantite_disponible,
       stock_minimum AS seuil_alerte
FROM produits;

-- ============================================================================
-- 8. MOUVEMENTS DE STOCK INITIAUX (entrée d'ouverture pour chaque produit)
-- ============================================================================
INSERT INTO mouvements_stock (id_produit, type_mouvement, quantite, id_utilisateur, reference_operation)
SELECT s.id_produit, 'entree', s.quantite_disponible,
       (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1'),
       'STOCK-INIT-' || p.code
FROM stocks s
JOIN produits p ON p.id_produit = s.id_produit;

-- ============================================================================
-- 9. OUVERTURE DE CAISSE
-- ============================================================================
INSERT INTO caisses (date_ouverture, montant_initial, statut, id_utilisateur) VALUES
(now(), 20000.00, 'ouverte',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'));

-- ============================================================================
-- 10. ACHAT / APPROVISIONNEMENT (réception fournisseur)
-- ============================================================================
INSERT INTO achats (date_achat, montant_total, statut, id_fournisseur, id_utilisateur) VALUES
(now(), 65000.00, 'valide',
    (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA'),
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1'));

INSERT INTO detail_achats (id_achat, id_produit, quantite, prix_unitaire)
SELECT
    (SELECT id_achat FROM achats
        WHERE id_fournisseur = (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')
        ORDER BY id_achat DESC LIMIT 1),
    (SELECT id_produit FROM produits WHERE code = 'BIE-001'),
    100, 350.00
UNION ALL
SELECT
    (SELECT id_achat FROM achats
        WHERE id_fournisseur = (SELECT id_fournisseur FROM fournisseurs WHERE raison_sociale = 'Brasseries du Cameroun SA')
        ORDER BY id_achat DESC LIMIT 1),
    (SELECT id_produit FROM produits WHERE code = 'SOD-001'),
    100, 300.00;

-- ============================================================================
-- 11. VENTES (5 transactions variées) + DÉTAILS + PAIEMENTS
-- ============================================================================

-- --- Vente 1 : client Mballa Jean, paiement espèces ---
INSERT INTO ventes (reference, date_vente, montant_total, remise, statut, id_utilisateur, id_client, id_caisse) VALUES
('VTE-0001', now(), 1500.00, 0.00, 'validee',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'),
    (SELECT id_client FROM clients WHERE telephone = '+237677111111'),
    (SELECT id_caisse FROM caisses ORDER BY id_caisse DESC LIMIT 1));

INSERT INTO detail_ventes (id_vente, id_produit, quantite, prix_unitaire) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0001'), (SELECT id_produit FROM produits WHERE code = 'BIE-001'), 2, 500.00),
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0001'), (SELECT id_produit FROM produits WHERE code = 'SOD-001'), 1, 500.00);

INSERT INTO paiements (id_vente, mode_paiement, montant) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0001'), 'especes', 1500.00);

-- --- Vente 2 : client anonyme, paiement Mobile Money ---
INSERT INTO ventes (reference, date_vente, montant_total, remise, statut, id_utilisateur, id_client, id_caisse) VALUES
('VTE-0002', now(), 2500.00, 0.00, 'validee',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'),
    NULL,
    (SELECT id_caisse FROM caisses ORDER BY id_caisse DESC LIMIT 1));

INSERT INTO detail_ventes (id_vente, id_produit, quantite, prix_unitaire) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0002'), (SELECT id_produit FROM produits WHERE code = 'SOD-002'), 3, 500.00),
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0002'), (SELECT id_produit FROM produits WHERE code = 'SOD-003'), 2, 500.00);

INSERT INTO paiements (id_vente, mode_paiement, montant, reference_transaction) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0002'), 'mobile_money', 2500.00, 'MOMO-TXN-000234');

-- --- Vente 3 : client Ateba Chantal, produit haut de gamme avec remise, carte bancaire ---
INSERT INTO ventes (reference, date_vente, montant_total, remise, statut, id_utilisateur, id_client, id_caisse) VALUES
('VTE-0003', now(), 17000.00, 1000.00, 'validee',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'),
    (SELECT id_client FROM clients WHERE telephone = '+237677222222'),
    (SELECT id_caisse FROM caisses ORDER BY id_caisse DESC LIMIT 1));

INSERT INTO detail_ventes (id_vente, id_produit, quantite, prix_unitaire) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0003'), (SELECT id_produit FROM produits WHERE code = 'SPI-001'), 1, 18000.00);

INSERT INTO paiements (id_vente, mode_paiement, montant, reference_transaction) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0003'), 'carte_bancaire', 17000.00, 'CB-TXN-000987');

-- --- Vente 4 : client anonyme, paiement mixte (espèces + Mobile Money) ---
INSERT INTO ventes (reference, date_vente, montant_total, remise, statut, id_utilisateur, id_client, id_caisse) VALUES
('VTE-0004', now(), 4700.00, 0.00, 'validee',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'),
    NULL,
    (SELECT id_caisse FROM caisses ORDER BY id_caisse DESC LIMIT 1));

INSERT INTO detail_ventes (id_vente, id_produit, quantite, prix_unitaire) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0004'), (SELECT id_produit FROM produits WHERE code = 'BIE-002'), 5, 700.00),
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0004'), (SELECT id_produit FROM produits WHERE code = 'SOD-004'), 2, 600.00);

INSERT INTO paiements (id_vente, mode_paiement, montant) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0004'), 'especes', 3000.00);
INSERT INTO paiements (id_vente, mode_paiement, montant, reference_transaction) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0004'), 'mobile_money', 1700.00, 'MOMO-TXN-000235');

-- --- Vente 5 : client Mballa Jean, panier varié, paiement espèces ---
INSERT INTO ventes (reference, date_vente, montant_total, remise, statut, id_utilisateur, id_client, id_caisse) VALUES
('VTE-0005', now(), 2550.00, 0.00, 'validee',
    (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'),
    (SELECT id_client FROM clients WHERE telephone = '+237677111111'),
    (SELECT id_caisse FROM caisses ORDER BY id_caisse DESC LIMIT 1));

INSERT INTO detail_ventes (id_vente, id_produit, quantite, prix_unitaire) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0005'), (SELECT id_produit FROM produits WHERE code = 'EAU-001'), 2, 500.00),
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0005'), (SELECT id_produit FROM produits WHERE code = 'JUS-001'), 1, 550.00),
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0005'), (SELECT id_produit FROM produits WHERE code = 'BIE-004'), 1, 1000.00);

INSERT INTO paiements (id_vente, mode_paiement, montant) VALUES
((SELECT id_vente FROM ventes WHERE reference = 'VTE-0005'), 'especes', 2550.00);

-- ============================================================================
-- 12. MOUVEMENTS DE STOCK LIÉS AUX VENTES (sorties)
-- ============================================================================
INSERT INTO mouvements_stock (id_produit, type_mouvement, quantite, id_utilisateur, reference_operation) VALUES
((SELECT id_produit FROM produits WHERE code = 'BIE-001'), 'vente', -2, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0001'),
((SELECT id_produit FROM produits WHERE code = 'SOD-001'), 'vente', -1, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0001'),
((SELECT id_produit FROM produits WHERE code = 'SOD-002'), 'vente', -3, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0002'),
((SELECT id_produit FROM produits WHERE code = 'SOD-003'), 'vente', -2, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0002'),
((SELECT id_produit FROM produits WHERE code = 'SPI-001'), 'vente', -1, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0003'),
((SELECT id_produit FROM produits WHERE code = 'BIE-002'), 'vente', -5, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0004'),
((SELECT id_produit FROM produits WHERE code = 'SOD-004'), 'vente', -2, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0004'),
((SELECT id_produit FROM produits WHERE code = 'EAU-001'), 'vente', -2, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0005'),
((SELECT id_produit FROM produits WHERE code = 'JUS-001'), 'vente', -1, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0005'),
((SELECT id_produit FROM produits WHERE code = 'BIE-004'), 'vente', -1, (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'VTE-0005');

-- ============================================================================
-- 13. MISE À JOUR DES QUANTITÉS DE STOCK (répercussion des ventes)
-- ============================================================================
UPDATE stocks SET quantite_disponible = quantite_disponible - 2, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'BIE-001');
UPDATE stocks SET quantite_disponible = quantite_disponible - 1, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'SOD-001');
UPDATE stocks SET quantite_disponible = quantite_disponible - 3, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'SOD-002');
UPDATE stocks SET quantite_disponible = quantite_disponible - 2, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'SOD-003');
UPDATE stocks SET quantite_disponible = quantite_disponible - 1, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'SPI-001');
UPDATE stocks SET quantite_disponible = quantite_disponible - 5, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'BIE-002');
UPDATE stocks SET quantite_disponible = quantite_disponible - 2, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'SOD-004');
UPDATE stocks SET quantite_disponible = quantite_disponible - 2, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'EAU-001');
UPDATE stocks SET quantite_disponible = quantite_disponible - 1, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'JUS-001');
UPDATE stocks SET quantite_disponible = quantite_disponible - 1, date_maj = now()
    WHERE id_produit = (SELECT id_produit FROM produits WHERE code = 'BIE-004');

-- ============================================================================
-- 14. DÉPENSES DE FONCTIONNEMENT
-- ============================================================================
INSERT INTO depenses (libelle, categorie, montant, date_depense, id_utilisateur) VALUES
('Facture ENEO électricité',    'electricite', 45000.00, now(), (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1')),
('Facture CAMWATER eau',        'eau',          15000.00, now(), (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1')),
('Transport approvisionnement', 'transport',    10000.00, now(), (SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1'));

-- ============================================================================
-- 15. JOURNAL D'ACTIVITÉ (traçabilité des actions clés)
-- ============================================================================
INSERT INTO journal_activite (id_utilisateur, action, description, adresse_ip) VALUES
((SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'admin'),     'connexion',        'Connexion réussie de l''administrateur',            '192.168.1.10'),
((SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'gerant1'),   'connexion',        'Connexion réussie du gérant',                        '192.168.1.11'),
((SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'ouverture_caisse', 'Ouverture de caisse avec fond initial de 20000 FCFA', '192.168.1.12'),
((SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'vente',            'Création de la vente VTE-0001',                       '192.168.1.12'),
((SELECT id_utilisateur FROM utilisateurs WHERE nom_utilisateur = 'caissier1'), 'vente',            'Création de la vente VTE-0003 avec remise appliquée', '192.168.1.12');

-- ============================================================================
-- FIN DU SCRIPT DE SEEDING
-- ============================================================================
