from rest_framework import viewsets

from .models import Categorie
from .serializers import CategorieSerializer


class CategorieViewSet(viewsets.ModelViewSet):
    queryset = Categorie.objects.all().order_by("nom")
    serializer_class = CategorieSerializer
