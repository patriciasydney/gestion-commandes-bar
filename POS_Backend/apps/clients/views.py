from rest_framework import viewsets

from .models import Client
from .serializers import ClientSerializer


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all().order_by("nom", "prenom")
    serializer_class = ClientSerializer
