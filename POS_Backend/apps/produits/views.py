from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import CanManageCatalog

from .models import Produit
from .serializers import ProduitCreateSerializer, ProduitSerializer


class ProduitViewSet(viewsets.ModelViewSet):
    queryset = Produit.objects.select_related("categorie", "fournisseur").all()
    serializer_class = ProduitSerializer
    permission_classes = [IsAuthenticated, CanManageCatalog]

    def get_serializer_class(self):
        if self.action == "create":
            return ProduitCreateSerializer
        return ProduitSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        search = self.request.query_params.get("search")
        if search:
            qs = qs.filter(nom__icontains=search)
        categorie = self.request.query_params.get("categorie")
        if categorie:
            qs = qs.filter(categorie_id=categorie)
        return qs.order_by("nom")
