from rest_framework import viewsets

from apps.utilisateurs.permissions import IsAdministrateur, IsGerantOrAdmin, IsStockReader
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Categorie
from .serializers import CategorieSerializer


class CategorieViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Categorie.objects.all().order_by("nom")
    serializer_class = CategorieSerializer

    role_permissions = {
        "list": [IsStockReader],
        "retrieve": [IsStockReader],
        "create": [IsGerantOrAdmin],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsAdministrateur],
        "default": [IsGerantOrAdmin],
    }
