from django.utils import timezone
from rest_framework import serializers

from .models import Fournisseur


class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = [
            "id_fournisseur",
            "raison_sociale",
            "telephone",
            "adresse",
            "email",
            "actif",
            "date_creation",
        ]
        read_only_fields = ["id_fournisseur", "date_creation"]

    def create(self, validated_data):
        validated_data.setdefault("date_creation", timezone.now())
        return Fournisseur.objects.create(**validated_data)
