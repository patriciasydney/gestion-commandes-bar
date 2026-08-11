from rest_framework import serializers

from .constants import CATEGORIES_DEPENSE
from .models import Depense


class DepenseSerializer(serializers.ModelSerializer):
    categorie = serializers.ChoiceField(choices=[(c, c) for c in CATEGORIES_DEPENSE])

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
