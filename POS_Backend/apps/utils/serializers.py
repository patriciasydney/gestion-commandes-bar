"""
Helpers pour les serializers — injection de request.user.
"""
from rest_framework import serializers


class UtilisateurFromRequestMixin:
    """Renseigne automatiquement le(s) champ(s) FK utilisateur depuis request.user."""

    utilisateur_fields = ("utilisateur",)

    def _inject_utilisateur(self, validated_data):
        request = self.context.get("request")
        if request is None or not request.user.is_authenticated:
            raise serializers.ValidationError(
                {"detail": "Authentification requise pour cette opération."}
            )
        for field in self.utilisateur_fields:
            validated_data[field] = request.user
        return validated_data
