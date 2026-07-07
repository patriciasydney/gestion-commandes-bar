from rest_framework import serializers
from .models import Categorie, Fournisseur, Produit, Client

class CategorieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorie
        fields = '__all__'  # Expose tous les champs (id, nom, description)

class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = '__all__'

class ProduitSerializer(serializers.ModelSerializer):
    # Ces lignes permettent d'afficher les détails de la catégorie et du fournisseur au lieu de simples identifiants numériques
    categorie_details = CategorieSerializer(source='categorie', read_only=True)
    fournisseur_details = FournisseurSerializer(source='fournisseur', read_only=True)

    class Meta:
        model = Produit
        fields = [
            'id', 'code', 'code_barres', 'nom', 'description', 
            'prix_achat', 'prix_vente', 'stock_minimum', 'image', 
            'categorie', 'fournisseur', 'categorie_details', 'fournisseur_details', 
            'date_creation'
        ]

class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'
