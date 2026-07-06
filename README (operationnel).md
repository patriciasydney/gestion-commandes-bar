# Modules Backend — Sales / Purchases / Inventory / Payments / Expenses
Réalisé par Gildas & Paulo (équipe GSI) — Application POS pour Débits de Boissons

## Contenu

| App Django | Correspond à | Tables SQL couvertes |
|---|---|---|
| `ventes` | Sales (POS) | `ventes`, `detail_ventes`, `caisses` |
| `achats` | Purchases | `achats`, `detail_achats` |
| `stocks` | Inventory | `stocks`, `mouvements_stock` |
| `paiements` | Payments | `paiements` |
| `depenses` | Expenses | `depenses` |

## Installation dans le projet Django existant

1. Copier les 5 dossiers d'apps à la racine du projet (à côté de `manage.py`).

2. Installer la dépendance manquante :
   ```bash
   pip install django-filter --break-system-packages
   ```

3. Dans `settings.py` :
   ```python
   INSTALLED_APPS = [
       ...
       'django_filters',
       'ventes.apps.VentesConfig',
       'achats.apps.AchatsConfig',
       'stocks.apps.StocksConfig',
       'paiements.apps.PaiementsConfig',
       'depenses.apps.DepensesConfig',
   ]
   ```

4. Dans le `urls.py` principal du projet :
   ```python
   urlpatterns = [
       ...
       path('api/', include('ventes.urls')),
       path('api/', include('achats.urls')),
       path('api/', include('stocks.urls')),
       path('api/', include('paiements.urls')),
       path('api/', include('depenses.urls')),
   ]
   ```

5. **Aucune migration à lancer** pour ces 5 apps : tous les modèles sont en
   `managed = False` car le schéma est déjà créé par `database/schema.sql`
   (source de vérité gérée par Michel). Ne pas lancer `makemigrations` dessus.

## Décisions à faire valider par l'équipe

- **`Caisse`** est placée dans l'app `ventes` (pas de module dédié prévu dans
  la répartition des tâches) — à confirmer avec Verone.
- **`GeneratedField`** (colonnes `sous_total` de `detail_ventes` et
  `detail_achats`) nécessite **Django >= 5.0**. Si le projet est sur une
  version antérieure, il faudra remplacer ce champ par une solution de repli
  (propriété Python + lecture via requête directe).
- **Authentification** : le champ `utilisateur` est actuellement un ID brut
  dans les serializers. À remplacer par `request.user` une fois le module
  JWT de Michel/Yohan intégré.
- **Règles d'annulation** (vente déjà validée, achat déjà consommé) : les
  refus mis en place sont des hypothèses raisonnables, pas des règles de
  gestion officiellement validées — à trancher en équipe.
- Les imports `produits.Produit`, `fournisseurs.Fournisseur`,
  `clients.Client`, `utilisateurs.Utilisateur` supposent que ce sont les
  noms d'apps réels utilisés par Michel/Yohan/Patricia. À corriger si les
  noms diffèrent.

## Endpoints principaux

| Méthode | URL | Description |
|---|---|---|
| `POST` | `/api/ventes/` | Créer une vente complète (panier), décrémente le stock automatiquement |
| `POST` | `/api/ventes/{id}/annuler/` | Annule une vente en attente, restitue le stock |
| `POST` | `/api/caisses/` | Ouvrir une caisse |
| `POST` | `/api/caisses/{id}/fermer/` | Fermer une caisse |
| `POST` | `/api/achats/` | Enregistrer une réception de livraison, incrémente le stock |
| `POST` | `/api/achats/{id}/annuler/` | Annule un achat |
| `GET` | `/api/stocks/` | Liste des stocks |
| `GET` | `/api/stocks/alertes/` | Produits en stock faible / rupture |
| `POST` | `/api/stocks/{id}/ajuster/` | Ajustement manuel du stock (inventaire, casse...) |
| `GET` | `/api/mouvements-stock/` | Historique des mouvements (filtrable par produit/type) |
| `POST` | `/api/paiements/` | Encaisser un paiement sur une vente |
| `GET`/`POST` | `/api/depenses/` | Gestion des dépenses |

Toutes les opérations qui touchent au stock (création de vente, réception
d'achat, ajustement, annulation) sont encapsulées dans `transaction.atomic()`
avec verrouillage `select_for_update()` sur la ligne de stock concernée, pour
éviter les écarts en cas d'opérations concurrentes (règle imposée par le
`.cursorrules` du projet).
