# Plan de travail — Phase 3 : Intégration Front Flutter / Backend Django

**Projet :** POS Débits de Boissons (monorepo `gestion-commandes-bar`)  
**Front :** `POS_Frontend/` (Flutter, Provider, http)  
**Backend :** `POS_Backend/` (Django 5+ REST, PostgreSQL, JWT)  
**Date :** 9 juillet 2026

## Règle d'or — Backend prioritaire

> **Le backend est la source de vérité.** En cas d'écart entre front et API, on adapte le front (noms de champs, endpoints, payloads) pour coller au contrat DRF / `schema.sql`. On n'invente pas de variables côté Flutter si le backend expose déjà un nom différent.

---

## Verdict audit front

| Critère | État |
|---|---|
| Architecture (Provider + services + modèles) | ✅ Bonne |
| 14 écrans routés | ✅ Complet |
| `flutter analyze` | ✅ 0 erreur |
| Connexion API réelle | ❌ `modeDemo = true` |
| Auth JWT | ❌ Incompatible |
| Modèles JSON | ❌ Écarts multiples |
| Flux vente POS | ❌ Endpoint `/details-vente/` inexistant |

---

## Problèmes bloquants (résumé)

1. **`ApiConstants.modeDemo = true`** — toute l'app utilise `MockApi`.
2. **Auth** — front attend `token` + `utilisateur` ; backend renvoie `access` + `refresh`.
3. **Token non propagé** — 14 services instancient chacun leur propre `ApiService()` sans JWT partagé.
4. **Flux vente** — 3 POST séparés vs 1 POST `/ventes/` avec `details[]` côté backend.
5. **CORS** — backend limité à `localhost:3000` ; Flutter Web utilise un autre port.
6. **Endpoints** — `/dashboard/` vs `/dashboard/summary/`, `/rapports/` vs `/reports/`.

---

## Sprint 1 — Connexion & auth (2–3 jours)

**Objectif :** login réel + appels authentifiés.

| # | Tâche | Côté | Statut |
|---|---|---|---|
| 1.1 | Singleton `ApiService` injecté via Provider | Front | ✅ |
| 1.2 | Après login : `setToken(access)`, stocker `refresh` en local | Front | ✅ |
| 1.3 | Adapter `AuthProvider` : lire `access` / `refresh` | Front | ✅ |
| 1.4 | Enrichir `CustomTokenObtainPairSerializer` → bloc `utilisateur` | Backend | ✅ |
| 1.5 | Adapter `Utilisateur.fromJson` (`id`, `username`, `role`) | Front | ✅ |
| 1.6 | CORS : ajouter origines Flutter Web en dev | Backend | ✅ |
| 1.7 | Utilisateur test avec mot de passe valide | Ops | ✅ (`admin` / `admin123`) |

**Critères de validation Sprint 1 :**
- [ ] `modeDemo = false`
- [ ] Login avec compte réel → redirection dashboard
- [ ] `GET /api/produits/` avec Bearer token → liste parsée

---

## Sprint 2 — Alignement modèles catalogue (2 jours)

**Objectif :** écrans Produits, Catégories, Stocks, Clients fonctionnels.

| # | Tâche | Statut |
|---|---|---|
| 2.1 | `Produit` : `categorie`, `fournisseur`, `image` | Front | ✅ |
| 2.2 | `Stock` : FK `produit`, `en_alerte` | Front | ✅ |
| 2.3 | `MouvementStock` : FK `produit`, `utilisateur` | Front | ✅ |
| 2.4 | `POST /stocks/{id}/ajuster/` (quantité signée) | Front | ✅ |
| 2.5 | Achats : `fournisseur` + `details[]`, statuts backend | Front | ✅ |
| 2.6 | Paiement / Dépense : FK `vente`, `utilisateur` serveur | Front | ✅ |

**Critères de validation Sprint 2 :**
- [ ] Liste produits depuis PostgreSQL
- [ ] Ajustement stock depuis l'écran Stocks
- [ ] CRUD client fonctionnel

---

## Sprint 3 — Flux POS & caisse (3 jours)

**Objectif :** vente complète de bout en bout.

| # | Tâche | Statut |
|---|---|---|
| 3.1 | Écran / logique ouverture caisse (`POST /caisses/`) | Front | ✅ |
| 3.2 | Réécrire `creerVenteComplete()` → 1 POST avec `details[]` | Front | ✅ |
| 3.3 | Paiement séparé `POST /paiements/` | Front | ✅ |
| 3.4 | Retirer `DetailVenteService` du flux POS | Front | ✅ |
| 3.5 | Gestion erreurs API (stock / caisse fermée) | Front | ✅ |

**Critères de validation Sprint 3 :**
- [x] Ouvrir caisse → vendre 2 produits → payer → stock décrémenté *(E2E API 10/07/2026)*
- [x] Vente visible dans `GET /ventes/`

---

## Sprint 4 — Dashboard & rapports (2 jours)

| # | Tâche | Statut |
|---|---|---|
| 4.1 | `DashboardService` → `/dashboard/summary/` + mapping clés | Front | ✅ |
| 4.2 | Adapter UI dashboard (liste alertes stock) | Front | ✅ |
| 4.3 | `RapportService` → `/reports/ventes/` avec dates | Front | ✅ |
| 4.4 | *(Option)* enrichir dashboard backend (stats mois/semaine) | ☐ |

**Critères de validation Sprint 4 :**
- [x] Dashboard affiche le CA du jour réel *(E2E API : 133 500 FCFA)*
- [x] Rapport ventes sur une période *(E2E API mois : 161 750 FCFA / 8 ventes)*

---

## Sprint 5 — Qualité & intégration repo (1–2 jours)

| # | Tâche | Statut |
|---|---|---|
| 5.1 | Retirer `.git` nested ou submodule Git | Front | ✅ |
| 5.2 | Supprimer `POS_Frontend/cyber_managment/` | — | ✅ *(absent du repo)* |
| 5.3 | Doc `POS_Backend/docs/FRONTEND_INTEGRATION.md` | Docs | ✅ |
| 5.4 | Checklist tests E2E (login → vente → rapport) | Docs | ✅ |
| 5.5 | `flutter test` (login + parsing modèles) | Front | ✅ |

**Critères de validation Sprint 5 :**
- [x] Front intégré au monorepo (sans `.git` nested)
- [x] Documentation d'intégration + checklist E2E
- [x] `flutter test` vert

---

## Écarts modèles JSON (référence)

| Entité | Front (mock) | Backend DRF |
|---|---|---|
| Utilisateur | `id_utilisateur`, `nom_utilisateur`, `id_role` | `id`, `username`, `role` (nested) |
| Produit | `id_categorie`, `photo_base64` | `categorie`, `fournisseur`, `image` |
| Stock | `id_produit` | `produit` |
| Vente | `id_utilisateur`, `id_client`, `id_caisse` | `utilisateur`, `client`, `caisse` |
| Paiement | `id_vente` | `vente` |
| Mouvement stock | `id_produit`, `id_utilisateur` | `produit`, `utilisateur` |
| Achat statut | `recu` | `en_attente` / `valide` / `annule` |

---

## Endpoints (référence)

| Front actuel | Backend réel |
|---|---|
| `GET /dashboard/summary/` | `GET /dashboard/summary/` |
| `GET /reports/ventes/?date_debut=&date_fin=` | `GET /reports/ventes/?date_debut=&date_fin=` |
| `POST /details-vente/` | *(inexistant — nested dans POST /ventes/)* |
| `POST /mouvements-stock/` | `POST /stocks/{id}/ajuster/` (mouvements en lecture seule) |

---

## Décisions à valider

1. **Login** — enrichir réponse backend avec `utilisateur` *(retenu)* vs parser JWT côté Dart ?
2. **Dashboard** — enrichir backend (stats mois/semaine) vs simplifier UI front ?
3. **Repo** — intégrer front dans monorepo (supprimer `.git` nested) ou repo séparé ?

---

## Flux vente cible

```
Front POS                          Django API
    │                                    │
    │  POST /caisses/ (ouverture)        │
    │ ─────────────────────────────────► │
    │                                    │
    │  POST /ventes/ {details[], caisse} │
    │ ─────────────────────────────────► │ → transaction stock + mouvements
    │                                    │
    │  POST /paiements/ {vente, montant} │
    │ ─────────────────────────────────► │ → valide vente si payé
```
