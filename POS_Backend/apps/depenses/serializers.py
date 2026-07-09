from rest_framework import serializers

from apps.journal_activite.services import enregistrer_journal
from apps.utils.serializers import UtilisateurFromRequestMixin

from .models import Depense


class DepenseSerializer(UtilisateurFromRequestMixin, serializers.ModelSerializer):
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
        read_only_fields = ["id_depense", "date_depense", "utilisateur"]

    def create(self, validated_data):
        validated_data = self._inject_utilisateur(validated_data)
        depense = super().create(validated_data)
        enregistrer_journal(
            self.context.get("request"),
            "depense.create",
            f"{depense.libelle} — {depense.montant}",
        )
        return depense
