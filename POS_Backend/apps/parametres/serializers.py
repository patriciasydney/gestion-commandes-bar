from rest_framework import serializers

from .models import ParametreSysteme


class ParametreSystemeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParametreSysteme
        fields = (
            "nom_entreprise",
            "adresse",
            "telephone",
            "email",
            "rccm",
            "nif",
            "tva_active",
            "tva_taux",
            "taxe_boisson_active",
            "taxe_boisson_taux",
            "imprimantes",
            "sauvegarde_auto",
            "derniere_sauvegarde",
            "date_modification",
        )
        read_only_fields = ("derniere_sauvegarde", "date_modification")


class SauvegardeMetaSerializer(serializers.Serializer):
    nom = serializers.CharField()
    taille = serializers.IntegerField()
    date_creation = serializers.DateTimeField()
