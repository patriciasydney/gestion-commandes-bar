from rest_framework import serializers


class PeriodeSerializer(serializers.Serializer):
    debut = serializers.DateField(allow_null=True)
    fin = serializers.DateField(allow_null=True)


class DetailJourSerializer(serializers.Serializer):
    jour = serializers.DateField()
    total_jour = serializers.DecimalField(max_digits=10, decimal_places=2)
    tickets = serializers.IntegerField()


class RapportVentesSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    total_ventes = serializers.DecimalField(max_digits=10, decimal_places=2)
    nombre_ventes = serializers.IntegerField()
    detail_par_jour = DetailJourSerializer(many=True)


class TopProduitSerializer(serializers.Serializer):
    produit__nom = serializers.CharField()
    quantite_totale = serializers.IntegerField()
    chiffre_affaires = serializers.DecimalField(max_digits=10, decimal_places=2)


class RapportProduitsSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    top_produits = TopProduitSerializer(many=True)


class DepenseCategorieSerializer(serializers.Serializer):
    categorie = serializers.CharField()
    total_categorie = serializers.DecimalField(max_digits=10, decimal_places=2)


class RapportDepensesSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    total_depenses = serializers.DecimalField(max_digits=10, decimal_places=2)
    par_categorie = DepenseCategorieSerializer(many=True)


class AchatFournisseurSerializer(serializers.Serializer):
    fournisseur__raison_sociale = serializers.CharField()
    total_fournisseur = serializers.DecimalField(max_digits=10, decimal_places=2)
    nombre_achats = serializers.IntegerField()


class RapportAchatsSerializer(serializers.Serializer):
    periode = PeriodeSerializer()
    total_achats = serializers.DecimalField(max_digits=10, decimal_places=2)
    nombre_achats = serializers.IntegerField()
    par_fournisseur = AchatFournisseurSerializer(many=True)
