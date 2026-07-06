from django.db import transaction
from rest_framework import serializers

from .models import Stock, MouvementStock


class StockSerializer(serializers.ModelSerializer):
    en_alerte = serializers.BooleanField(read_only=True)

    class Meta:
        model = Stock
        fields = [
            'id_stock', 'produit', 'quantite_disponible',
            'seuil_alerte', 'date_maj', 'en_alerte',
        ]
        read_only_fields = ['id_stock', 'quantite_disponible', 'date_maj']


class MouvementStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = MouvementStock
        fields = [
            'id_mouvement', 'produit', 'type_mouvement', 'quantite',
            'date_mouvement', 'utilisateur', 'reference_operation',
        ]
        read_only_fields = fields


class AjustementStockSerializer(serializers.Serializer):
    """
    Ajustement manuel du stock par le magasinier (inventaire, casse, erreur...).
    `quantite` est signée : positive pour ajouter, négative pour retirer.
    """
    quantite = serializers.IntegerField()
    utilisateur = serializers.IntegerField()  # id_utilisateur — à remplacer par request.user si l'auth JWT est en place
    reference_operation = serializers.CharField(required=False, allow_blank=True)

    def validate_quantite(self, value):
        if value == 0:
            raise serializers.ValidationError("La quantité d'ajustement ne peut pas être nulle.")
        return value

    @transaction.atomic
    def save(self, **kwargs):
        stock = self.context['stock']
        quantite = self.validated_data['quantite']

        stock = Stock.objects.select_for_update().get(pk=stock.pk)
        nouvelle_quantite = stock.quantite_disponible + quantite
        if nouvelle_quantite < 0:
            raise serializers.ValidationError(
                f"Ajustement refusé : le stock passerait à {nouvelle_quantite} (négatif)."
            )

        stock.quantite_disponible = nouvelle_quantite
        stock.save(update_fields=['quantite_disponible', 'date_maj'])

        MouvementStock.objects.create(
            produit=stock.produit,
            type_mouvement=MouvementStock.TYPE_AJUSTEMENT,
            quantite=quantite,
            utilisateur_id=self.validated_data['utilisateur'],
            reference_operation=self.validated_data.get('reference_operation', ''),
        )
        return stock
