from rest_framework import serializers

from apps.utils.fields import MontantDecimalField


class ProduitStockFaibleSerializer(serializers.Serializer):
    produit = serializers.CharField()
    quantite = serializers.IntegerField()
    seuil = serializers.IntegerField()


class DashboardSummarySerializer(serializers.Serializer):
    date = serializers.DateField()
    chiffre_affaires_jour = MontantDecimalField()
    nombre_tickets_jour = serializers.IntegerField()
    depenses_jour = MontantDecimalField()
    produits_stock_faible = ProduitStockFaibleSerializer(many=True)
