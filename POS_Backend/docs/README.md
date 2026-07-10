# POS Backend — Débits de Boissons

Backend Django REST unifié. **Source de vérité BDD :** `../database/schema.sql`

## Prérequis

- Python 3.11+
- **Django 5.0+** (obligatoire — `GeneratedField` sur `detail_ventes` / `detail_achats`)
- PostgreSQL 15+

## Installation rapide

```bash
# Depuis la racine du monorepo
pip install -r requirements.txt

# Ou depuis POS_Backend
cd POS_Backend
pip install -r requirements/development.txt
cp .env.example .env
```

## Base de données

```bash
psql -U michel -d test_dsi -f ../database/schema.sql
psql -U michel -d test_dsi -f ../database/django_utilisateurs_bridge.sql
psql -U michel -d test_dsi -f ../database/indexes_optimisation.sql
psql -U michel -d test_dsi -f ../database/seed.sql
psql -U michel -d test_dsi -f ../database/notifications.sql
```

## Lancer le serveur

```bash
# Depuis la racine
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver

# Ou depuis POS_Backend/
cd POS_Backend && python manage.py runserver
```

## Apps (alignées sur le schéma SQL)

| App Django | Tables PostgreSQL |
|---|---|
| `utilisateurs` | `roles`, `utilisateurs` |
| `categories` | `categories` |
| `fournisseurs` | `fournisseurs` |
| `clients` | `clients` |
| `produits` | `produits` |
| `stocks` | `stocks`, `mouvements_stock` |
| `ventes` | `ventes`, `detail_ventes`, `caisses` |
| `achats` | `achats`, `detail_achats` |
| `paiements` | `paiements` |
| `depenses` | `depenses` |
| `journal_activite` | `journal_activite` |
| `dashboard` | *(agrégations — pas de table)* |
| `reports` | *(agrégations — pas de table)* |
| `notifications` | `notifications` *(extension Sindiely)* |

Tous les modèles métier sont en `managed = False`, sauf `notifications`.

Voir aussi : [INTEGRATION_EQUIPE.md](./INTEGRATION_EQUIPE.md)

## API

| Endpoint | Module |
|---|---|
| `POST /api/auth/login/` | JWT |
| `/api/roles/`, `/api/utilisateurs/` | utilisateurs |
| `/api/categories/` | categories |
| `/api/produits/` | produits |
| `/api/fournisseurs/` | fournisseurs |
| `/api/clients/` | clients |
| `/api/ventes/`, `/api/caisses/` | ventes |
| `/api/achats/` | achats |
| `/api/stocks/`, `/api/mouvements-stock/` | stocks |
| `/api/paiements/` | paiements |
| `/api/depenses/` | depenses |
| `/api/journal-activite/` | journal_activite |
| `/api/dashboard/summary/` | dashboard (Sindiely) |
| `/api/reports/ventes/`, `/produits/`, `/depenses/`, `/achats/` | reports (Sindiely) |
| `/api/notifications/` | notifications (Sindiely) |
| `/api/docs/`, `/api/schema/` | Swagger OpenAPI |

## Intégration Flutter

- [FRONTEND_INTEGRATION.md](./FRONTEND_INTEGRATION.md) — contrats API, flux POS, mapping JSON
- [E2E_CHECKLIST.md](./E2E_CHECKLIST.md) — checklist manuelle login → vente → rapport
