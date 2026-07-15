from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import CanManageClients

from .models import Client
from .serializers import ClientSerializer


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all().order_by("nom", "prenom")
    serializer_class = ClientSerializer
    permission_classes = [IsAuthenticated, CanManageClients]
