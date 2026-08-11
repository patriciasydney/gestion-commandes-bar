from rest_framework import serializers

from .models import Categorie


class CategorieSerializer(serializers.ModelSerializer):
    nombre_produits = serializers.SerializerMethodField()

    class Meta:
        model = Categorie
        fields = [
            "id_categorie",
            "nom",
            "description",
            "actif",
            "nombre_produits",
        ]
        read_only_fields = ["id_categorie", "nombre_produits"]

    def get_nombre_produits(self, obj):
        annotated = getattr(obj, "nombre_produits", None)
        if annotated is not None:
            return annotated
        if obj.pk is None:
            return 0
        return obj.produits.count()
