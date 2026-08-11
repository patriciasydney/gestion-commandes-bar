from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import CanManageFournisseurs

from .models import Fournisseur
from .serializers import FournisseurSerializer


class FournisseurViewSet(viewsets.ModelViewSet):
    queryset = Fournisseur.objects.all().order_by("raison_sociale")
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated, CanManageFournisseurs]
