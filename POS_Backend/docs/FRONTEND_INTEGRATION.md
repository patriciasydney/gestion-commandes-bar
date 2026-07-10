# Intégration Flutter ↔ Django REST

**Front :** `POS_Frontend/` (Flutter, Provider, http)  
**Backend :** `POS_Backend/` (Django 5+, PostgreSQL, SimpleJWT)  
**Règle d'or :** le backend est la source de vérité — le front s'aligne sur les contrats DRF.

---

## Démarrage local

### Backend

```bash
cd POS_Backend
cp .env.example .env
pip install -r requirements/development.txt
python manage.py migrate
python manage.py ensure_dev_user   # admin / admin123
python manage.py runserver
```

API : `http://localhost:8000/api/`  
Swagger : `http://localhost:8000/api/docs/`

### Frontend

```bash
cd POS_Frontend
flutter pub get
flutter run -d chrome   # ou android / linux
```

Configuration : `lib/core/constants/api_constants.dart`

- `baseUrl = "http://localhost:8000/api"`
- `modeDemo = false` → appels HTTP réels (JWT requis)

---

## Authentification

| Étape | Détail |
|---|---|
| Login | `POST /api/auth/login/` body `{ "username", "password" }` |
| Réponse | `{ "access", "refresh", "utilisateur": { id, username, role, … } }` |
| Header | `Authorization: Bearer <access>` sur toutes les routes protégées |
| Persistance | `shared_preferences` (access, refresh, bloc utilisateur) |
| Singleton | `ApiService.instance` injecté via `Provider<ApiService>` |

Compte dev : `admin` / `admin123` (`python manage.py ensure_dev_user`).

---

## Endpoints utilisés par le front

| Module front | Endpoint | Notes |
|---|---|---|
| Auth | `POST /auth/login/` | SimpleJWT + bloc `utilisateur` |
| Catalogue | `GET/POST /produits/`, `/categories/`, `/clients/` | FK `categorie`, `fournisseur` |
| Stocks | `GET /stocks/`, `POST /stocks/{id}/ajuster/` | Mouvements en lecture seule |
| Achats | `POST /achats/` | `{ fournisseur, details[] }` — pas de dépense auto |
| Dépenses | `POST /depenses/` | Charges opérationnelles (électricité, etc.) |
| Caisse | `POST /caisses/`, `POST /caisses/{id}/fermer/` | Caisse ouverte requise avant vente |
| POS | `POST /ventes/` puis `POST /paiements/` | Vente nested `details[]` |
| Dashboard | `GET /dashboard/summary/` | CA jour, alertes stock |
| Rapports | `GET /reports/ventes/`, `/produits/`, `/depenses/`, `/achats/` | Query `date_debut`, `date_fin` (YYYY-MM-DD) |

---

## Flux POS (vente complète)

```
1. POST /api/caisses/           { "montant_initial": 0 }
2. POST /api/ventes/            { "reference", "remise", "caisse", "client"?, "details": [...] }
3. POST /api/paiements/         { "vente", "mode_paiement", "montant" }
```

Modes paiement : `especes`, `mobile_money`, `carte_bancaire`, `mixte`.

Erreurs courantes :
- Caisse fermée → ouvrir la caisse d'abord
- Stock insuffisant → message DRF avec quantité disponible

---

## Achats vs dépenses (rapports)

| Concept | Table | Écran | Rapport |
|---|---|---|---|
| **Achat fournisseur** | `achats` | Achats | `GET /reports/achats/` |
| **Dépense opérationnelle** | `depenses` | Dépenses | `GET /reports/depenses/` |

Un achat met à jour le stock mais **ne crée pas** de ligne dans `depenses`.  
Le bénéfice net affiché côté front : `CA − dépenses opérationnelles − achats fournisseurs`.

---

## Mapping JSON (écarts corrigés)

| Entité | Champs DRF (backend) |
|---|---|
| Utilisateur | `id`, `username`, `role` (nested) |
| Produit | `categorie`, `fournisseur`, `image` |
| Stock | `produit`, `en_alerte` |
| Vente | `utilisateur`, `client`, `caisse`, `details[]` |
| Paiement | `vente` (FK, plus `id_vente`) |
| Dashboard | `chiffre_affaires_jour`, `nombre_tickets_jour`, `produits_stock_faible` |
| Rapport achats | `total_achats`, `par_fournisseur[].fournisseur__raison_sociale` |

---

## CORS (Flutter Web)

Origines dev autorisées dans `config/settings/base.py` (regex `localhost:*`).

---

## Tests automatisés front

```bash
cd POS_Frontend
flutter test
```

Couverture : parsing JSON login + modèles (`test/`).

Checklist manuelle E2E : voir [E2E_CHECKLIST.md](./E2E_CHECKLIST.md).

---

## Structure monorepo

```
gestion-commandes-bar/
├── POS_Backend/          # Django API
├── POS_Frontend/         # Flutter (racine du projet front)
├── database/             # schema.sql, seed, indexes
└── plan de travail.md
```
