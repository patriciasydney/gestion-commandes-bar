-- Corrige les catégories de dépenses (anciens codes → libellés métier)
-- Usage : psql -d test_dsi -f database/fix_depenses_categories.sql

UPDATE depenses SET categorie = 'Charges fixes' WHERE lower(categorie) = 'electricite';
UPDATE depenses SET categorie = 'Charges fixes' WHERE lower(categorie) = 'eau';
UPDATE depenses SET categorie = 'Carburant'     WHERE lower(categorie) = 'transport';
