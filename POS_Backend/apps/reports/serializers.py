from rest_framework import serializers

from apps.utils.fields import MontantDecimalField


class PeriodeSerializer(serializers.Serializer):
    debut = serializers.DateField(allow_null=True)
    fin = serializers.DateField(allow_null=True)


class RapportVenteJourSerializer(serializers.Serializer):
    jour = serializers.DateField()
    total_jour = MontantDecimalField()
    tickets = serializers.IntegerField()


class RapportVentesSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    total_ventes = MontantDecimalField()
    nombre_ventes = serializers.IntegerField()
    detail_par_jour = RapportVenteJourSerializer(many=True)


class TopProduitSerializer(serializers.Serializer):
    produit__nom = serializers.CharField()
    quantite_totale = serializers.IntegerField()
    chiffre_affaires = MontantDecimalField()


class RapportProduitsSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    top_produits = TopProduitSerializer(many=True)


class DepenseCategorieSerializer(serializers.Serializer):
    categorie = serializers.CharField()
    total_categorie = MontantDecimalField()


class RapportDepensesSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    total_depenses = MontantDecimalField()
    par_categorie = DepenseCategorieSerializer(many=True)
