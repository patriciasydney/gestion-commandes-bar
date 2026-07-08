# 4. Architecture du Backend Django

## 4.1 Présentation

Le backend de l'application est développé avec **Django** et **Django REST Framework (DRF)**. Il constitue le cœur du système et assure l'ensemble des traitements métier, la gestion des données, la sécurisation des accès ainsi que la communication avec la base de données PostgreSQL.

L'architecture du backend est conçue selon une approche **modulaire**, où chaque domaine fonctionnel est isolé dans une application Django indépendante. Cette organisation améliore la lisibilité du code, facilite le développement collaboratif et simplifie la maintenance de l'application.

---

# 4.2 Technologies utilisées

Le backend repose sur les technologies suivantes :

| Technologie           | Rôle                              |
| --------------------- | --------------------------------- |
| Django                | Framework backend principal       |
| Django REST Framework | Développement des API REST        |
| PostgreSQL            | Base de données relationnelle     |
| JWT                   | Authentification sécurisée        |
| Python                | Langage de programmation          |
| Docker                | Conteneurisation de l'application |
| Git & GitHub          | Gestion des versions              |

---

# 4.3 Structure générale du projet

Le projet backend est organisé selon une architecture modulaire.

```text
backend/
└── pos_backend/
    │
    ├── config/
    ├── apps/
    ├── common/
    ├── media/
    ├── static/
    ├── requirements/
    ├── docs/
    ├── tests/
    ├── manage.py
    ├── .env
    ├── docker-compose.yml
    └── README.md
```

Chaque dossier possède une responsabilité bien définie afin de garantir une organisation claire et évolutive du projet.

---

# 4.4 Description des principaux dossiers

| Dossier         | Description                                                                                      |
| --------------- | ------------------------------------------------------------------------------------------------ |
| `config/`       | Configuration générale du projet Django.                                                         |
| `apps/`         | Ensemble des applications métier.                                                                |
| `common/`       | Composants partagés (permissions, exceptions, middleware, utilitaires, validateurs, pagination). |
| `media/`        | Stockage des fichiers téléversés par les utilisateurs.                                           |
| `static/`       | Ressources statiques (CSS, JavaScript, images).                                                  |
| `requirements/` | Dépendances Python du projet.                                                                    |
| `docs/`         | Documentation spécifique au backend.                                                             |
| `tests/`        | Tests globaux du backend.                                                                        |

---

# 4.5 Organisation des applications Django

Le backend est composé des applications suivantes :

```text
apps/
│
├── authentication/
├── users/
├── customers/
├── services/
├── orders/
├── payments/
├── cash_register/
├── dashboard/
├── reports/
└── notifications/
```

Chaque application correspond à un domaine métier précis.

---

# 4.6 Responsabilités des applications

### Authentication

Gestion de l'authentification, de la connexion, du rafraîchissement des jetons JWT et de la déconnexion.

### Users

Gestion des comptes utilisateurs, des rôles, des permissions et des profils.

### Customers

Gestion des informations des clients.

### Services

Gestion des prestations proposées par le cybercafé.

### Orders

Gestion des commandes et des détails des commandes.

### Payments

Gestion des paiements associés aux commandes.

### Cash Register

Gestion des caisses, des ouvertures et fermetures de session ainsi que des mouvements de caisse.

### Dashboard

Calcul des indicateurs et statistiques affichés sur le tableau de bord.

### Reports

Génération des rapports de ventes, de commandes, de paiements et de caisse.

### Notifications

Gestion des notifications destinées aux utilisateurs.

---

# 4.7 Architecture interne d'une application

Toutes les applications Django suivent la même organisation afin de garantir une cohérence dans le projet.

```text
application/
│
├── migrations/
│
├── models/
│   ├── __init__.py
│
├── serializers/
│
├── services/
│
├── views/
│
├── permissions/
│
├── urls.py
├── admin.py
├── apps.py
├── tests.py
└── __init__.py
```

Cette structure permet de séparer les différentes responsabilités de chaque module.

---

# 4.8 Communication interne

Le fonctionnement interne du backend suit les étapes suivantes :

1. Le frontend envoie une requête HTTP.
2. L'URL est résolue par Django.
3. La vue reçoit la requête.
4. Les permissions sont vérifiées.
5. Les services exécutent la logique métier.
6. Les modèles interagissent avec PostgreSQL via l'ORM Django.
7. Les serializers convertissent les données en JSON.
8. Une réponse est renvoyée au frontend.

---

# 4.9 Sécurité

Le backend intègre plusieurs mécanismes de sécurité :

* authentification JWT ;
* gestion des rôles et permissions ;
* validation des données ;
* protection contre les injections SQL grâce à l'ORM Django ;
* gestion centralisée des exceptions ;
* journalisation des opérations sensibles.

---

# 4.10 Communication avec la base de données

Le backend utilise l'ORM de Django pour accéder à PostgreSQL. Cette approche permet de manipuler les données sous forme d'objets Python tout en limitant l'écriture de requêtes SQL.

L'ORM facilite également les migrations, la maintenance et l'évolution du schéma de la base de données.

---

# 4.11 Évolutivité

L'architecture modulaire retenue permet d'ajouter facilement de nouvelles applications ou fonctionnalités sans modifier les modules existants.

Cette organisation favorise également le développement parallèle des différents membres de l'équipe.

---

# 4.12 Schéma de l'architecture du backend

```text
                 Frontend Flutter
                        │
                Requêtes HTTP/JSON
                        │
                        ▼
                Django REST Framework
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
      Views         Services      Permissions
        │               │
        └───────┬───────┘
                ▼
             Models
                │
                ▼
          PostgreSQL
```

---

# 4.13 Conclusion

L'architecture du backend Django repose sur une organisation modulaire, sécurisée et évolutive. Elle facilite la répartition des tâches entre les développeurs, améliore la maintenabilité du code et garantit une intégration efficace avec le frontend Flutter grâce aux API REST développées avec Django REST Framework.
