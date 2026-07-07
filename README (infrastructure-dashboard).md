# Infrastructure Django & Module Dashboard — Laetitia

## Ce que couvre ce module
1. Mise en place du projet Django connecté à la base PostgreSQL de Michel (`pos_db`)
2. Recréation des apps manquantes dont dépendent tous les modules (`roles`, `utilisateurs`, `categories`, `fournisseurs`, `clients`, `produits`)
3. Premier endpoint du tableau de bord (§5.14 du cahier des charges)

## Infrastructure

### Base de données
- PostgreSQL 15+, base `pos_db`
- Chargée avec `schema.sql` → `indexes_optimisation.sql` → `seed.sql` (fournis par Michel)
- Connexion configurée dans `pos_backend/settings.py` (`DATABASES`)

### Apps ajoutées (manquantes du dépôt, nécessaires pour que tout fonctionne)
| App | Rôle |
|---|---|
| `roles` | Rôle attribué à un utilisateur |
| `utilisateurs` | Comptes du personnel |
| `categories` | Familles de produits |
| `fournisseurs` | Partenaires livrant les produits |
| `clients` | Client optionnel rattaché à une vente |
| `produits` | Articles vendus |

Toutes en `managed = False` — ces tables existent déjà dans `pos_db` via le SQL de Michel ; Django les lit sans jamais les modifier.

## Module Dashboard

### GET /api/dashboard/summary/
Retourne un résumé du jour :
- `chiffre_affaires_jour` : somme des ventes validées du jour
- `nombre_tickets_jour` : nombre de ventes validées du jour
- `depenses_jour` : somme des dépenses du jour
- `produits_stock_faible` : liste des produits dont le stock est sous le seuil d'alerte

Dépend des modèles `ventes`, `stocks`, `depenses` (déjà livrés par l'équipe, `managed = False`).

## À venir
- Bénéfice estimé, meilleures ventes (voir plan d'action)
- Module Notifications (table propre, `managed = True`)
- Reports, tests, documentation API
