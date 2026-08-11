from django.urls import path

from . import views

urlpatterns = [
    path("", views.parametres_detail, name="parametres-detail"),
    path("sauvegardes/", views.liste_sauvegardes, name="parametres-sauvegardes"),
    path("sauvegardes/creer/", views.creer_sauvegarde, name="parametres-sauvegarde-creer"),
    path("sauvegardes/restaurer/", views.restaurer_sauvegarde, name="parametres-sauvegarde-restaurer"),
]
