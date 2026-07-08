from rest_framework import serializers

from .models import Depense


class DepenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Depense
        fields = [
            "id_depense",
            "libelle",
            "categorie",
            "montant",
            "date_depense",
            "utilisateur",
        ]
        read_only_fields = ["id_depense", "date_depense"]
