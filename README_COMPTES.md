# Comptes & rôles — POS Débits de Boissons

Fichier de référence pour la connexion en environnement de développement.

> **Attention :** ces identifiants sont destinés au **local / tests uniquement**. Ne pas les utiliser en production.

## Tableau des comptes

| Identifiant     | Mot de passe    | Rôle              |
|-----------------|-----------------|-------------------|
| `admin`         | `admin123`      | Administrateur    |
| `gerant1`       | `gerant123`     | Gérant            |
| `caissier1`     | `caissier123`   | Caissier          |
| `magasinier1`   | `magasin123`    | Magasinier        |
| `serveur1`      | `serveur123`    | Serveur           |
| `comptable1`    | `compta123`     | Comptable         |

## Rôles et responsabilités

| Rôle | Objectif | Droits principaux |
|------|--------|-------------------|
| **Administrateur** | Configurer et sécuriser le système | Utilisateurs, rôles, paramètres, sauvegardes, accès total |
| **Gérant** | Piloter l’activité commerciale | Produits, fournisseurs, stocks, rapports ; **pas** d’ouverture/fermeture de caisse |
| **Caissier** | Point de vente quotidien | Ouvrir/fermer caisse, ventes, paiements, reçus |
| **Magasinier** | Gestion physique des stocks | Entrées/sorties, inventaires, achats, alertes stock |
| **Serveur** | Prise de commandes | POS / commandes (sans clôture de caisse) |
| **Comptable** | Suivi financier | Dépenses, rapports, consultation |

## Réinitialiser les mots de passe

```bash
cd POS_Backend
source ../.venv/bin/activate   # ou : source .venv/bin/activate depuis la racine
python manage.py seed_dev_users
```

Cette commande recrée / met à jour les 6 rôles et applique les mots de passe ci-dessus.

## Connexion

- **Frontend :** http://127.0.0.1:8080  
- **API / Swagger :** http://127.0.0.1:8000/api/docs/  
- Login API : `POST /api/auth/login/` avec `{ "username", "password" }`
