# 1. Architecture Globale du Système

## 1.1 Présentation

L'architecture globale décrit l'organisation générale de l'application de gestion des commandes du cybercafé. Elle présente les principaux composants du système ainsi que leurs interactions afin d'assurer un fonctionnement cohérent, sécurisé et évolutif.

L'application repose sur une architecture **client-serveur** composée de trois couches principales :

* la couche de présentation (Frontend Flutter) ;
* la couche métier (Backend Django REST Framework) ;
* la couche de données (Base de données PostgreSQL).

Cette séparation des responsabilités facilite la maintenance, améliore les performances du système et permet le développement parallèle des différentes composantes de l'application.

---

## 1.2 Vue d'ensemble de l'architecture

L'application est constituée des éléments suivants :

### Frontend Flutter

Le frontend représente l'interface utilisateur de l'application. Développé avec Flutter, il permet aux utilisateurs d'accéder aux différentes fonctionnalités du système, notamment :

* l'authentification ;
* la gestion des commandes ;
* la gestion des clients ;
* la gestion des prestations ;
* les paiements ;
* la gestion de la caisse ;
* le tableau de bord ;
* les rapports.

Le frontend communique exclusivement avec le backend via des API REST sécurisées.

### Backend Django

Le backend constitue le cœur du système. Développé avec Django et Django REST Framework, il assure :

* la logique métier ;
* la validation des données ;
* la gestion des utilisateurs ;
* l'application des règles de gestion ;
* la sécurisation des accès ;
* la communication avec la base de données.

### Base de données PostgreSQL

La base de données PostgreSQL assure le stockage des informations de l'application :

* utilisateurs ;
* clients ;
* services ;
* commandes ;
* paiements ;
* opérations de caisse ;
* notifications ;
* rapports.

Elle garantit l'intégrité, la cohérence et la sécurité des données.

---

## 1.3 Architecture en trois couches

Le système adopte une architecture en trois couches :

* **Couche de présentation** : interface utilisateur développée avec Flutter.
* **Couche métier** : backend développé avec Django REST Framework.
* **Couche de données** : base de données PostgreSQL.

Cette architecture permet une séparation claire entre l'interface utilisateur, la logique métier et le stockage des données.

---

## 1.4 Communication entre les composants

Le fonctionnement global de l'application suit le processus suivant :

1. L'utilisateur interagit avec l'application Flutter.
2. Le frontend envoie une requête HTTP au backend.
3. Le backend traite la requête en appliquant les règles métier.
4. Le backend interroge la base de données PostgreSQL.
5. PostgreSQL retourne les données demandées.
6. Le backend renvoie une réponse au format JSON.
7. Le frontend affiche les résultats à l'utilisateur.

---

## 1.5 Schéma de l'architecture globale

```text
                   Utilisateur
                         │
                         ▼
               Application Flutter
                         │
               API REST (HTTP/JSON)
                         │
                         ▼
          Django REST Framework
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
    Logique métier              Authentification
          │
          ▼
      PostgreSQL
```

---

## 1.6 Technologies utilisées

| Couche                  | Technologie           |
| ----------------------- | --------------------- |
| Frontend                | Flutter               |
| Backend                 | Django                |
| API                     | Django REST Framework |
| Base de données         | PostgreSQL            |
| Authentification        | JWT                   |
| Gestion des dépendances | Git & GitHub          |

---

## 1.7 Avantages de l'architecture

L'architecture retenue présente plusieurs avantages :

* séparation claire des responsabilités ;
* développement indépendant du frontend et du backend ;
* communication standardisée via les API REST ;
* sécurité renforcée grâce à l'authentification JWT ;
* maintenance simplifiée ;
* facilité d'évolution et d'ajout de nouvelles fonctionnalités ;
* compatibilité avec un déploiement local ou sur un serveur distant.

---

## 1.8 Conclusion

L'architecture globale retenue répond aux besoins fonctionnels et techniques de l'application de gestion des commandes du cybercafé. Elle offre une structure modulaire, évolutive et sécurisée, adaptée au développement collaboratif et aux exigences d'un système moderne basé sur Flutter, Django REST Framework et PostgreSQL.
