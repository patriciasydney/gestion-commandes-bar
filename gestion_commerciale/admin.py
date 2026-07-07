from django.contrib import admin
from .models import Categorie, Fournisseur, Produit, Client

@admin.register(Categorie)
class CategorieAdmin(admin.ModelAdmin):
    list_display = ('id', 'nom', 'description')
    search_fields = ('nom',)

@admin.register(Fournisseur)
class FournisseurAdmin(admin.ModelAdmin):
    list_display = ('id', 'raison_sociale', 'telephone', 'email')
    search_fields = ('raison_sociale', 'email')

@admin.register(Produit)
class ProduitAdmin(admin.ModelAdmin):
    list_display = ('code', 'nom', 'categorie', 'prix_achat', 'prix_vente', 'stock_minimum')
    list_filter = ('categorie', 'fournisseur')
    search_fields = ('code', 'nom', 'code_barres')

@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = ('id', 'nom', 'prenom', 'telephone')
    search_fields = ('nom', 'telephone')
