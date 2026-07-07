-- ============================================================================
-- schema.sql
-- Application de Gestion de Point de Vente (POS) - Débits de Boissons
-- SGBD : PostgreSQL 15+
-- Phase 2 - Script DDL d'initialisation
-- ============================================================================

-- ============================================================================
-- 1. SUPPRESSION DES TABLES EXISTANTES (ordre inverse des dépendances)
-- ============================================================================
DROP TABLE IF EXISTS journal_activite CASCADE;
DROP TABLE IF EXISTS depenses CASCADE;
DROP TABLE IF EXISTS paiements CASCADE;
DROP TABLE IF EXISTS detail_ventes CASCADE;
DROP TABLE IF EXISTS ventes CASCADE;
DROP TABLE IF EXISTS caisses CASCADE;
DROP TABLE IF EXISTS detail_achats CASCADE;
DROP TABLE IF EXISTS achats CASCADE;
DROP TABLE IF EXISTS mouvements_stock CASCADE;
DROP TABLE IF EXISTS stocks CASCADE;
DROP TABLE IF EXISTS produits CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS fournisseurs CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS utilisateurs CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- ============================================================================
-- 2. VAGUE 1 : TABLES SANS DÉPENDANCE
-- ============================================================================

-- Table : roles
CREATE TABLE roles (
    id_role         BIGSERIAL PRIMARY KEY,
    nom_role        VARCHAR(50)     NOT NULL UNIQUE,
    description     VARCHAR(255),
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- Table : categories
CREATE TABLE categories (
    id_categorie    BIGSERIAL PRIMARY KEY,
    nom             VARCHAR(100)    NOT NULL UNIQUE,
    description     VARCHAR(255),
    actif           BOOLEAN         NOT NULL DEFAULT TRUE
);

-- Table : fournisseurs
CREATE TABLE fournisseurs (
    id_fournisseur  BIGSERIAL PRIMARY KEY,
    raison_sociale  VARCHAR(150)    NOT NULL,
    telephone       VARCHAR(20),
    adresse         VARCHAR(255),
    email           VARCHAR(150),
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- Table : clients
CREATE TABLE clients (
    id_client       BIGSERIAL PRIMARY KEY,
    nom             VARCHAR(100)    NOT NULL,
    prenom          VARCHAR(100),
    telephone       VARCHAR(20)     UNIQUE,
    email           VARCHAR(150),
    adresse         VARCHAR(255),
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- ============================================================================
-- 3. VAGUE 2 : TABLES DÉPENDANTES DE LA VAGUE 1
-- ============================================================================

-- Table : utilisateurs (dépend de roles)
CREATE TABLE utilisateurs (
    id_utilisateur  BIGSERIAL PRIMARY KEY,
    nom             VARCHAR(100)    NOT NULL,
    prenom          VARCHAR(100)    NOT NULL,
    telephone       VARCHAR(20)     UNIQUE,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    nom_utilisateur VARCHAR(50)     NOT NULL UNIQUE,
    mot_de_passe    VARCHAR(255)    NOT NULL,
    photo           VARCHAR(255),
    statut          VARCHAR(20)     NOT NULL DEFAULT 'actif',
    date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now(),
    id_role         BIGINT          NOT NULL,
    CONSTRAINT chk_utilisateurs_statut
        CHECK (statut IN ('actif', 'inactif', 'suspendu')),
    CONSTRAINT fk_utilisateurs_role
        FOREIGN KEY (id_role) REFERENCES roles(id_role)
        ON DELETE RESTRICT
);

-- Table : produits (dépend de categories, fournisseurs)
CREATE TABLE produits (
    id_produit      BIGSERIAL PRIMARY KEY,
    code            VARCHAR(30)     NOT NULL UNIQUE,
    code_barres     VARCHAR(50)     UNIQUE,
    nom             VARCHAR(150)    NOT NULL,
    description     TEXT,
    prix_achat      NUMERIC(10,2)   NOT NULL,
    prix_vente      NUMERIC(10,2)   NOT NULL,
    contenance      VARCHAR(30),
    stock_minimum   INTEGER         NOT NULL DEFAULT 0,
    image           VARCHAR(255),
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    date_creation   TIMESTAMPTZ     NOT NULL DEFAULT now(),
    id_categorie    BIGINT          NOT NULL,
    id_fournisseur  BIGINT,
    CONSTRAINT chk_produits_prix_achat
        CHECK (prix_achat >= 0),
    CONSTRAINT chk_produits_prix_vente
        CHECK (prix_vente >= 0),
    CONSTRAINT chk_produits_stock_minimum
        CHECK (stock_minimum >= 0),
    CONSTRAINT fk_produits_categorie
        FOREIGN KEY (id_categorie) REFERENCES categories(id_categorie)
        ON DELETE RESTRICT,
    CONSTRAINT fk_produits_fournisseur
        FOREIGN KEY (id_fournisseur) REFERENCES fournisseurs(id_fournisseur)
        ON DELETE SET NULL
);

-- ============================================================================
-- 4. VAGUE 3 : TABLES DÉPENDANTES DES UTILISATEURS / PRODUITS
-- ============================================================================

-- Table : stocks (dépend de produits) - relation 1-1
CREATE TABLE stocks (
    id_stock            BIGSERIAL PRIMARY KEY,
    id_produit          BIGINT      NOT NULL UNIQUE,
    quantite_disponible INTEGER     NOT NULL DEFAULT 0,
    seuil_alerte        INTEGER     NOT NULL DEFAULT 0,
    date_maj            TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_stocks_quantite
        CHECK (quantite_disponible >= 0),
    CONSTRAINT chk_stocks_seuil
        CHECK (seuil_alerte >= 0),
    CONSTRAINT fk_stocks_produit
        FOREIGN KEY (id_produit) REFERENCES produits(id_produit)
        ON DELETE CASCADE
);

-- Table : caisses (dépend de utilisateurs)
CREATE TABLE caisses (
    id_caisse       BIGSERIAL PRIMARY KEY,
    date_ouverture  TIMESTAMPTZ     NOT NULL DEFAULT now(),
    date_fermeture  TIMESTAMPTZ,
    montant_initial NUMERIC(10,2)   NOT NULL,
    montant_final   NUMERIC(10,2),
    statut          VARCHAR(20)     NOT NULL DEFAULT 'ouverte',
    id_utilisateur  BIGINT          NOT NULL,
    CONSTRAINT chk_caisses_montant_initial
        CHECK (montant_initial >= 0),
    CONSTRAINT chk_caisses_montant_final
        CHECK (montant_final IS NULL OR montant_final >= 0),
    CONSTRAINT chk_caisses_dates
        CHECK (date_fermeture IS NULL OR date_fermeture >= date_ouverture),
    CONSTRAINT chk_caisses_statut
        CHECK (statut IN ('ouverte', 'fermee')),
    CONSTRAINT fk_caisses_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE RESTRICT
);

-- ============================================================================
-- 5. VAGUE 4 : FLUX D'ACHATS (APPROVISIONNEMENT)
-- ============================================================================

-- Table : achats (dépend de fournisseurs, utilisateurs)
CREATE TABLE achats (
    id_achat        BIGSERIAL PRIMARY KEY,
    date_achat      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    montant_total   NUMERIC(10,2)   NOT NULL DEFAULT 0,
    statut          VARCHAR(20)     NOT NULL DEFAULT 'valide',
    id_fournisseur  BIGINT          NOT NULL,
    id_utilisateur  BIGINT          NOT NULL,
    CONSTRAINT chk_achats_montant_total
        CHECK (montant_total >= 0),
    CONSTRAINT chk_achats_statut
        CHECK (statut IN ('en_attente', 'valide', 'annule')),
    CONSTRAINT fk_achats_fournisseur
        FOREIGN KEY (id_fournisseur) REFERENCES fournisseurs(id_fournisseur)
        ON DELETE RESTRICT,
    CONSTRAINT fk_achats_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE RESTRICT
);

-- Table : detail_achats (dépend de achats, produits)
CREATE TABLE detail_achats (
    id_detail       BIGSERIAL PRIMARY KEY,
    id_achat        BIGINT          NOT NULL,
    id_produit      BIGINT          NOT NULL,
    quantite        INTEGER         NOT NULL,
    prix_unitaire   NUMERIC(10,2)   NOT NULL,
    sous_total      NUMERIC(10,2)   GENERATED ALWAYS AS (quantite * prix_unitaire) STORED,
    CONSTRAINT chk_detail_achats_quantite
        CHECK (quantite > 0),
    CONSTRAINT chk_detail_achats_prix_unitaire
        CHECK (prix_unitaire >= 0),
    CONSTRAINT fk_detail_achats_achat
        FOREIGN KEY (id_achat) REFERENCES achats(id_achat)
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_achats_produit
        FOREIGN KEY (id_produit) REFERENCES produits(id_produit)
        ON DELETE RESTRICT
);

-- ============================================================================
-- 6. VAGUE 5 : FLUX DE VENTES
-- ============================================================================

-- Table : ventes (dépend de utilisateurs, clients, caisses)
CREATE TABLE ventes (
    id_vente        BIGSERIAL PRIMARY KEY,
    reference       VARCHAR(50)     NOT NULL UNIQUE,
    date_vente      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    montant_total   NUMERIC(10,2)   NOT NULL DEFAULT 0,
    remise          NUMERIC(10,2)   NOT NULL DEFAULT 0,
    statut          VARCHAR(20)     NOT NULL DEFAULT 'validee',
    id_utilisateur  BIGINT          NOT NULL,
    id_client       BIGINT,
    id_caisse       BIGINT          NOT NULL,
    CONSTRAINT chk_ventes_montant_total
        CHECK (montant_total >= 0),
    CONSTRAINT chk_ventes_remise
        CHECK (remise >= 0),
    CONSTRAINT chk_ventes_statut
        CHECK (statut IN ('en_attente', 'validee', 'annulee')),
    CONSTRAINT fk_ventes_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ventes_client
        FOREIGN KEY (id_client) REFERENCES clients(id_client)
        ON DELETE SET NULL,
    CONSTRAINT fk_ventes_caisse
        FOREIGN KEY (id_caisse) REFERENCES caisses(id_caisse)
        ON DELETE RESTRICT
);

-- Table : detail_ventes (dépend de ventes, produits)
CREATE TABLE detail_ventes (
    id_detail       BIGSERIAL PRIMARY KEY,
    id_vente        BIGINT          NOT NULL,
    id_produit      BIGINT          NOT NULL,
    quantite        INTEGER         NOT NULL,
    prix_unitaire   NUMERIC(10,2)   NOT NULL,
    sous_total      NUMERIC(10,2)   GENERATED ALWAYS AS (quantite * prix_unitaire) STORED,
    CONSTRAINT chk_detail_ventes_quantite
        CHECK (quantite > 0),
    CONSTRAINT chk_detail_ventes_prix_unitaire
        CHECK (prix_unitaire >= 0),
    CONSTRAINT fk_detail_ventes_vente
        FOREIGN KEY (id_vente) REFERENCES ventes(id_vente)
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_ventes_produit
        FOREIGN KEY (id_produit) REFERENCES produits(id_produit)
        ON DELETE RESTRICT
);

-- Table : paiements (dépend de ventes)
CREATE TABLE paiements (
    id_paiement             BIGSERIAL PRIMARY KEY,
    id_vente                BIGINT          NOT NULL,
    mode_paiement           VARCHAR(20)     NOT NULL,
    montant                 NUMERIC(10,2)   NOT NULL,
    reference_transaction   VARCHAR(100),
    date_paiement           TIMESTAMPTZ     NOT NULL DEFAULT now(),
    CONSTRAINT chk_paiements_montant
        CHECK (montant >= 0),
    CONSTRAINT chk_paiements_mode
        CHECK (mode_paiement IN ('especes', 'mobile_money', 'carte_bancaire', 'mixte')),
    CONSTRAINT fk_paiements_vente
        FOREIGN KEY (id_vente) REFERENCES ventes(id_vente)
        ON DELETE CASCADE
);

-- ============================================================================
-- 7. VAGUE 6 : CLÔTURE DES FLUX (MOUVEMENTS, DÉPENSES, JOURNAL)
-- ============================================================================

-- Table : mouvements_stock (dépend de produits, utilisateurs)
CREATE TABLE mouvements_stock (
    id_mouvement        BIGSERIAL PRIMARY KEY,
    id_produit           BIGINT          NOT NULL,
    type_mouvement       VARCHAR(20)     NOT NULL,
    quantite             INTEGER         NOT NULL,
    date_mouvement       TIMESTAMPTZ     NOT NULL DEFAULT now(),
    id_utilisateur       BIGINT          NOT NULL,
    reference_operation  VARCHAR(50),
    CONSTRAINT chk_mouvements_type
        CHECK (type_mouvement IN ('entree', 'sortie', 'ajustement', 'vente', 'achat')),
    CONSTRAINT chk_mouvements_quantite
        CHECK (quantite <> 0),
    CONSTRAINT fk_mouvements_produit
        FOREIGN KEY (id_produit) REFERENCES produits(id_produit)
        ON DELETE RESTRICT,
    CONSTRAINT fk_mouvements_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE RESTRICT
);

-- Table : depenses (dépend de utilisateurs)
CREATE TABLE depenses (
    id_depense      BIGSERIAL PRIMARY KEY,
    libelle         VARCHAR(150)    NOT NULL,
    categorie       VARCHAR(50)     NOT NULL,
    montant         NUMERIC(10,2)   NOT NULL,
    date_depense    TIMESTAMPTZ     NOT NULL DEFAULT now(),
    id_utilisateur  BIGINT          NOT NULL,
    CONSTRAINT chk_depenses_montant
        CHECK (montant >= 0),
    CONSTRAINT fk_depenses_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE RESTRICT
);

-- Table : journal_activite (dépend de utilisateurs)
CREATE TABLE journal_activite (
    id_journal      BIGSERIAL PRIMARY KEY,
    id_utilisateur  BIGINT,
    action          VARCHAR(100)    NOT NULL,
    description     TEXT,
    date_action     TIMESTAMPTZ     NOT NULL DEFAULT now(),
    adresse_ip      VARCHAR(45),
    CONSTRAINT fk_journal_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE SET NULL
);

-- ============================================================================
-- 8. INDEX COMPLÉMENTAIRES (optimisation des jointures fréquentes)
-- ============================================================================
CREATE INDEX idx_utilisateurs_role ON utilisateurs(id_role);
CREATE INDEX idx_produits_categorie ON produits(id_categorie);
CREATE INDEX idx_produits_fournisseur ON produits(id_fournisseur);
CREATE INDEX idx_achats_fournisseur ON achats(id_fournisseur);
CREATE INDEX idx_achats_utilisateur ON achats(id_utilisateur);
CREATE INDEX idx_detail_achats_achat ON detail_achats(id_achat);
CREATE INDEX idx_detail_achats_produit ON detail_achats(id_produit);
CREATE INDEX idx_ventes_utilisateur ON ventes(id_utilisateur);
CREATE INDEX idx_ventes_client ON ventes(id_client);
CREATE INDEX idx_ventes_caisse ON ventes(id_caisse);
CREATE INDEX idx_detail_ventes_vente ON detail_ventes(id_vente);
CREATE INDEX idx_detail_ventes_produit ON detail_ventes(id_produit);
CREATE INDEX idx_paiements_vente ON paiements(id_vente);
CREATE INDEX idx_mouvements_produit ON mouvements_stock(id_produit);
CREATE INDEX idx_mouvements_utilisateur ON mouvements_stock(id_utilisateur);
CREATE INDEX idx_depenses_utilisateur ON depenses(id_utilisateur);
CREATE INDEX idx_journal_utilisateur ON journal_activite(id_utilisateur);