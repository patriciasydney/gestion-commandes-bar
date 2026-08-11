# Intégration du travail équipe — POS Backend

Ce document décrit comment le code de chaque membre a été intégré dans `POS_Backend/`, sans supprimer la logique existante.

**Source de vérité BDD :** `database/schema.sql` (Michel).  
**Extension :** `database/notifications.sql` (Sindiely — table `notifications`).

---

## Cartographie branche → app Django

| Contributeur | Branche Git | Contenu d'origine | App(s) intégrée(s) |
|---|---|---|---|
| Michel / Yohan | `origin/michelyohan`, `main` | `smartreport_backend/`, `USERS/` — JWT, CRUD utilisateurs, RBAC | `apps.utilisateurs` |
| Gildas / Paul | `origin/gildas` | `ventes/`, `achats/`, `stocks/`, `paiements/`, `depenses/` | `apps.ventes`, `apps.achats`, `apps.stocks`, `apps.paiements`, `apps.depenses` |
| Patricia | `origin/patricia` | `products/`, `categories/`, `suppliers/`, `customers/` | `apps.produits`, `apps.categories`, `apps.fournisseurs`, `apps.clients` |
| Verone | `origin/verone` | `POS_Backend/config/apps/` (scaffold anglais vide) | **Non repris** — remplacé par apps françaises alignées SQL |
| Sindiely / Laetitia | `origin/Sindiely` | `dashboard/`, `reports/`, `notifications/`, `pos_backend/` (Swagger) | `apps.dashboard`, `apps.reports`, `apps.notifications` + `drf-spectacular` |

---

## Décisions d'intégration

1. **Un seul projet Django** : `POS_Backend/` avec `config/` (ex-`smartreport_backend`).
2. **Noms en français** : tables et apps alignées sur `schema.sql` (`utilisateurs`, `produits`, etc.).
3. **Modèles métier** : `managed = False` (tables créées par SQL). Exception : `notifications` (`managed = True`, migration Django).
4. **Auth JWT** : `AUTH_USER_MODEL = "utilisateurs.Utilisateur"`, SimpleJWT + blacklist (Michel).
5. **Permissions RBAC** : `apps/utilisateurs/permissions.py` — rôles depuis `database/seed.sql` (`Administrateur`, `Gérant`, `Caissier`, …).
6. **Imports Sindiely** : chemins adaptés (`apps.ventes.models` au lieu de `ventes.models`), auth + `IsGerantOrComptable` ajoutés sur dashboard/reports.

---

## Endpoints par module

### Michel — Auth & utilisateurs
- `POST /api/auth/login/` — JWT
- `POST /api/auth/refresh/`
- `/api/roles/`, `/api/utilisateurs/`

### Gildas / Paul — Opérations
- `/api/ventes/`, `/api/caisses/`
- `/api/achats/`
- `/api/stocks/`, `/api/mouvements-stock/`
- `/api/paiements/`
- `/api/depenses/`
- `/api/journal-activite/`

### Patricia — Catalogue
- `/api/categories/`
- `/api/produits/`
- `/api/fournisseurs/`
- `/api/clients/`

### Sindiely — Tableau de bord & alertes
- `GET /api/dashboard/summary/` — CA jour, tickets, dépenses, stocks faibles
- `GET /api/reports/ventes/?date_debut=&date_fin=`
- `GET /api/reports/produits/?date_debut=&date_fin=`
- `GET /api/reports/depenses/?date_debut=&date_fin=`
- `GET /api/notifications/?lu=true|false`
- `PATCH /api/notifications/<id>/lue/`
- `GET /api/docs/` — Swagger (drf-spectacular)
- `GET /api/schema/` — schéma OpenAPI

---

## Fichiers supprimés (doublons, récupérables via Git)

Les apps à la racine du repo (`ventes/`, `USERS/`, etc.) et le scaffold vide `POS_Backend/config/apps/` ont été retirés **après** migration de leur contenu dans `POS_Backend/apps/`.  
Pour consulter l'historique : `git show origin/<branche>:<chemin>`.

---

## Prochaines étapes (Phase 2)

- Appliquer les permissions Michel sur tous les ViewSets opérationnels
- Propager `request.user` dans les serializers (ventes, achats, journal)
- Tests d'intégration flux complet (vente + stock + paiement)
