from decimal import Decimal

from django.db import transaction
from rest_framework import serializers

from apps.journal_activite.services import enregistrer_journal
from apps.produits.models import Produit
from apps.stocks.models import MouvementStock, Stock
from apps.utils.fields import MontantDecimalField

from .models import Achat, DetailAchat


class DetailAchatInputSerializer(serializers.Serializer):
    produit = serializers.PrimaryKeyRelatedField(queryset=Produit.objects.all())
    quantite = serializers.IntegerField(min_value=1)
    prix_unitaire = MontantDecimalField(min_value=0)


class DetailAchatSerializer(serializers.ModelSerializer):
    sous_total = MontantDecimalField(read_only=True)

    class Meta:
        model = DetailAchat
        fields = ["id_detail", "produit", "quantite", "prix_unitaire", "sous_total"]
        read_only_fields = fields


class AchatSerializer(serializers.ModelSerializer):
    details = DetailAchatSerializer(many=True, read_only=True)

    class Meta:
        model = Achat
        fields = [
            "id_achat",
            "date_achat",
            "montant_total",
            "statut",
            "fournisseur",
            "utilisateur",
            "details",
        ]
        read_only_fields = ["id_achat", "date_achat", "montant_total", "statut"]


class AchatCreateSerializer(serializers.ModelSerializer):
    details = DetailAchatInputSerializer(many=True, write_only=True)

    class Meta:
        model = Achat
        fields = ["fournisseur", "details"]

    def validate(self, attrs):
        if not attrs.get("details"):
            raise serializers.ValidationError("Un achat doit contenir au moins un produit.")
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        request = self.context.get("request")
        if request is None or not request.user.is_authenticated:
            raise serializers.ValidationError(
                {"detail": "Authentification requise pour enregistrer un achat."}
            )

        details_data = validated_data.pop("details")
        achat = Achat.objects.create(
            montant_total=0,
            utilisateur=request.user,
            **validated_data,
        )

        montant_total = Decimal("0")
        for line in details_data:
            produit = line["produit"]
            quantite = line["quantite"]
            prix_unitaire = line["prix_unitaire"]

            DetailAchat.objects.create(
                achat=achat,
                produit=produit,
                quantite=quantite,
                prix_unitaire=prix_unitaire,
            )

            stock = Stock.objects.select_for_update().get(produit=produit)
            stock.quantite_disponible += quantite
            stock.save(update_fields=["quantite_disponible", "date_maj"])

            MouvementStock.objects.create(
                produit=produit,
                type_mouvement=MouvementStock.TYPE_ACHAT,
                quantite=quantite,
                utilisateur=achat.utilisateur,
                reference_operation=f"achat-{achat.id_achat}",
            )

            montant_total += quantite * prix_unitaire

        achat.montant_total = montant_total
        achat.save(update_fields=["montant_total"])

        enregistrer_journal(
            request,
            "achat.create",
            f"Achat #{achat.id_achat} — total {achat.montant_total}",
        )
        return achat


class AchatAnnulationSerializer(serializers.Serializer):
    @transaction.atomic
    def save(self, **kwargs):
        achat = self.context["achat"]
        if achat.statut == Achat.STATUT_ANNULE:
            raise serializers.ValidationError("Cet achat est déjà annulé.")

        for detail in achat.details.select_related("produit"):
            stock = Stock.objects.select_for_update().get(produit=detail.produit)
            if stock.quantite_disponible < detail.quantite:
                raise serializers.ValidationError(
                    f"Impossible d'annuler : le stock de « {detail.produit} » "
                    f"a déjà été partiellement consommé."
                )
            stock.quantite_disponible -= detail.quantite
            stock.save(update_fields=["quantite_disponible", "date_maj"])

            MouvementStock.objects.create(
                produit=detail.produit,
                type_mouvement=MouvementStock.TYPE_AJUSTEMENT,
                quantite=-detail.quantite,
                utilisateur=achat.utilisateur,
                reference_operation=f"annulation-achat-{achat.id_achat}",
            )

        achat.statut = Achat.STATUT_ANNULE
        achat.save(update_fields=["statut"])

        request = self.context.get("achat_request")
        if request:
            enregistrer_journal(
                request,
                "achat.annuler",
                f"Annulation achat #{achat.id_achat}",
            )
        return achat
