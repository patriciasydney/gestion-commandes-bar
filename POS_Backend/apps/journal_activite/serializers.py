from rest_framework import serializers

from .models import JournalActivite


class JournalActiviteSerializer(serializers.ModelSerializer):
    class Meta:
        model = JournalActivite
        fields = [
            "id_journal",
            "utilisateur",
            "action",
            "description",
            "date_action",
            "adresse_ip",
        ]
        read_only_fields = ["id_journal", "date_action"]
