from decimal import Decimal

from django.db import transaction
from django.utils import timezone
from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers

from apps.journal_activite.services import enregistrer_journal
from apps.paiements.models import Paiement
from apps.paiements.serializers import PaiementSerializer
from apps.produits.models import Produit
from apps.stocks.models import MouvementStock, Stock
from apps.utilisateurs.permissions import RoleNames, get_user_role_name
from apps.utils.fields import MontantDecimalField

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
        read_only_fields = [
            "id_caisse",
            "date_ouverture",
            "date_fermeture",
            "statut",
            "utilisateur",
        ]


class CaisseFermetureSerializer(serializers.Serializer):
    montant_final = MontantDecimalField(min_value=0)

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
    prix_unitaire = MontantDecimalField(required=False, min_value=0)


class DetailVenteSerializer(serializers.ModelSerializer):
    # GeneratedField (DB) — déclaration explicite pour drf-spectacular
    sous_total = MontantDecimalField(read_only=True)

    class Meta:
        model = DetailVente
        fields = ["id_detail", "produit", "quantite", "prix_unitaire", "sous_total"]
        read_only_fields = fields


class VenteSerializer(serializers.ModelSerializer):
    details = DetailVenteSerializer(many=True, read_only=True)
    paiements = serializers.SerializerMethodField()
    client_nom = serializers.SerializerMethodField()

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
            "client_nom",
            "caisse",
            "details",
            "paiements",
        ]
        read_only_fields = ["id_vente", "date_vente", "montant_total", "statut", "client_nom"]

    @extend_schema_field(str)
    def get_client_nom(self, obj):
        if obj.client_id is None:
            return None
        return str(obj.client)

    @extend_schema_field(PaiementSerializer(many=True))
    def get_paiements(self, obj):
        return PaiementSerializer(obj.paiements.all(), many=True).data


def _appliquer_sortie_stock(vente, utilisateur, request=None):
    """Décrémente le stock et crée les mouvements pour une vente validée."""
    for detail in vente.details.select_related("produit"):
        stock = Stock.objects.select_for_update().get(produit=detail.produit)
        if stock.quantite_disponible < detail.quantite:
            raise serializers.ValidationError(
                f"Stock insuffisant pour « {detail.produit} » "
                f"(disponible : {stock.quantite_disponible}, demandé : {detail.quantite})."
            )

        stock.quantite_disponible -= detail.quantite
        stock.save(update_fields=["quantite_disponible", "date_maj"])

        MouvementStock.objects.create(
            produit=detail.produit,
            type_mouvement=MouvementStock.TYPE_VENTE,
            quantite=-detail.quantite,
            utilisateur=utilisateur,
            reference_operation=vente.reference,
        )

        from apps.notifications.services import signaler_alerte_stock

        signaler_alerte_stock(stock)


class VenteCreateSerializer(serializers.ModelSerializer):
    details = DetailVenteInputSerializer(many=True, write_only=True)
    en_attente = serializers.BooleanField(required=False, default=False, write_only=True)

    class Meta:
        model = Vente
        fields = ["reference", "remise", "client", "caisse", "details", "en_attente"]

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

        request = self.context.get("request")
        role = get_user_role_name(request.user) if request and request.user.is_authenticated else None
        en_attente = attrs.get("en_attente", False)
        if role == RoleNames.SERVEUR or en_attente:
            if attrs.get("client") is None:
                raise serializers.ValidationError(
                    {
                        "client": "La commande doit être liée à un client (nom obligatoire)."
                    }
                )
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        request = self.context.get("request")
        if request is None or not request.user.is_authenticated:
            raise serializers.ValidationError(
                {"detail": "Authentification requise pour créer une vente."}
            )

        details_data = validated_data.pop("details")
        en_attente = validated_data.pop("en_attente", False)
        role = get_user_role_name(request.user)
        # Le serveur ne peut que transmettre une commande (jamais une vente validée directe).
        if role == RoleNames.SERVEUR:
            en_attente = True

        remise = validated_data.get("remise", Decimal("0"))
        statut = (
            Vente.STATUT_EN_ATTENTE if en_attente else Vente.STATUT_VALIDEE
        )

        # Vérification stock (même en attente) pour éviter les commandes impossibles.
        for line in details_data:
            produit = line["produit"]
            quantite = line["quantite"]
            stock = Stock.objects.select_for_update().get(produit=produit)
            if stock.quantite_disponible < quantite:
                raise serializers.ValidationError(
                    f"Stock insuffisant pour « {produit} » "
                    f"(disponible : {stock.quantite_disponible}, demandé : {quantite})."
                )

        vente = Vente.objects.create(
            montant_total=0,
            utilisateur=request.user,
            statut=statut,
            **validated_data,
        )

        montant_total = Decimal("0")
        for line in details_data:
            produit = line["produit"]
            quantite = line["quantite"]
            prix_unitaire = line.get("prix_unitaire", produit.prix_vente)

            DetailVente.objects.create(
                vente=vente,
                produit=produit,
                quantite=quantite,
                prix_unitaire=prix_unitaire,
            )
            montant_total += quantite * prix_unitaire

        vente.montant_total = montant_total - remise
        vente.save(update_fields=["montant_total"])

        if statut == Vente.STATUT_VALIDEE:
            _appliquer_sortie_stock(vente, request.user, request)

        action = "vente.commande" if en_attente else "vente.create"
        enregistrer_journal(
            request,
            action,
            f"{'Commande' if en_attente else 'Vente'} {vente.reference} "
            f"— total {vente.montant_total} ({vente.statut})",
        )
        if statut == Vente.STATUT_EN_ATTENTE:
            from apps.notifications.services import signaler_commande_en_attente

            signaler_commande_en_attente(vente)
        return vente


class VenteEncaissementSerializer(serializers.Serializer):
    mode_paiement = serializers.ChoiceField(
        choices=["especes", "mobile_money", "carte_bancaire", "mixte"]
    )
    reference_transaction = serializers.CharField(
        required=False, allow_blank=True, allow_null=True, max_length=100
    )

    @transaction.atomic
    def save(self, **kwargs):
        vente = self.context["vente"]
        request = self.context["request"]

        if vente.statut != Vente.STATUT_EN_ATTENTE:
            raise serializers.ValidationError(
                "Seules les commandes en attente peuvent être encaissées."
            )
        if vente.caisse.statut != Caisse.STATUT_OUVERTE:
            raise serializers.ValidationError(
                "La caisse liée à cette commande n'est plus ouverte."
            )

        _appliquer_sortie_stock(vente, request.user, request)

        Paiement.objects.create(
            vente=vente,
            mode_paiement=self.validated_data["mode_paiement"],
            montant=vente.montant_total,
            reference_transaction=self.validated_data.get("reference_transaction") or None,
        )

        vente.statut = Vente.STATUT_VALIDEE
        vente.save(update_fields=["statut"])

        from apps.notifications.services import resoudre_notifications_commande

        resoudre_notifications_commande(vente)

        enregistrer_journal(
            request,
            "vente.encaisser",
            f"Encaissement commande {vente.reference} — {vente.montant_total}",
        )
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

        # Les commandes en_attente n'ont pas encore sorti de stock : pas de restauration.
        if vente.statut != Vente.STATUT_EN_ATTENTE:
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

                from apps.notifications.services import signaler_alerte_stock

                signaler_alerte_stock(stock)

        vente.statut = Vente.STATUT_ANNULEE
        vente.save(update_fields=["statut"])

        from apps.notifications.services import resoudre_notifications_commande

        resoudre_notifications_commande(vente)

        request = self.context.get("vente_request")
        if request:
            enregistrer_journal(
                request,
                "vente.annuler",
                f"Annulation vente {vente.reference}",
            )
        return vente
