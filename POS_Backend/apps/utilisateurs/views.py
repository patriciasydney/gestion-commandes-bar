from rest_framework import viewsets
from rest_framework_simplejwt.views import TokenObtainPairView

from apps.utilisateurs.permissions import IsAdministrateur, IsGerantOrAdmin, IsOwnerOrAdmin
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Role, Utilisateur
from .serializers import (
    CustomTokenObtainPairSerializer,
    UtilisateurCreationSerializer,
    UtilisateurSerializer,
    RoleSerializer,
)


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


class RoleViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Role.objects.all().order_by("nom_role")
    serializer_class = RoleSerializer

    role_permissions = {
        "list": [IsAdministrateur],
        "retrieve": [IsAdministrateur],
        "create": [IsAdministrateur],
        "update": [IsAdministrateur],
        "partial_update": [IsAdministrateur],
        "destroy": [IsAdministrateur],
        "default": [IsAdministrateur],
    }


class UtilisateurViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Utilisateur.objects.all().select_related("role")

    role_permissions = {
        "list": [IsAdministrateur],
        "retrieve": [IsAdministrateur],
        "create": [IsAdministrateur],
        "update": [IsAdministrateur],
        "partial_update": [IsAdministrateur],
        "destroy": [IsAdministrateur],
        "default": [IsAdministrateur],
    }

    def get_permissions(self):
        if self.action in ("retrieve", "partial_update", "update"):
            return [IsOwnerOrAdmin()]
        return super().get_permissions()

    def get_serializer_class(self):
        if self.action == "create":
            return UtilisateurCreationSerializer
        return UtilisateurSerializer
