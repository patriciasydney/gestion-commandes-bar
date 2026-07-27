-- ============================================================================
-- django_utilisateurs_bridge.sql
-- Colonnes requises par Django (AbstractBaseUser + PermissionsMixin)
-- sur la table utilisateurs existante de schema.sql
-- À exécuter une seule fois sur test_dsi AVANT migrate users
-- ============================================================================

ALTER TABLE utilisateurs
    ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ NULL,
    ADD COLUMN IF NOT EXISTS is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Synchroniser is_active avec le statut métier existant
UPDATE utilisateurs SET is_active = (statut = 'actif');

-- L'administrateur doit avoir is_staff = TRUE (accès admin Django / futures vérifs de permission)
UPDATE utilisateurs SET is_staff = TRUE
    WHERE id_role = (SELECT id_role FROM roles WHERE nom_role = 'Administrateur');
