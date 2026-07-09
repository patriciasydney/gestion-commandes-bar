from decimal import Decimal

from django.db import transaction
from rest_framework import serializers

from apps.journal_activite.services import enregistrer_journal
from apps.ventes.models import Vente

from .models import Paiement


class PaiementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paiement
        fields = [
            "id_paiement",
            "vente",
            "mode_paiement",
            "montant",
            "reference_transaction",
            "date_paiement",
        ]
        read_only_fields = ["id_paiement", "date_paiement"]

    def validate(self, attrs):
        vente = attrs["vente"]
        montant = attrs["montant"]
        deja_paye = sum((p.montant for p in vente.paiements.all()), Decimal("0"))
        if deja_paye + montant > vente.montant_total:
            raise serializers.ValidationError(
                f"Le montant encaissé ({deja_paye + montant}) dépasserait le "
                f"total de la vente ({vente.montant_total})."
            )
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        paiement = Paiement.objects.create(**validated_data)

        vente = validated_data["vente"]
        total_paye = sum((p.montant for p in vente.paiements.all()), Decimal("0"))
        if total_paye >= vente.montant_total and vente.statut != Vente.STATUT_VALIDEE:
            vente.statut = Vente.STATUT_VALIDEE
            vente.save(update_fields=["statut"])

        enregistrer_journal(
            self.context.get("request"),
            "paiement.create",
            f"Paiement {paiement.montant} sur vente {vente.reference}",
        )
        return paiement
