# Dictionnaire de Données — Application POS Débits de Boissons

**Projet :** Application de gestion de Point de Vente (POS) pour débits de boissons
**SGBD cible :** PostgreSQL 15+
**Responsable Mission 1 :** Michel — Modélisation, Conception et Déploiement de la base de données
**Phase :** 1 — Dictionnaire de données

---

## Conventions générales

| Règle | Détail |
|---|---|
| Nommage | snake_case, en français (`id_produit`, `prix_vente`...) |
| Clés primaires | `BIGSERIAL` |
| Montants / prix / coûts | `NUMERIC(10,2)` exclusivement — jamais `FLOAT`/`REAL` |
| Dates / horodatage | `TIMESTAMPTZ` |
| Statuts / indicateurs | `BOOLEAN` |
| Suppression logique par défaut | `ON DELETE RESTRICT` sur les tables de référence, `ON DELETE CASCADE` sur les tables de détail |

> **Note de conception :** la table `clients` a été ajoutée au dictionnaire bien qu'elle ne soit pas listée explicitement dans la demande initiale, car la table `ventes` référence obligatoirement un `id_client` (cahier des charges §9.6 et module §5.11 "Gestion des clients"). Son absence créerait une clé étrangère orpheline.

---

## 1. `roles`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_role | BIGSERIAL | PK | Identifiant unique du rôle |
| nom_role | VARCHAR(50) | NOT NULL, UNIQUE | Ex : Administrateur, Gérant, Caissier, Magasinier, Serveur, Comptable |
| description | VARCHAR(255) | — | Description des responsabilités du rôle |
| actif | BOOLEAN | NOT NULL, DEFAULT TRUE | Permet de désactiver un rôle sans le supprimer (préserve l'historique) |
| date_creation | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage de création |

## 2. `utilisateurs`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_utilisateur | BIGSERIAL | PK | Identifiant unique |
| nom | VARCHAR(100) | NOT NULL | Nom de famille |
| prenom | VARCHAR(100) | NOT NULL | Prénom |
| telephone | VARCHAR(20) | UNIQUE | Numéro de contact |
| email | VARCHAR(150) | NOT NULL, UNIQUE | Identifiant de récupération de compte |
| nom_utilisateur | VARCHAR(50) | NOT NULL, UNIQUE | Login de connexion |
| mot_de_passe | VARCHAR(255) | NOT NULL | Hash du mot de passe (jamais en clair — bcrypt/argon2) |
| photo | VARCHAR(255) | — | Chemin/URL de la photo (optionnelle) |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'actif', CHECK (statut IN ('actif','inactif','suspendu')) | Un utilisateur "inactif" ne peut plus se connecter |
| date_creation | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage de création du compte |
| id_role | BIGINT | NOT NULL, **FK → roles(id_role)** ON DELETE RESTRICT | Un utilisateur possède un seul rôle ; RESTRICT empêche de supprimer un rôle encore attribué |

## 3. `categories`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_categorie | BIGSERIAL | PK | Identifiant unique |
| nom | VARCHAR(100) | NOT NULL, UNIQUE | Ex : Bières, Vins, Whiskies, Jus, Snacks |
| description | VARCHAR(255) | — | Description libre |
| actif | BOOLEAN | NOT NULL, DEFAULT TRUE | Activer/désactiver une catégorie sans supprimer les produits liés |

## 4. `fournisseurs`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_fournisseur | BIGSERIAL | PK | Identifiant unique |
| raison_sociale | VARCHAR(150) | NOT NULL | Nom commercial du fournisseur |
| telephone | VARCHAR(20) | — | Contact téléphonique |
| adresse | VARCHAR(255) | — | Adresse physique |
| email | VARCHAR(150) | — | Contact email |
| actif | BOOLEAN | NOT NULL, DEFAULT TRUE | Fournisseur toujours actif ou archivé |
| date_creation | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage de création |

## 5. `clients`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_client | BIGSERIAL | PK | Identifiant unique |
| nom | VARCHAR(100) | NOT NULL | Nom du client |
| prenom | VARCHAR(100) | — | Prénom du client |
| telephone | VARCHAR(20) | UNIQUE | Contact (souvent utilisé comme identifiant client) |
| email | VARCHAR(150) | — | Contact email (optionnel) |
| adresse | VARCHAR(255) | — | Adresse (optionnelle) |
| actif | BOOLEAN | NOT NULL, DEFAULT TRUE | Statut du compte client |
| date_creation | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Date d'enregistrement |

## 6. `produits`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_produit | BIGSERIAL | PK | Identifiant unique |
| code | VARCHAR(30) | NOT NULL, UNIQUE | Référence interne du produit |
| code_barres | VARCHAR(50) | UNIQUE | Pour lecteur de codes-barres/douchette |
| nom | VARCHAR(150) | NOT NULL | Nom commercial du produit |
| description | TEXT | — | Description libre |
| prix_achat | NUMERIC(10,2) | NOT NULL, CHECK (prix_achat >= 0) | Coût d'acquisition |
| prix_vente | NUMERIC(10,2) | NOT NULL, CHECK (prix_vente >= 0) | Prix facturé au client (normalement ≥ prix_achat, contrôlé côté applicatif pour autoriser les promotions) |
| contenance | VARCHAR(30) | — | Ex : "33cl", "75cl" |
| stock_minimum | INTEGER | NOT NULL, DEFAULT 0, CHECK (stock_minimum >= 0) | Seuil déclenchant une alerte de réapprovisionnement |
| image | VARCHAR(255) | — | Chemin/URL de la photo produit |
| actif | BOOLEAN | NOT NULL, DEFAULT TRUE | Produit désactivé = non vendable, mais historique conservé |
| id_categorie | BIGINT | NOT NULL, **FK → categories(id_categorie)** ON DELETE RESTRICT | Un produit appartient à une seule catégorie |
| id_fournisseur | BIGINT | **FK → fournisseurs(id_fournisseur)** ON DELETE SET NULL | Fournisseur principal (nullable si non renseigné) |
| date_creation | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage de création |

## 7. `stocks`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_stock | BIGSERIAL | PK | Identifiant unique |
| id_produit | BIGINT | NOT NULL, UNIQUE, **FK → produits(id_produit)** ON DELETE CASCADE | Relation 1-1 : chaque produit a exactement une fiche stock |
| quantite_disponible | INTEGER | NOT NULL, DEFAULT 0, CHECK (quantite_disponible >= 0) | Quantité en temps réel — jamais négative |
| seuil_alerte | INTEGER | NOT NULL, DEFAULT 0, CHECK (seuil_alerte >= 0) | Déclenche la notification de stock faible |
| date_maj | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Dernière mise à jour de la quantité |

## 8. `mouvements_stock`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_mouvement | BIGSERIAL | PK | Identifiant unique |
| id_produit | BIGINT | NOT NULL, **FK → produits(id_produit)** ON DELETE RESTRICT | Produit concerné par le mouvement |
| type_mouvement | VARCHAR(20) | NOT NULL, CHECK (type_mouvement IN ('entree','sortie','ajustement','vente','achat')) | Nature du mouvement |
| quantite | INTEGER | NOT NULL, CHECK (quantite <> 0) | Quantité déplacée (positive = entrée, négative = sortie, selon convention applicative) |
| date_mouvement | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage du mouvement |
| id_utilisateur | BIGINT | NOT NULL, **FK → utilisateurs(id_utilisateur)** ON DELETE RESTRICT | Utilisateur responsable du mouvement (traçabilité) |
| reference_operation | VARCHAR(50) | — | Référence libre vers la vente/l'achat à l'origine du mouvement |

## 9. `achats`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_achat | BIGSERIAL | PK | Identifiant unique |
| date_achat | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Date de l'approvisionnement |
| montant_total | NUMERIC(10,2) | NOT NULL, CHECK (montant_total >= 0) | Total de la commande (calculé à partir des détails) |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'valide', CHECK (statut IN ('en_attente','valide','annule')) | Un achat annulé ne doit pas impacter le stock |
| id_fournisseur | BIGINT | NOT NULL, **FK → fournisseurs(id_fournisseur)** ON DELETE RESTRICT | Fournisseur concerné |
| id_utilisateur | BIGINT | NOT NULL, **FK → utilisateurs(id_utilisateur)** ON DELETE RESTRICT | Utilisateur ayant enregistré l'achat |

## 10. `detail_achats`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_detail | BIGSERIAL | PK | Identifiant unique |
| id_achat | BIGINT | NOT NULL, **FK → achats(id_achat)** ON DELETE CASCADE | Suppression de l'achat = suppression de ses lignes |
| id_produit | BIGINT | NOT NULL, **FK → produits(id_produit)** ON DELETE RESTRICT | Produit livré |
| quantite | INTEGER | NOT NULL, CHECK (quantite > 0) | Quantité réceptionnée |
| prix_unitaire | NUMERIC(10,2) | NOT NULL, CHECK (prix_unitaire >= 0) | Prix d'achat unitaire au moment de la commande |
| sous_total | NUMERIC(10,2) | GENERATED ALWAYS AS (quantite * prix_unitaire) STORED | Calcul automatique, garantit la cohérence |

## 11. `caisses`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_caisse | BIGSERIAL | PK | Identifiant unique |
| date_ouverture | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Début de session |
| date_fermeture | TIMESTAMPTZ | CHECK (date_fermeture IS NULL OR date_fermeture >= date_ouverture) | NULL tant que la caisse est ouverte |
| montant_initial | NUMERIC(10,2) | NOT NULL, CHECK (montant_initial >= 0) | Fond de caisse au départ |
| montant_final | NUMERIC(10,2) | CHECK (montant_final >= 0) | Renseigné uniquement à la clôture |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'ouverte', CHECK (statut IN ('ouverte','fermee')) | Une vente ne peut être créée que si la caisse liée est "ouverte" |
| id_utilisateur | BIGINT | NOT NULL, **FK → utilisateurs(id_utilisateur)** ON DELETE RESTRICT | Caissier responsable de la session |

## 12. `ventes`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_vente | BIGSERIAL | PK | Identifiant unique |
| reference | VARCHAR(50) | NOT NULL, UNIQUE | Référence/ticket unique — chaque vente possède un identifiant unique |
| date_vente | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage de la transaction |
| montant_total | NUMERIC(10,2) | NOT NULL, CHECK (montant_total >= 0) | Total après remise, calculé à partir des détails |
| remise | NUMERIC(10,2) | NOT NULL, DEFAULT 0, CHECK (remise >= 0) | Remise autorisée uniquement selon permissions du rôle |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'validee', CHECK (statut IN ('en_attente','validee','annulee')) | Annulation possible uniquement selon permissions |
| id_utilisateur | BIGINT | NOT NULL, **FK → utilisateurs(id_utilisateur)** ON DELETE RESTRICT | Vendeur/caissier ayant réalisé la vente |
| id_client | BIGINT | **FK → clients(id_client)** ON DELETE SET NULL | Optionnel : une vente peut concerner un client anonyme |
| id_caisse | BIGINT | NOT NULL, **FK → caisses(id_caisse)** ON DELETE RESTRICT | Caisse sur laquelle la vente a été enregistrée |

## 13. `detail_ventes`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_detail | BIGSERIAL | PK | Identifiant unique |
| id_vente | BIGINT | NOT NULL, **FK → ventes(id_vente)** ON DELETE CASCADE | Suppression de la vente = suppression de ses lignes |
| id_produit | BIGINT | NOT NULL, **FK → produits(id_produit)** ON DELETE RESTRICT | Produit vendu |
| quantite | INTEGER | NOT NULL, CHECK (quantite > 0) | Quantité vendue |
| prix_unitaire | NUMERIC(10,2) | NOT NULL, CHECK (prix_unitaire >= 0) | Prix de vente historisé au moment de la transaction |
| sous_total | NUMERIC(10,2) | GENERATED ALWAYS AS (quantite * prix_unitaire) STORED | Calcul automatique |

## 14. `paiements`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_paiement | BIGSERIAL | PK | Identifiant unique |
| id_vente | BIGINT | NOT NULL, **FK → ventes(id_vente)** ON DELETE CASCADE | Une vente peut avoir plusieurs paiements (paiement mixte) |
| mode_paiement | VARCHAR(20) | NOT NULL, CHECK (mode_paiement IN ('especes','mobile_money','carte_bancaire','mixte')) | Moyens supportés |
| montant | NUMERIC(10,2) | NOT NULL, CHECK (montant >= 0) | Montant réglé pour cette ligne de paiement |
| reference_transaction | VARCHAR(100) | — | Référence Mobile Money/carte, si applicable |
| date_paiement | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage du règlement |

## 15. `depenses`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_depense | BIGSERIAL | PK | Identifiant unique |
| libelle | VARCHAR(150) | NOT NULL | Intitulé de la dépense |
| categorie | VARCHAR(50) | NOT NULL | Ex : eau, électricité, transport, salaire, entretien, fournitures |
| montant | NUMERIC(10,2) | NOT NULL, CHECK (montant >= 0) | Montant dépensé |
| date_depense | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Date de la dépense |
| id_utilisateur | BIGINT | NOT NULL, **FK → utilisateurs(id_utilisateur)** ON DELETE RESTRICT | Utilisateur ayant enregistré la dépense |

## 16. `journal_activite`

| Champ | Type PostgreSQL | Contraintes | Description & Règles de gestion |
|---|---|---|---|
| id_journal | BIGSERIAL | PK | Identifiant unique |
| id_utilisateur | BIGINT | **FK → utilisateurs(id_utilisateur)** ON DELETE SET NULL | Nullable : la traçabilité doit survivre même si le compte utilisateur est supprimé |
| action | VARCHAR(100) | NOT NULL | Ex : connexion, suppression, modification, annulation, sauvegarde |
| description | TEXT | — | Détail de l'action réalisée |
| date_action | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Horodatage précis de l'action |
| adresse_ip | VARCHAR(45) | — | Compatible IPv4/IPv6, utile pour la détection de connexions suspectes |

---

## Récapitulatif des clés étrangères entre blocs fonctionnels

```
roles          ← utilisateurs
categories     ← produits
fournisseurs   ← produits, achats
produits       ← stocks, mouvements_stock, detail_achats, detail_ventes
utilisateurs   ← mouvements_stock, achats, caisses, ventes, depenses, journal_activite
clients        ← ventes
achats         ← detail_achats
caisses        ← ventes
ventes         ← detail_ventes, paiements
```

## Ordre de création des tables (respect des dépendances FK)

1. **Sans dépendance** : `roles`, `categories`, `fournisseurs`, `clients`
2. **Dépendantes de la vague 1** : `utilisateurs` (roles), `produits` (categories, fournisseurs)
3. **Dépendantes des utilisateurs/produits** : `stocks` (produits), `caisses` (utilisateurs)
4. **Flux d'achats** : `achats` (fournisseurs, utilisateurs) → `detail_achats` (achats, produits)
5. **Flux de ventes** : `ventes` (utilisateurs, clients, caisses) → `detail_ventes` (ventes, produits) → `paiements` (ventes)
6. **Clôture des flux** : `mouvements_stock` (produits, utilisateurs), `depenses` (utilisateurs), `journal_activite` (utilisateurs)
