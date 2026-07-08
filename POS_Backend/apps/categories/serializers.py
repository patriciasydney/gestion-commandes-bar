from rest_framework import serializers

from .models import Categorie


class CategorieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorie
        fields = ["id_categorie", "nom", "description", "actif"]
        read_only_fields = ["id_categorie"]
