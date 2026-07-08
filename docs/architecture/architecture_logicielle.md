# 2. Architecture Logicielle

## 2.1 Présentation

L'application de gestion des commandes du cybercafé est conçue selon une **architecture logicielle modulaire**, dans laquelle le système est découpé en plusieurs modules indépendants, chacun étant responsable d'un domaine fonctionnel précis.

Cette approche favorise la séparation des responsabilités, facilite le développement en équipe, simplifie la maintenance et permet une évolution progressive de l'application. Chaque module communique avec les autres à travers des interfaces bien définies, garantissant ainsi une meilleure cohérence du système.

L'application repose sur une architecture **client-serveur**, où le frontend développé avec Flutter communique avec le backend développé avec Django REST Framework à travers des API REST sécurisées. Le backend assure la logique métier et l'accès à la base de données PostgreSQL.

---

## 2.2 Organisation des modules

L'application est composée des modules fonctionnels suivants :

### Module d'authentification

Ce module assure la connexion des utilisateurs, la gestion des sessions, la sécurité des accès et l'authentification par jetons JWT.

### Module de gestion des utilisateurs

Il permet de créer, modifier, consulter et supprimer les comptes utilisateurs, ainsi que de gérer les rôles et les permissions.

### Module de gestion des clients

Ce module centralise les informations relatives aux clients du cybercafé et permet le suivi de leurs commandes.

### Module de gestion des services

Il assure la gestion des prestations proposées par le cybercafé, telles que l'impression, la photocopie, la numérisation, la saisie de documents, la connexion Internet ou toute autre prestation disponible.

### Module de gestion des commandes

Il constitue le cœur de l'application. Il permet l'enregistrement, le suivi, la modification et la validation des commandes effectuées par les clients.

### Module de gestion des paiements

Ce module prend en charge l'enregistrement des paiements, le calcul des montants à payer, la génération des reçus et le suivi des opérations financières.

### Module de gestion de la caisse

Il permet d'ouvrir et de fermer une caisse, de suivre les mouvements de caisse, de calculer les soldes et de produire les bilans de caisse.

### Module Tableau de bord

Le tableau de bord fournit une vue synthétique de l'activité du cybercafé en affichant les principaux indicateurs tels que les commandes, les recettes, les prestations et les statistiques.

### Module Rapports

Il permet de générer différents rapports d'activité, notamment les rapports de ventes, de paiements, de commandes et de caisse.

### Module Notifications

Ce module informe les utilisateurs des événements importants du système, comme la validation d'une commande, la confirmation d'un paiement ou d'autres alertes utiles.

---

## 2.3 Communication entre les modules

Les modules communiquent entre eux par l'intermédiaire du backend Django. Chaque module possède des responsabilités clairement définies et n'accède aux données des autres modules que lorsque cela est nécessaire.

Le frontend Flutter interagit avec ces modules via les API REST exposées par Django REST Framework. Cette séparation entre les différentes couches garantit une meilleure modularité, une maintenance facilitée et une évolution plus simple de l'application.

---

## 2.4 Architecture modulaire

L'architecture logicielle est organisée autour des applications Django suivantes :

* Authentication
* Users
* Customers
* Services
* Orders
* Payments
* Cash Register
* Dashboard
* Reports
* Notifications

Chaque application représente un domaine métier spécifique et possède sa propre organisation interne (modèles, sérialiseurs, services, vues, permissions, routes et tests).

---

## 2.5 Avantages de l'architecture

L'architecture retenue présente plusieurs avantages :

* séparation claire des responsabilités ;
* modularité et réutilisation du code ;
* facilité de maintenance ;
* développement collaboratif en parallèle ;
* évolutivité du système ;
* meilleure organisation des tests ;
* intégration simplifiée avec Flutter grâce aux API REST ;
* amélioration de la qualité globale du logiciel.

---

## 2.6 Vue d'ensemble de l'architecture logicielle

```text
                    Application Flutter
                           │
                           ▼
                   API REST (JSON)
                           │
                           ▼
                Django REST Framework
                           │
 ┌──────────┬──────────┬──────────┬──────────┐
 │          │          │          │          │
 ▼          ▼          ▼          ▼          ▼
Authentication  Users  Customers  Services  Orders
                                           │
                               ┌───────────┴────────────┐
                               ▼                        ▼
                           Payments             Cash Register
                               │                        │
                               └───────────┬────────────┘
                                           ▼
                                     Dashboard
                                           │
                                           ▼
                                       Reports
                                           │
                                           ▼
                                    Notifications
                                           │
                                           ▼
                                      PostgreSQL
```

---

## 2.7 Conclusion

L'architecture logicielle retenue répond aux besoins fonctionnels et techniques du projet de gestion des commandes du cybercafé. Son organisation modulaire permet une répartition efficace des tâches entre les membres de l'équipe, facilite la maintenance de l'application et offre une base solide pour les évolutions futures. Elle constitue également un support adapté au développement avec Django, Flutter et PostgreSQL.
