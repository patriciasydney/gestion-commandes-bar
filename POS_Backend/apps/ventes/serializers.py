from decimal import Decimal

from django.db import transaction
from django.utils import timezone
from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers

from apps.produits.models import Produit
from apps.stocks.models import MouvementStock, Stock

from .models import Caisse, DetailVente, Vente


class CaisseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Caisse
        fields = [
            "id_caisse",
            "date_ouverture",
            "date_fermeture",
            "montant_initial",
            "montant_final",
            "statut",
            "utilisateur",
        ]
        read_only_fields = ["id_caisse", "date_ouverture", "date_fermeture", "statut"]


class CaisseFermetureSerializer(serializers.Serializer):
    montant_final = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=0)

    def save(self, **kwargs):
        caisse = self.context["caisse"]
        if caisse.statut == Caisse.STATUT_FERMEE:
            raise serializers.ValidationError("Cette caisse est déjà fermée.")
        caisse.montant_final = self.validated_data["montant_final"]
        caisse.statut = Caisse.STATUT_FERMEE
        caisse.date_fermeture = timezone.now()
        caisse.save(update_fields=["montant_final", "statut", "date_fermeture"])
        return caisse


class DetailVenteInputSerializer(serializers.Serializer):
    produit = serializers.PrimaryKeyRelatedField(queryset=Produit.objects.all())
    quantite = serializers.IntegerField(min_value=1)
    prix_unitaire = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, min_value=0
    )


class DetailVenteSerializer(serializers.ModelSerializer):
    # GeneratedField (PostgreSQL) — déclaration explicite pour drf-spectacular / Swagger
    sous_total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = DetailVente
        fields = ["id_detail", "produit", "quantite", "prix_unitaire", "sous_total"]
        read_only_fields = fields


class VenteSerializer(serializers.ModelSerializer):
    details = DetailVenteSerializer(many=True, read_only=True)
    paiements = serializers.SerializerMethodField()

    class Meta:
        model = Vente
        fields = [
            "id_vente",
            "reference",
            "date_vente",
            "montant_total",
            "remise",
            "statut",
            "utilisateur",
            "client",
            "caisse",
            "details",
            "paiements",
        ]
        read_only_fields = ["id_vente", "date_vente", "montant_total", "statut"]

    @extend_schema_field(serializers.ListField(child=serializers.DictField()))
    def get_paiements(self, obj):
        from apps.paiements.serializers import PaiementSerializer

        return PaiementSerializer(obj.paiements.all(), many=True).data


class VenteCreateSerializer(serializers.ModelSerializer):
    details = DetailVenteInputSerializer(many=True, write_only=True)

    class Meta:
        model = Vente
        fields = ["reference", "remise", "utilisateur", "client", "caisse", "details"]

    def validate(self, attrs):
        if not attrs.get("details"):
            raise serializers.ValidationError(
                "Une vente doit contenir au moins un article."
            )
        caisse = attrs["caisse"]
        if caisse.statut != Caisse.STATUT_OUVERTE:
            raise serializers.ValidationError(
                "La caisse doit être ouverte avant toute vente."
            )
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        details_data = validated_data.pop("details")
        remise = validated_data.get("remise", Decimal("0"))

        vente = Vente.objects.create(montant_total=0, **validated_data)

        montant_total = Decimal("0")
        for line in details_data:
            produit = line["produit"]
            quantite = line["quantite"]
            prix_unitaire = line.get("prix_unitaire", produit.prix_vente)

            stock = Stock.objects.select_for_update().get(produit=produit)
            if stock.quantite_disponible < quantite:
                raise serializers.ValidationError(
                    f"Stock insuffisant pour « {produit} » "
                    f"(disponible : {stock.quantite_disponible}, demandé : {quantite})."
                )

            DetailVente.objects.create(
                vente=vente,
                produit=produit,
                quantite=quantite,
                prix_unitaire=prix_unitaire,
            )

            stock.quantite_disponible -= quantite
            stock.save(update_fields=["quantite_disponible", "date_maj"])

            MouvementStock.objects.create(
                produit=produit,
                type_mouvement=MouvementStock.TYPE_VENTE,
                quantite=-quantite,
                utilisateur=vente.utilisateur,
                reference_operation=vente.reference,
            )

            montant_total += quantite * prix_unitaire

        vente.montant_total = montant_total - remise
        vente.save(update_fields=["montant_total"])
        return vente


class VenteAnnulationSerializer(serializers.Serializer):
    @transaction.atomic
    def save(self, **kwargs):
        vente = self.context["vente"]
        if vente.statut == Vente.STATUT_ANNULEE:
            raise serializers.ValidationError("Cette vente est déjà annulée.")
        if vente.statut == Vente.STATUT_VALIDEE:
            raise serializers.ValidationError(
                "Une vente validée ne peut plus être annulée directement."
            )

        for detail in vente.details.select_related("produit"):
            stock = Stock.objects.select_for_update().get(produit=detail.produit)
            stock.quantite_disponible += detail.quantite
            stock.save(update_fields=["quantite_disponible", "date_maj"])

            MouvementStock.objects.create(
                produit=detail.produit,
                type_mouvement=MouvementStock.TYPE_AJUSTEMENT,
                quantite=detail.quantite,
                utilisateur=vente.utilisateur,
                reference_operation=f"annulation-{vente.reference}",
            )

        vente.statut = Vente.STATUT_ANNULEE
        vente.save(update_fields=["statut"])
        return vente
