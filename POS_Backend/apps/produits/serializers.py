from django.db import transaction
from django.utils import timezone
from rest_framework import serializers

from apps.stocks.models import Stock

from .models import Produit


class ProduitSerializer(serializers.ModelSerializer):
    class Meta:
        model = Produit
        fields = [
            "id_produit",
            "code",
            "code_barres",
            "nom",
            "description",
            "prix_achat",
            "prix_vente",
            "contenance",
            "stock_minimum",
            "image",
            "actif",
            "date_creation",
            "categorie",
            "fournisseur",
        ]
        read_only_fields = ["id_produit", "date_creation"]


class ProduitCreateSerializer(ProduitSerializer):
    """Crée le produit et la fiche stock associée (relation 1-1)."""

    @transaction.atomic
    def create(self, validated_data):
        validated_data.setdefault("date_creation", timezone.now())
        produit = Produit.objects.create(**validated_data)
        Stock.objects.create(
            produit=produit,
            quantite_disponible=0,
            seuil_alerte=produit.stock_minimum,
        )
        return produit
