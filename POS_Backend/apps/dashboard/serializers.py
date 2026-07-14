from rest_framework import serializers


class ProduitStockFaibleSerializer(serializers.Serializer):
    produit = serializers.CharField()
    quantite = serializers.IntegerField()
    seuil = serializers.IntegerField()


class DashboardSummarySerializer(serializers.Serializer):
    date = serializers.DateField()
    chiffre_affaires_jour = serializers.DecimalField(max_digits=10, decimal_places=2)
    nombre_tickets_jour = serializers.IntegerField()
    depenses_jour = serializers.DecimalField(max_digits=10, decimal_places=2)
    produits_stock_faible = ProduitStockFaibleSerializer(many=True)
