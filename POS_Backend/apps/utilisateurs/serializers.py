from django.utils import timezone
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.exceptions import AuthenticationFailed

from .models import Role, Utilisateur


class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = ["id_role", "nom_role", "description", "actif", "date_creation"]
        read_only_fields = ["id_role", "date_creation"]


class UtilisateurSerializer(serializers.ModelSerializer):
    role = RoleSerializer(read_only=True)
    role_id = serializers.PrimaryKeyRelatedField(
        queryset=Role.objects.all(), source="role", write_only=True, required=False
    )

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "nom",
            "prenom",
            "email",
            "telephone",
            "statut",
            "date_creation",
            "role",
            "role_id",
            "photo",
        ]
        read_only_fields = ["id", "date_creation"]

    def update(self, instance, validated_data):
        if "statut" in validated_data:
            validated_data["is_active"] = (
                validated_data["statut"] == Utilisateur.Statut.ACTIF
            )
        return super().update(instance, validated_data)


class UtilisateurCreationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "password",
            "nom",
            "prenom",
            "email",
            "telephone",
            "statut",
            "role",
            "date_creation",
        ]
        read_only_fields = ["id", "date_creation"]

    def create(self, validated_data):
        password = validated_data.pop("password")
        validated_data.setdefault("date_creation", timezone.now())
        statut = validated_data.get("statut", Utilisateur.Statut.ACTIF)
        validated_data["is_active"] = statut == Utilisateur.Statut.ACTIF
        utilisateur = Utilisateur(**validated_data)
        utilisateur.set_password(password)
        utilisateur.save()
        return utilisateur

    def to_representation(self, instance):
        """Réponse complète alignée sur le frontend (id + rôle imbriqué)."""
        return UtilisateurSerializer(instance, context=self.context).data


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["username"] = user.username
        token["nom"] = user.nom
        token["prenom"] = user.prenom
        token["role"] = user.role.nom_role if user.role else None
        token["statut"] = user.statut
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        user = self.user
        if not user.is_active or user.statut != Utilisateur.Statut.ACTIF:
            raise AuthenticationFailed(
                "Ce compte est inactif ou suspendu.",
                code="user_inactive",
            )
        data["utilisateur"] = UtilisateurSerializer(user).data
        return data
