# Module Dashboard, Rapports & Notifications — Sindiely / Laetitia

> Intégré dans `POS_Backend/apps/dashboard`, `apps/reports`, `apps.notifications`.  
> Voir aussi [INTEGRATION_EQUIPE.md](./INTEGRATION_EQUIPE.md).

## Endpoints

| Route | Description |
|---|---|
| `GET /api/dashboard/summary/` | CA jour, tickets, dépenses, stocks faibles |
| `GET /api/reports/ventes/` | Rapport ventes (`date_debut`, `date_fin`) |
| `GET /api/reports/produits/` | Top 10 produits vendus |
| `GET /api/reports/depenses/` | Dépenses par catégorie |
| `GET /api/notifications/` | Alertes métier (`?lu=true\|false`) |
| `PATCH /api/notifications/<id>/lue/` | Marquer une alerte comme lue |
| `GET /api/docs/` | Documentation Swagger |

Permissions : JWT + `IsGerantOrComptable` (Michel).
