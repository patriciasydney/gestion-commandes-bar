from rest_framework import viewsets

from apps.utilisateurs.permissions import IsCaissier, IsGerantOrAdmin
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Client
from .serializers import ClientSerializer


class ClientViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Client.objects.all().order_by("nom", "prenom")
    serializer_class = ClientSerializer

    role_permissions = {
        "list": [IsCaissier],
        "retrieve": [IsCaissier],
        "create": [IsCaissier],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "default": [IsCaissier],
    }
