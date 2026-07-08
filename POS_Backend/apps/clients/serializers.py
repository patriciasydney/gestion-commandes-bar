from django.utils import timezone
from rest_framework import serializers

from .models import Client


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = [
            "id_client",
            "nom",
            "prenom",
            "telephone",
            "email",
            "adresse",
            "actif",
            "date_creation",
        ]
        read_only_fields = ["id_client", "date_creation"]

    def create(self, validated_data):
        validated_data.setdefault("date_creation", timezone.now())
        return Client.objects.create(**validated_data)
