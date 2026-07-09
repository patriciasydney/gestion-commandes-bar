from rest_framework import viewsets

from apps.utilisateurs.permissions import IsAdministrateur, IsGerantOrAdmin
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Fournisseur
from .serializers import FournisseurSerializer


class FournisseurViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Fournisseur.objects.all().order_by("raison_sociale")
    serializer_class = FournisseurSerializer

    role_permissions = {
        "list": [IsGerantOrAdmin],
        "retrieve": [IsGerantOrAdmin],
        "create": [IsGerantOrAdmin],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsAdministrateur],
        "default": [IsGerantOrAdmin],
    }
