-- Extension au schéma Michel — table notifications (module Sindiely / Laetitia)
-- À appliquer après schema.sql si la table n'existe pas encore.

CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    type VARCHAR(30) NOT NULL CHECK (type IN ('stock_faible', 'rupture', 'caisse_ouverte', 'commande_attente')),
    message VARCHAR(255) NOT NULL,
    date_notification TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    lu BOOLEAN NOT NULL DEFAULT FALSE,
    utilisateur_id BIGINT NULL REFERENCES utilisateurs(id_utilisateur) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_lu ON notifications (lu);
CREATE INDEX IF NOT EXISTS idx_notifications_date ON notifications (date_notification DESC);

-- Migration incremental (bases déjà créées) :
-- ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
-- ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
--   CHECK (type IN ('stock_faible', 'rupture', 'caisse_ouverte', 'commande_attente'));
