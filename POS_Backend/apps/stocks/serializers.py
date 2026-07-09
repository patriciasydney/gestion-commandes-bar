from django.db import transaction
from rest_framework import serializers

from apps.journal_activite.services import enregistrer_journal

from .models import MouvementStock, Stock


class StockSerializer(serializers.ModelSerializer):
    en_alerte = serializers.BooleanField(read_only=True)

    class Meta:
        model = Stock
        fields = [
            "id_stock",
            "produit",
            "quantite_disponible",
            "seuil_alerte",
            "date_maj",
            "en_alerte",
        ]
        read_only_fields = ["id_stock", "quantite_disponible", "date_maj"]


class MouvementStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = MouvementStock
        fields = [
            "id_mouvement",
            "produit",
            "type_mouvement",
            "quantite",
            "date_mouvement",
            "utilisateur",
            "reference_operation",
        ]
        read_only_fields = fields


class AjustementStockSerializer(serializers.Serializer):
    quantite = serializers.IntegerField()
    reference_operation = serializers.CharField(required=False, allow_blank=True)

    def validate_quantite(self, value):
        if value == 0:
            raise serializers.ValidationError(
                "La quantité d'ajustement ne peut pas être nulle."
            )
        return value

    @transaction.atomic
    def save(self, **kwargs):
        request = self.context.get("request")
        if request is None or not request.user.is_authenticated:
            raise serializers.ValidationError(
                {"detail": "Authentification requise pour ajuster le stock."}
            )

        stock = self.context["stock"]
        quantite = self.validated_data["quantite"]
        utilisateur = request.user

        stock = Stock.objects.select_for_update().get(pk=stock.pk)
        nouvelle_quantite = stock.quantite_disponible + quantite
        if nouvelle_quantite < 0:
            raise serializers.ValidationError(
                f"Ajustement refusé : le stock passerait à {nouvelle_quantite} (négatif)."
            )

        stock.quantite_disponible = nouvelle_quantite
        stock.save(update_fields=["quantite_disponible", "date_maj"])

        MouvementStock.objects.create(
            produit=stock.produit,
            type_mouvement=MouvementStock.TYPE_AJUSTEMENT,
            quantite=quantite,
            utilisateur=utilisateur,
            reference_operation=self.validated_data.get("reference_operation", ""),
        )

        enregistrer_journal(
            request,
            "stock.ajuster",
            f"Produit #{stock.produit_id} : {quantite:+d} (stock={stock.quantite_disponible})",
        )
        return stock
