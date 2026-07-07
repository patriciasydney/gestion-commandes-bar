# Project DSI

## Objectif
Ce projet contient un backend Django connecté à une base PostgreSQL `test_dsi` pour une application POS de gestion de débit de boissons.

Ce `README.md` sert surtout à faciliter la relecture, l'organisation du code et le `git merge` en expliquant **uniquement les dossiers et fichiers utiles** du projet.

## Vue d'ensemble

```text
project-dsi/
├── manage.py
├── README.md
├── .gitignore
├── .cursorrules
├── dictionnaire_donnees.md
├── smartreport_backend/
├── USERS/
└── database/
```

## Racine du projet

### `manage.py`
Point d'entrée principal de Django.

Utilisé pour lancer les commandes comme :
- `python manage.py runserver`
- `python manage.py migrate`
- `python manage.py createsuperuser`

### `README.md`
Document de navigation du projet. Il explique le rôle des dossiers et fichiers importants pour que plusieurs personnes puissent travailler dessus plus facilement.

### `.gitignore`
Liste des fichiers et dossiers à ne pas versionner :
- environnement virtuel ;
- caches Python ;
- bases SQLite locales ;
- fichiers temporaires.

### `.cursorrules`
Règles locales utilisées pendant le travail dans l'IDE Cursor. Ce n'est pas le coeur fonctionnel du projet, mais le fichier reste utile pour garder les conventions de travail.

### `dictionnaire_donnees.md`
Documentation métier et structurelle de la base de données.

Ce fichier décrit :
- les tables ;
- les champs ;
- les contraintes ;
- les règles de gestion.

Il sert de référence fonctionnelle entre la base PostgreSQL et le backend Django.

## Dossier `smartreport_backend/`
Ce dossier contient la **configuration globale du projet Django**.

### `smartreport_backend/settings.py`
Fichier de configuration principal du backend.

Il contient notamment :
- les applications installées ;
- la connexion à PostgreSQL ;
- la configuration JWT ;
- le modèle utilisateur personnalisé ;
- les réglages Django généraux.

Points importants dans ce projet :
- la base utilisée est PostgreSQL ;
- l'app métier principale actuellement branchée est `USERS` ;
- l'authentification API utilise `SimpleJWT` ;
- le modèle utilisateur déclaré est `users.Utilisateur`.

### `smartreport_backend/urls.py`
Point d'entrée des routes du projet.

Ce fichier branche actuellement :
- l'interface d'administration Django sur `/admin/` ;
- les routes API de l'application `USERS` sur `/api/`.

### `smartreport_backend/asgi.py`
Point d'entrée ASGI du projet.

Utile si le projet est lancé avec un serveur asynchrone ou dans certains environnements de déploiement modernes.

### `smartreport_backend/wsgi.py`
Point d'entrée WSGI du projet.

Utile pour un déploiement Django classique.

### `smartreport_backend/__init__.py`
Fichier technique Python qui marque le dossier comme package.

## Dossier `USERS/`
Ce dossier contient l'**application Django utile et active** pour la gestion :
- des utilisateurs ;
- des rôles ;
- de l'authentification ;
- des endpoints API associés.

> C'est ce dossier qu'il faut considérer comme la vraie app en cours d'utilisation dans le projet.

### `USERS/models.py`
Déclare les modèles Django liés aux tables PostgreSQL existantes :
- `Role`
- `Utilisateur`

Ce fichier contient aussi :
- le manager personnalisé `UtilisateurManager` ;
- le mapping entre Django et les colonnes SQL réelles ;
- la logique de création d'utilisateur et de superutilisateur.

Particularité importante :
- les modèles sont branchés sur les tables déjà créées dans PostgreSQL ;
- ils servent de pont entre Django et `test_dsi`.

### `USERS/serializers.py`
Contient les sérialiseurs Django REST Framework :
- `RoleSerializer`
- `UtilisateurSerializer`
- `UtilisateurCreationSerializer`
- `CustomTokenObtainPairSerializer`

Rôle du fichier :
- transformer les objets Python en JSON ;
- valider les données reçues par l'API ;
- gérer la création d'utilisateurs ;
- enrichir le token JWT avec des informations utilisateur.

### `USERS/views.py`
Contient les vues API.

Principales vues présentes :
- `CustomTokenObtainPairView` : connexion JWT ;
- `UtilisateurViewSet` : CRUD des utilisateurs.

Ce fichier porte donc la logique d'accès HTTP aux utilisateurs.

### `USERS/urls.py`
Déclare les routes de l'application `USERS`.

Routes utiles actuellement :
- `POST /api/auth/login/`
- `POST /api/auth/refresh/`
- routes CRUD générées pour `/api/utilisateurs/`

### `USERS/permissions.py`
Contient les permissions personnalisées basées sur les rôles.

Ce fichier centralise la logique RBAC :
- administrateur ;
- gérant ;
- caissier ;
- magasinier ;
- serveur ;
- comptable.

Même si toutes ces permissions ne sont pas encore branchées partout, ce fichier est utile car il prépare la sécurité métier du backend.

### `USERS/apps.py`
Déclaration de l'application Django `USERS`.

Ce fichier permet à Django de reconnaître correctement l'application dans le projet.

### `USERS/admin.py`
Point de personnalisation de l'administration Django pour l'application `USERS`.

Même s'il est léger actuellement, il reste utile pour faire évoluer l'affichage des modèles dans l'admin.

### `USERS/tests.py`
Fichier réservé aux tests automatisés de l'application `USERS`.

Il est utile structurellement, même s'il n'est pas encore rempli.

### `USERS/migrations/`
Contient les migrations Django de l'application `USERS`.

#### `USERS/migrations/0001_initial.py`
Première migration connue de l'application.

Elle permet à Django de suivre l'état du modèle côté framework, même lorsque la base est déjà partiellement préparée par les scripts SQL.

#### `USERS/migrations/__init__.py`
Fichier technique Python nécessaire au package de migrations.

### `USERS/__init__.py`
Fichier technique Python qui marque le dossier comme package.

## Dossier `database/`
Ce dossier contient tous les scripts SQL utiles au projet.

### `database/schema.sql`
Script principal de création de la base métier.

Il crée les tables principales du POS, par exemple :
- `roles`
- `utilisateurs`
- `categories`
- `fournisseurs`
- `clients`
- `produits`
- `stocks`
- `caisses`
- `ventes`
- `paiements`
- `depenses`
- `journal_activite`

Ce fichier est la base structurelle du projet côté PostgreSQL.

### `database/indexes_optimisation.sql`
Script d'optimisation PostgreSQL.

Il ajoute les index utiles pour améliorer :
- les recherches ;
- les filtres temporels ;
- les performances des requêtes fréquentes ;
- certains cas métier comme les alertes stock ou les ventes en attente.

### `database/seed.sql`
Script de données de démonstration.

Il insère des enregistrements de base pour tester plus vite le projet :
- rôles ;
- utilisateurs ;
- données métiers liées au POS.

### `database/django_utilisateurs_bridge.sql`
Script de compatibilité entre le schéma SQL existant et Django.

Son rôle est d'ajouter les colonnes nécessaires au bon fonctionnement de l'authentification Django sur la table `utilisateurs`, par exemple :
- `last_login`
- `is_superuser`
- `is_staff`
- `is_active`

Ce fichier est important car il relie le modèle utilisateur Django à la structure PostgreSQL existante.

### `database/indexes_optimisation.md`
Documentation détaillée sur les index PostgreSQL du projet.

Ce fichier explique :
- pourquoi les index existent ;
- à quoi ils servent ;
- comment ils améliorent les performances ;
- quels problèmes de permissions et de configuration PostgreSQL ont été rencontrés.

## Ordre logique de lecture pour un nouveau développeur
Pour comprendre rapidement le projet, lire dans cet ordre :

1. `README.md`
2. `dictionnaire_donnees.md`
3. `database/schema.sql`
4. `database/seed.sql`
5. `smartreport_backend/settings.py`
6. `smartreport_backend/urls.py`
7. `USERS/models.py`
8. `USERS/serializers.py`
9. `USERS/views.py`
10. `USERS/urls.py`
11. `USERS/permissions.py`

## Flux technique simplifié

```text
Client HTTP
   ↓
smartreport_backend/urls.py
   ↓
USERS/urls.py
   ↓
USERS/views.py
   ↓
USERS/serializers.py
   ↓
USERS/models.py
   ↓
Base PostgreSQL test_dsi
   ↑
database/schema.sql / seed.sql / django_utilisateurs_bridge.sql
```

## Fichiers réellement importants pour le merge
Si votre chef de projet veut aller à l'essentiel, les fichiers les plus importants à comparer pendant le merge sont :

- `smartreport_backend/settings.py`
- `smartreport_backend/urls.py`
- `USERS/models.py`
- `USERS/serializers.py`
- `USERS/views.py`
- `USERS/urls.py`
- `USERS/permissions.py`
- `database/schema.sql`
- `database/seed.sql`
- `database/indexes_optimisation.sql`
- `database/django_utilisateurs_bridge.sql`
- `dictionnaire_donnees.md`

## Commandes utiles

### Lancer le projet
```bash
source venv/bin/activate
python manage.py runserver
```

### Appliquer les migrations Django
```bash
python manage.py migrate
```

### Tester l'authentification JWT
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"mich","password":"votre_mot_de_passe"}'
```

## Résumé
Le projet repose sur trois blocs utiles :

- `smartreport_backend/` : configuration Django ;
- `USERS/` : logique applicative utilisateur et API ;
- `database/` : structure et alimentation PostgreSQL.

Le reste sert surtout à la documentation, à l'exécution locale ou au support de développement.
