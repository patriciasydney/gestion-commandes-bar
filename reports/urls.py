from django.urls import path
from .views import rapport_ventes, rapport_produits, rapport_depenses

urlpatterns = [
    path('ventes/', rapport_ventes),
    path('produits/', rapport_produits),
    path('depenses/', rapport_depenses),
]
