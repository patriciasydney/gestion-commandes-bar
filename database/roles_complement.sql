-- Complément rôles manquants (bases déjà initialisées avec seed.sql ancien)
-- Usage : psql -d test_dsi -f database/roles_complement.sql

INSERT INTO roles (nom_role, description, actif) VALUES
('Magasinier', 'Gestion des approvisionnements, mouvements de stock et inventaires', TRUE),
('Serveur',    'Prise de commandes clients et transmission au caissier',             TRUE),
('Comptable',  'Consultation des rapports financiers, dépenses et achats',           TRUE)
ON CONFLICT (nom_role) DO NOTHING;

INSERT INTO utilisateurs (nom, prenom, telephone, email, nom_utilisateur, mot_de_passe, statut, id_role)
SELECT 'Ekanga', 'Brice', '+237690444444', 'brice.ekanga@possarl.cm', 'magasinier1',
       '$2b$12$FAKEHASHMAGASIN000000000000000000000000000000000', 'actif',
       id_role FROM roles WHERE nom_role = 'Magasinier'
AND NOT EXISTS (SELECT 1 FROM utilisateurs WHERE nom_utilisateur = 'magasinier1');

INSERT INTO utilisateurs (nom, prenom, telephone, email, nom_utilisateur, mot_de_passe, statut, id_role)
SELECT 'Manga', 'Claire', '+237690555555', 'claire.manga@possarl.cm', 'serveur1',
       '$2b$12$FAKEHASHSERVEUR000000000000000000000000000000000', 'actif',
       id_role FROM roles WHERE nom_role = 'Serveur'
AND NOT EXISTS (SELECT 1 FROM utilisateurs WHERE nom_utilisateur = 'serveur1');

INSERT INTO utilisateurs (nom, prenom, telephone, email, nom_utilisateur, mot_de_passe, statut, id_role)
SELECT 'Owona', 'Denise', '+237690666666', 'denise.owona@possarl.cm', 'comptable1',
       '$2b$12$FAKEHASHCOMPTAB000000000000000000000000000000000', 'actif',
       id_role FROM roles WHERE nom_role = 'Comptable'
AND NOT EXISTS (SELECT 1 FROM utilisateurs WHERE nom_utilisateur = 'comptable1');
