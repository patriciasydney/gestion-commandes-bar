# Démarrage local — Comptes de test

Monorepo POS Débits de Boissons (`POS_Backend` + `POS_Frontend`).

## Comptes disponibles

| Identifiant   | Mot de passe   | Rôle            | Accueil typique        |
|---------------|----------------|-----------------|------------------------|
| `admin`       | `admin123`     | Administrateur  | Tableau de bord       |
| `gerant1`     | `gerant123`    | Gérant          | Tableau de bord        |
| `caissier1`   | `caissier123`  | Caissier        | Point de vente         |
| `magasinier1` | `magasin123`   | Magasinier      | Stocks                 |
| `serveur1`    | `serveur123`   | Serveur         | Point de vente         |
| `comptable1`  | `compta123`    | Comptable       | Rapports               |

Recréer / réinitialiser les mots de passe :

```bash
cd POS_Backend
source ../.venv/bin/activate
python manage.py ensure_dev_user --username admin --password admin123
python manage.py seed_dev_users
```

## Lancer

```bash
# Backend
cd POS_Backend && source ../.venv/bin/activate
python manage.py runserver

# Frontend
cd POS_Frontend
flutter pub get
flutter run -d web-server --web-port=8080
# ou : flutter run -d chrome / linux
```

- API / Swagger : http://127.0.0.1:8000/api/docs/
- App : http://127.0.0.1:8080

## Build web sur le reseau local

Le frontend Flutter peut etre compile avec une URL d'API differente grace a
`--dart-define`.

```bash
# Backend accessible sur le reseau local
cd POS_Backend && source ../.venv/bin/activate
python manage.py runserver 0.0.0.0:8000

# Build web pointant vers le backend local
cd ../POS_Frontend
flutter build web --dart-define=API_BASE_URL=http://10.0.34.69:8000/api

# Partage simple du build sur le reseau
cd build/web
python3 -m http.server 8090 --bind 0.0.0.0
```

- Build web partage : `http://10.0.34.69:8090`
- API backend : `http://10.0.34.69:8000/api`
- Si le login echoue a distance, verifier `API_BASE_URL`, `DJANGO_ALLOWED_HOSTS`
  et `CORS_ALLOWED_ORIGINS`.

## Rôles (cahier des charges §4.1)

- **Administrateur** — utilisateurs, rôles, paramètres, sauvegardes, supervision totale
- **Gérant** — catalogue, stocks, fournisseurs, rapports ; pas d’ouverture/fermeture de caisse
- **Caissier** — ventes, paiements, ouverture/fermeture de caisse
- **Magasinier** — entrées/sorties stock, inventaires, achats
- **Serveur** — prise de commandes (POS), sans clôture de caisse
- **Comptable** — dépenses, rapports financiers, consultation
