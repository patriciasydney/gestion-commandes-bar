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

    def validate_image(self, value):
        """Le champ stocke un chemin/URL court, pas une image encodée."""
        if value in (None, ""):
            return None
        if len(value) > 255:
            raise serializers.ValidationError(
                "L'image doit être un chemin ou une URL (255 caractères max), "
                "pas une photo encodée en base64."
            )
        return value

    def validate_code_barres(self, value):
        if value in (None, ""):
            return None
        return value

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
