# 5. Architecture du Frontend Flutter

## 5.1 Présentation

Le frontend de l'application est développé avec **Flutter**, un framework open source de Google permettant de créer des applications multiplateformes performantes à partir d'une base de code unique. Cette technologie offre une interface utilisateur moderne, réactive et compatible avec Android, iOS, Windows, Linux et le Web.

Dans le cadre de ce projet, Flutter est utilisé pour développer l'interface utilisateur de l'application de gestion des commandes du cybercafé. Il communique avec le backend Django REST Framework à travers des API REST sécurisées utilisant le format JSON.

L'architecture retenue est modulaire afin de faciliter le développement collaboratif, la maintenance et l'évolution future de l'application.

---

# 5.2 Objectifs de l'architecture

L'architecture du frontend vise à :

* offrir une interface utilisateur simple et intuitive ;
* garantir une navigation fluide entre les écrans ;
* faciliter la communication avec le backend ;
* favoriser la réutilisation des composants graphiques ;
* simplifier les tests et la maintenance du code.

---

# 5.3 Structure générale du projet

Le projet Flutter est organisé de manière à séparer les ressources, les fonctionnalités et les composants réutilisables.

```text
frontend/
│
└── pos_frontend/
    │
    ├── android/
    ├── ios/
    ├── linux/
    ├── windows/
    ├── web/
    │
    ├── assets/
    │   ├── images/
    │   ├── icons/
    │   ├── fonts/
    │   └── animations/
    │
    ├── lib/
    ├── test/
    │
    ├── pubspec.yaml
    └── README.md
```

---

# 5.4 Organisation du dossier `lib`

Le dossier `lib` contient l'ensemble du code source de l'application.

```text
lib/
│
├── core/
├── config/
├── routes/
├── services/
├── shared/
├── features/
├── widgets/
├── theme/
├── utils/
└── main.dart
```

Description des principaux dossiers :

| Dossier     | Description                                                                |
| ----------- | -------------------------------------------------------------------------- |
| `core/`     | Configuration générale, constantes, stockage local et gestion des erreurs. |
| `config/`   | Configuration globale de l'application.                                    |
| `routes/`   | Gestion centralisée de la navigation entre les écrans.                     |
| `services/` | Communication avec les API REST du backend.                                |
| `shared/`   | Classes, modèles et composants partagés entre plusieurs modules.           |
| `features/` | Modules fonctionnels de l'application.                                     |
| `widgets/`  | Widgets personnalisés et réutilisables.                                    |
| `theme/`    | Couleurs, typographies et styles de l'application.                         |
| `utils/`    | Fonctions utilitaires.                                                     |

---

# 5.5 Modules fonctionnels

L'application est organisée en plusieurs modules correspondant aux fonctionnalités du système.

```text
features/
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

Chaque module possède une structure interne identique afin d'assurer une organisation cohérente du projet.

---

# 5.6 Architecture interne d'un module

```text
authentication/
│
├── models/
├── screens/
├── widgets/
├── providers/
├── services/
└── controllers/
```

Cette organisation est appliquée à tous les modules de l'application.

---

# 5.7 Navigation

La navigation est centralisée afin de faciliter la gestion des différents écrans.

Les principaux écrans sont :

* Splash Screen ;
* Connexion ;
* Tableau de bord ;
* Gestion des clients ;
* Gestion des services ;
* Gestion des commandes ;
* Paiements ;
* Caisse ;
* Rapports ;
* Notifications ;
* Paramètres.

---

# 5.8 Communication avec le backend

Le frontend communique avec le backend Django REST Framework au moyen d'API REST sécurisées.

Les principales étapes sont les suivantes :

1. L'utilisateur effectue une action dans l'application.
2. Le frontend envoie une requête HTTP.
3. Le backend traite la requête.
4. Les données sont enregistrées ou récupérées dans PostgreSQL.
5. Une réponse JSON est renvoyée.
6. L'interface est mise à jour.

---

# 5.9 Gestion de l'état

Afin de garantir une gestion efficace des données et des interactions entre les différents écrans, l'application utilisera un gestionnaire d'état (State Management).

Le choix définitif de la solution (Provider, Riverpod, Bloc ou autre) sera effectué lors de la phase de développement en fonction des besoins du projet.

---

# 5.10 Design System

L'application s'appuie sur un Design System garantissant une interface homogène.

Il comprend notamment :

* palette de couleurs ;
* typographies ;
* icônes ;
* boutons ;
* champs de saisie ;
* tableaux ;
* cartes d'information ;
* boîtes de dialogue ;
* messages d'erreur ;
* indicateurs de chargement.

Cette approche garantit une expérience utilisateur cohérente sur l'ensemble de l'application.

---

# 5.11 Sécurité

Plusieurs mécanismes contribuent à la sécurité du frontend :

* authentification par jetons JWT ;
* stockage sécurisé des informations de connexion ;
* contrôle des accès aux différentes fonctionnalités ;
* validation des données saisies avant leur transmission au backend ;
* gestion centralisée des erreurs.

---

# 5.12 Évolutivité

L'architecture retenue facilite l'ajout de nouvelles fonctionnalités sans remettre en cause l'organisation générale du projet.

Grâce à sa structure modulaire, chaque nouveau module pourra être développé indépendamment avant d'être intégré à l'application.

---

# 5.13 Conclusion

L'architecture du frontend Flutter offre une organisation claire, modulaire et évolutive. Elle facilite le développement collaboratif, améliore la réutilisation des composants et garantit une intégration efficace avec le backend Django REST Framework via des API REST sécurisées. Cette architecture constitue une base solide pour la réalisation d'une application moderne, performante et maintenable.
