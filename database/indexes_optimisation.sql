-- ============================================================================
-- indexes_optimisation.sql
-- Application POS - Débits de Boissons
-- Phase 3 - Indexation et Optimisation PostgreSQL
-- À ajouter à la suite de schema.sql
-- ============================================================================

-- ============================================================================
-- 0. EXTENSION REQUISE POUR LA RECHERCHE TEXTUELLE APPROXIMATIVE (ILIKE / LIKE)
-- pg_trgm permet des index GIN/GIST efficaces sur les recherches partielles
-- (recherche produit par nom, code-barres, etc. avec ILIKE '%texte%')
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================================
-- 1. INDEX MANQUANT SUR CLÉ ÉTRANGÈRE (audit de complétude)
-- caisses.id_utilisateur n'était pas indexé dans schema.sql initial
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_caisses_utilisateur
    ON caisses(id_utilisateur);

-- ============================================================================
-- 2. INDEX DE RECHERCHE TEXTUELLE (module Produits, Fournisseurs, Clients)
-- Cas d'usage : barre de recherche rapide en caisse (§5.5, §5.9), recherche
-- fournisseur/client. Les index GIN trigram accélèrent ILIKE '%mot%'.
-- ============================================================================

-- Recherche rapide d'un produit par nom (autocomplétion, POS)
CREATE INDEX IF NOT EXISTS idx_produits_nom_trgm
    ON produits USING gin (nom gin_trgm_ops);

-- Recherche par code-barres (douchette/scan, correspondance exacte prioritaire
-- déjà couverte par la contrainte UNIQUE ; le trigram couvre la saisie partielle)
CREATE INDEX IF NOT EXISTS idx_produits_code_barres_trgm
    ON produits USING gin (code_barres gin_trgm_ops);

-- Recherche par code produit interne
CREATE INDEX IF NOT EXISTS idx_produits_code_trgm
    ON produits USING gin (code gin_trgm_ops);

-- Recherche d'un fournisseur par raison sociale
CREATE INDEX IF NOT EXISTS idx_fournisseurs_raison_sociale_trgm
    ON fournisseurs USING gin (raison_sociale gin_trgm_ops);

-- Recherche d'un client par nom (module clients §5.11)
CREATE INDEX IF NOT EXISTS idx_clients_nom_trgm
    ON clients USING gin (nom gin_trgm_ops);

-- Recherche d'un utilisateur (module admin, gestion des comptes §5.3)
CREATE INDEX IF NOT EXISTS idx_utilisateurs_nom_trgm
    ON utilisateurs USING gin (nom gin_trgm_ops);

-- ============================================================================
-- 3. INDEX SUR LES FILTRES TEMPORELS (tables de flux)
-- Cas d'usage : tableau de bord, rapports journaliers/mensuels/annuels (§5.13),
-- filtrage par plage de dates sur les tables à forte volumétrie.
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_ventes_date_vente
    ON ventes(date_vente);

CREATE INDEX IF NOT EXISTS idx_achats_date_achat
    ON achats(date_achat);

CREATE INDEX IF NOT EXISTS idx_depenses_date_depense
    ON depenses(date_depense);

CREATE INDEX IF NOT EXISTS idx_mouvements_date_mouvement
    ON mouvements_stock(date_mouvement);

CREATE INDEX IF NOT EXISTS idx_paiements_date_paiement
    ON paiements(date_paiement);

CREATE INDEX IF NOT EXISTS idx_journal_date_action
    ON journal_activite(date_action);

CREATE INDEX IF NOT EXISTS idx_caisses_date_ouverture
    ON caisses(date_ouverture);

-- ============================================================================
-- 4. INDEX COMPOSITES (requêtes combinées fréquentes du tableau de bord)
-- Cas d'usage : "ventes validées du jour", "dépenses par utilisateur sur une
-- période", rapports croisant statut + date en une seule condition WHERE.
-- ============================================================================

-- Chiffre d'affaires du jour / historique des ventes validées (§5.12, §5.13)
CREATE INDEX IF NOT EXISTS idx_ventes_statut_date
    ON ventes(statut, date_vente DESC);

-- Suivi des dépenses par utilisateur et par période (module comptable §4.1.6)
CREATE INDEX IF NOT EXISTS idx_depenses_utilisateur_date
    ON depenses(id_utilisateur, date_depense DESC);

-- Historique des mouvements par produit, du plus récent au plus ancien
CREATE INDEX IF NOT EXISTS idx_mouvements_produit_date
    ON mouvements_stock(id_produit, date_mouvement DESC);

-- ============================================================================
-- 5. INDEX PARTIELS (ciblent uniquement les lignes réellement interrogées
-- en permanence, réduisent la taille de l'index et accélèrent les alertes)
-- ============================================================================

-- Alerte de stock faible / rupture (§5.8, tableau de bord §5.14)
-- Cible uniquement les produits dont la quantité est sous le seuil d'alerte
CREATE INDEX IF NOT EXISTS idx_stocks_alerte
    ON stocks(id_produit)
    WHERE quantite_disponible <= seuil_alerte;

-- Recherche de la caisse actuellement ouverte par utilisateur (§5.18 :
-- une vente ne peut être créée que si une caisse est "ouverte")
CREATE INDEX IF NOT EXISTS idx_caisses_ouvertes
    ON caisses(id_utilisateur)
    WHERE statut = 'ouverte';

-- Ventes en attente de validation (paniers en cours, §5.9 "mise en attente")
CREATE INDEX IF NOT EXISTS idx_ventes_en_attente
    ON ventes(id_caisse)
    WHERE statut = 'en_attente';

-- Produits actifs uniquement (catalogue affiché en caisse, exclut les
-- produits désactivés du filtrage courant)
CREATE INDEX IF NOT EXISTS idx_produits_actifs
    ON produits(id_categorie)
    WHERE actif = TRUE;

-- ============================================================================
-- FIN DU SCRIPT D'INDEXATION
-- ============================================================================