## 4.6 Architecture de la base de données

### 4.6.1 Présentation

La base de données constitue le cœur du système d'information de l'application de gestion des commandes du cybercafé. Elle assure le stockage, l'organisation et la sécurisation des informations nécessaires au fonctionnement de l'application, notamment les utilisateurs, les clients, les services, les commandes, les paiements et les opérations de caisse.

Le système repose sur **PostgreSQL**, un système de gestion de base de données relationnelle (SGBDR) reconnu pour sa fiabilité, ses performances et sa compatibilité avec Django. PostgreSQL garantit l'intégrité des données grâce aux contraintes relationnelles, aux transactions ACID et aux mécanismes avancés de sécurité.

L'architecture de la base de données est conçue selon un modèle relationnel normalisé afin de limiter les redondances, d'assurer la cohérence des informations et de faciliter les opérations de recherche, de mise à jour et de suppression.

### 4.6.2 Organisation des données

Les données sont organisées en plusieurs entités métier représentant les différents domaines fonctionnels de l'application.

Les principales entités sont :

* Utilisateurs
* Rôles
* Clients
* Services
* Commandes
* Détails des commandes
* Paiements
* Caisses
* Sessions de caisse
* Transactions de caisse
* Notifications

Chaque entité possède une clé primaire permettant son identification unique et entretient des relations avec les autres entités à travers des clés étrangères.

### 4.6.3 Relations entre les entités

Les principales relations sont les suivantes :

* Un rôle peut être attribué à plusieurs utilisateurs.
* Un utilisateur peut créer plusieurs commandes.
* Un client peut effectuer plusieurs commandes.
* Une commande est composée d'un ou de plusieurs services.
* Chaque service peut être présent dans plusieurs commandes.
* Une commande peut être réglée par un ou plusieurs paiements selon les règles de gestion retenues.
* Une session de caisse est ouverte par un utilisateur.
* Une session de caisse contient plusieurs transactions.
* Les paiements sont associés aux mouvements de caisse.
* Les notifications sont destinées à un ou plusieurs utilisateurs.

Ces relations garantissent la cohérence des informations tout en facilitant les traitements réalisés par l'application.

### 4.6.4 Intégrité des données

Afin d'assurer la fiabilité des informations, plusieurs mécanismes d'intégrité sont mis en œuvre :

* utilisation de clés primaires pour identifier chaque enregistrement ;
* utilisation de clés étrangères pour maintenir les relations entre les tables ;
* contraintes d'unicité sur les données sensibles (nom d'utilisateur, adresse électronique, etc.) ;
* contraintes de validation sur les montants, les quantités et les états des commandes ;
* suppression et mise à jour contrôlées afin de préserver la cohérence des données.

### 4.6.5 Sécurité de la base de données

La sécurité des données repose sur plusieurs mécanismes :

* authentification sécurisée des utilisateurs ;
* gestion des rôles et des permissions ;
* chiffrement des mots de passe par Django ;
* contrôle des accès aux données via les API REST ;
* journalisation des opérations sensibles ;
* sauvegardes régulières de la base de données.

### 4.6.6 Communication avec le backend

La base de données est accessible uniquement par le backend Django. Les échanges sont réalisés à travers l'ORM (Object Relational Mapping) de Django, qui permet de manipuler les données sous forme d'objets Python sans écrire directement des requêtes SQL dans la majorité des cas.

Cette approche améliore la sécurité, facilite la maintenance et garantit la portabilité du système.

### 4.6.7 Évolutivité

L'architecture retenue est conçue pour être évolutive. De nouvelles tables ou fonctionnalités pourront être ajoutées sans remettre en cause l'organisation générale de la base de données. Cette modularité permettra d'intégrer ultérieurement de nouveaux services, de nouvelles méthodes de paiement ou d'autres fonctionnalités répondant aux besoins du cybercafé.
