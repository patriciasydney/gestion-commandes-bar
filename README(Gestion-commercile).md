#  Module de Gestion Commerciale

Ce module est une refonte complète et propre de la gestion commerciale pour l'application globale de gestion de commande de bar. Il remplace l'ancienne structure monolithique par **4 micro-applications Django indépendantes, spécialisées et structurées** selon les meilleures pratiques de développement (Clean Architecture / Single Responsibility Principle).

Chaque application possède ses propres modèles PostgreSQL, ses sérialiseurs et ses contrôleurs (ViewSets) exposés via une API REST robuste avec **Django REST Framework (DRF)**.

---

##  Architecture du Module

La gestion commerciale a été segmentée en 4 entités autonomes au sein du répertoire de travail :

```text
gestion-commandes-bar/
├── categories/          # Gestion des catégories de produits
├── customers/           # Gestion de la base clients
├── products/            # Gestion du catalogue de produits
└── suppliers/           # Gestion des fournisseurs (fournisseurs)
1.  Categories (categories)
Prend en charge la classification des articles disponibles au bar.
    • Modèle (Category) : Nom, Description.
    • API Endpoint : GET, POST, PUT, DELETE sur /api/categories/
2.  Customers (customers)
Gère les fiches d'informations des clients du bar pour le suivi et la fidélisation.
    • Modèle (Customer) : Prénom, Nom, Téléphone.
    • API Endpoint : GET, POST, PUT, DELETE sur /api/clients/
3.  Products (products)
Cœur du catalogue. Permet de suivre l'inventaire des boissons et articles vendus.
    • Modèle (Product) : Nom, Description, Prix, Stock, Catégorie (Relation ForeignKey).
    • API Endpoint : GET, POST, PUT, DELETE sur /api/produits/
4. Suppliers (suppliers)
Supervise la relation avec les partenaires et grossistes qui approvisionnent le bar.
    • Modèle (Supplier) : Nom, Téléphone, Email.
    • API Endpoint : GET, POST, PUT, DELETE sur /api/fournisseurs/
 Installation et Configuration
Pour intégrer et lancer ces applications sur votre environnement local, suivez les étapes suivantes :
1. Activer l'environnement virtuel et installer les dépendances
Bash
# Activation de l'environnement
source env/bin/activate

# Assurez-vous que Django REST Framework est installé
pip install djangorestframework
2. Enregistrement dans settings.py
Les applications doivent être déclarées dans la liste des INSTALLED_APPS du projet principal (backend/settings.py) :
Python
INSTALLED_APPS = [
    # ... autres applications Django et tierces ...
    'rest_framework',
    
    # Vos 4 nouveaux modules propres :
    'products',
    'categories',
    'suppliers',
    'customers',
]
3. Configuration du routage principal (backend/urls.py)
Pour maintenir la compatibilité avec le reste du projet et l'historique de l'équipe, les URLs de l'API sont configurées en français tout en pointant vers les modules propres :
Python
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Routage vers les 4 nouvelles applications propres
    path('api/produits/', include('products.urls')),
    path('api/categories/', include('categories.urls')),
    path('api/fournisseurs/', include('suppliers.urls')),
    path('api/clients/', include('customers.urls')),
]
Base de données & Migrations
Une fois les fichiers de modèles configurés, générez les tables PostgreSQL associées :
Bash
# 1. Détection des nouveaux modèles et création des fichiers de migration
python manage.py makemigrations

# 2. Application des tables sur la base de données PostgreSQL active
python manage.py migrate
 Lancement et Points d'accès API
Démarrez le serveur de développement local :
Bash
python manage.py runserver
Le serveur sera accessible à l'adresse http://127.0.0.1:8000/. L'interface de navigation de Django REST Framework est disponible aux endpoints suivants :
    • Catalogue des Produits : http://127.0.0.1:8000/api/produits/
    • Gestion des Catégories : http://127.0.0.1:8000/api/categories/
    • Fiches des Fournisseurs : http://127.0.0.1:8000/api/fournisseurs/
    • Base des Clients : http://127.0.0.1:8000/api/clients/
 Développeur
    • Auteur : Patricia (patriciasydney)
    • Branche Git : patricia
