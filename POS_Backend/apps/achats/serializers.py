from decimal import Decimal

from django.db import transaction
from rest_framework import serializers

from apps.produits.models import Produit
from apps.stocks.models import MouvementStock, Stock

from .models import Achat, DetailAchat


class DetailAchatInputSerializer(serializers.Serializer):
    produit = serializers.PrimaryKeyRelatedField(queryset=Produit.objects.all())
    quantite = serializers.IntegerField(min_value=1)
    prix_unitaire = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=0)


class DetailAchatSerializer(serializers.ModelSerializer):
    # GeneratedField (PostgreSQL) — déclaration explicite pour drf-spectacular / Swagger
    sous_total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

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
        fields = ["fournisseur", "utilisateur", "details"]

    def validate(self, attrs):
        if not attrs.get("details"):
            raise serializers.ValidationError("Un achat doit contenir au moins un produit.")
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        details_data = validated_data.pop("details")
        achat = Achat.objects.create(montant_total=0, **validated_data)

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
        return achat
