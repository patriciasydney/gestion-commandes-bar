# 3. Architecture Physique

## 3.1 Présentation

L'architecture physique décrit l'infrastructure matérielle et réseau nécessaire au fonctionnement de l'application de gestion des commandes du cybercafé. Elle présente les différents équipements utilisés, leur rôle ainsi que les interactions entre eux.

L'application repose sur une architecture **client-serveur** dans laquelle les postes clients exécutent l'application Flutter, tandis que le serveur héberge le backend Django et la base de données PostgreSQL. Les différents équipements communiquent au sein d'un réseau local (LAN), garantissant un accès rapide et sécurisé aux ressources.

---

## 3.2 Composants matériels

L'infrastructure physique est composée des éléments suivants :

### Poste Administrateur

Le poste administrateur permet de gérer l'ensemble de l'application. Il offre l'accès aux fonctionnalités d'administration, à la gestion des utilisateurs, aux rapports, aux paramètres du système et à la supervision générale.

### Poste Opérateur

Le poste opérateur est utilisé pour enregistrer les commandes des clients, gérer les prestations, effectuer les paiements et imprimer les reçus.

### Serveur d'application

Le serveur d'application héberge le backend développé avec Django et Django REST Framework. Il traite les requêtes provenant des postes clients, applique les règles métier et assure la communication avec la base de données.

### Serveur de base de données

Le serveur de base de données héberge PostgreSQL. Il stocke l'ensemble des informations relatives aux utilisateurs, aux clients, aux prestations, aux commandes, aux paiements, aux opérations de caisse et aux notifications.

### Réseau local (LAN)

Le réseau local assure la communication entre les postes clients, le serveur d'application, le serveur de base de données et les équipements connectés.

### Routeur

Le routeur fournit l'accès au réseau local et, si nécessaire, à Internet pour les mises à jour, les sauvegardes ou les services externes.

### Commutateur (Switch)

Le commutateur relie les différents équipements du réseau local afin de garantir une communication fiable et performante.

### Imprimante multifonction

L'imprimante multifonction permet l'impression des reçus, des documents administratifs et des rapports générés par l'application.

### Scanner

Le scanner est utilisé pour la numérisation des documents des clients et des pièces administratives.

### Photocopieur

Le photocopieur permet la réalisation des prestations de reproduction de documents proposées par le cybercafé.

### Caméras de surveillance

Les caméras assurent la sécurité des locaux et contribuent au contrôle des activités du cybercafé.

---

## 3.3 Architecture de communication

Les utilisateurs accèdent à l'application Flutter depuis leurs postes de travail. Les requêtes sont transmises au backend Django via le réseau local. Le backend traite les demandes, interagit avec PostgreSQL pour lire ou enregistrer les données, puis retourne une réponse au frontend.

Les équipements tels que les imprimantes et les scanners sont connectés au réseau afin d'être accessibles depuis les postes de travail.

---

## 3.4 Schéma de l'architecture physique

```text
                           Internet
                               │
                         ┌───────────┐
                         │ Routeur   │
                         └─────┬─────┘
                               │
                        ┌────────────┐
                        │   Switch   │
                        └─────┬──────┘
                              │
          ┌───────────────────┼────────────────────┐
          │                   │                    │
   ┌─────────────┐     ┌─────────────┐      ┌─────────────┐
   │ Poste       │     │ Poste       │      │ Imprimante  │
   │ Administr.  │     │ Opérateur   │      │ Scanner     │
   └──────┬──────┘     └──────┬──────┘      └─────────────┘
          │                   │
          └──────────────┬────┘
                         │
                ┌──────────────────┐
                │ Serveur Django   │
                │ Django REST API  │
                └────────┬─────────┘
                         │
                ┌──────────────────┐
                │ PostgreSQL       │
                │ Base de données  │
                └──────────────────┘

          Caméras IP connectées au réseau local
```

---

## 3.5 Sécurité de l'infrastructure

Afin de garantir la disponibilité et la sécurité du système, plusieurs mesures sont prévues :

* authentification des utilisateurs avant tout accès à l'application ;
* contrôle des rôles et des permissions ;
* sauvegardes régulières de la base de données ;
* sécurisation du réseau local ;
* protection des équipements par des mots de passe ;
* journalisation des opérations sensibles ;
* surveillance des locaux grâce aux caméras.

---

## 3.6 Évolutivité

L'architecture physique est conçue de manière à pouvoir évoluer en fonction des besoins du cybercafé. Il sera possible d'ajouter de nouveaux postes de travail, de nouvelles imprimantes, d'autres équipements réseau ou un serveur plus performant sans remettre en cause l'organisation générale du système.

Cette évolutivité garantit la pérennité de l'application et facilite son adaptation à l'augmentation de l'activité.
