from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CategorieViewSet, FournisseurViewSet, ProduitViewSet, ClientViewSet

# Le routeur de Django REST Framework gère automatiquement les URLs du CRUD
router = DefaultRouter()
router.register(r'categories', CategorieViewSet, basename='categorie')
router.register(r'fournisseurs', FournisseurViewSet, basename='fournisseur')
router.register(r'produits', ProduitViewSet, basename='produit')
router.register(r'clients', ClientViewSet, basename='client')

urlpatterns = [
    path('', include(router.urls)),
]