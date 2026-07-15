from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import CanManageCatalog

from .models import Categorie
from .serializers import CategorieSerializer


class CategorieViewSet(viewsets.ModelViewSet):
    queryset = Categorie.objects.all().order_by("nom")
    serializer_class = CategorieSerializer
    permission_classes = [IsAuthenticated, CanManageCatalog]
