from django.utils import timezone
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

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


class UtilisateurCreationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = Utilisateur
        fields = [
            "username",
            "password",
            "nom",
            "prenom",
            "email",
            "telephone",
            "statut",
            "role",
        ]

    def create(self, validated_data):
        password = validated_data.pop("password")
        validated_data.setdefault("date_creation", timezone.now())
        utilisateur = Utilisateur(**validated_data)
        utilisateur.set_password(password)
        utilisateur.save()
        return utilisateur


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
