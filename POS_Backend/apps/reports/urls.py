from django.urls import path

from .views import rapport_depenses, rapport_produits, rapport_ventes

urlpatterns = [
    path("ventes/", rapport_ventes),
    path("produits/", rapport_produits),
    path("depenses/", rapport_depenses),
]
