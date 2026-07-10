# Checklist tests E2E — POS Débits de Boissons

**Prérequis :** PostgreSQL + backend `:8000` + front Flutter + compte `admin` / `admin123`

---

## 1. Auth

- [ ] `python manage.py ensure_dev_user` exécuté
- [ ] Login écran → redirection dashboard
- [ ] Fermer / rouvrir l'app → session restaurée (JWT)
- [ ] `GET /api/produits/` avec token → 200

---

## 2. Catalogue

- [ ] Liste produits depuis PostgreSQL (écran Produits)
- [ ] CRUD client fonctionnel
- [ ] Ajustement stock : `POST /stocks/{id}/ajuster/` (quantité signée)

---

## 3. Flux POS

- [ ] Ouvrir caisse (`POST /caisses/`)
- [ ] Ajouter 2 produits au panier
- [ ] Encaisser (mode `especes`)
- [ ] Stock décrémenté en BDD
- [ ] Vente visible dans `GET /api/ventes/`
- [ ] Paiement enregistré dans `GET /api/paiements/`

---

## 4. Achats & dépenses

- [ ] Créer un achat fournisseur → stock augmenté
- [ ] Rapport **Jour** → section **Achats fournisseurs** non vide
- [ ] Créer une dépense (écran Dépenses)
- [ ] Rapport **Jour** → section **Dépenses opérationnelles** non vide

---

## 5. Dashboard & rapports

- [ ] Dashboard : CA du jour = données réelles (`/dashboard/summary/`)
- [ ] Alertes stock affichées si produits sous seuil
- [ ] Rapport **Mois** : CA, top produits, achats, dépenses
- [ ] Export CSV (presse-papiers) sans erreur

---

## 6. Qualité

- [ ] `flutter analyze` → 0 erreur
- [ ] `flutter test` → tous les tests passent
- [ ] `python manage.py check` → OK

---

## Commandes rapides de vérification API

```bash
# Login
curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Dashboard (remplacer TOKEN)
curl -s http://localhost:8000/api/dashboard/summary/ -H "Authorization: Bearer TOKEN"

# Rapport ventes du mois
curl -s "http://localhost:8000/api/reports/ventes/?date_debut=2026-07-01&date_fin=2026-07-31" \
  -H "Authorization: Bearer TOKEN"
```
