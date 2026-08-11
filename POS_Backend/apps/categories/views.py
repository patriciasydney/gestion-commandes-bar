from django.db.models import Count, ProtectedError
from rest_framework import status, viewsets
from rest_framework.response import Response

from apps.utilisateurs.permissions import IsAdministrateur, IsGerantOrAdmin, IsStockReader
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Categorie
from .serializers import CategorieSerializer


class CategorieViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = (
        Categorie.objects.all()
        .annotate(nombre_produits=Count("produits"))
        .order_by("nom")
    )
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

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        nb = getattr(instance, "nombre_produits", None)
        if nb is None:
            nb = instance.produits.count()
        if nb > 0:
            return Response(
                {
                    "detail": (
                        f"Impossible de supprimer « {instance.nom} » : "
                        f"{nb} produit(s) y sont encore associés. "
                        "Réaffectez ou désactivez ces produits d'abord."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            return super().destroy(request, *args, **kwargs)
        except ProtectedError:
            return Response(
                {
                    "detail": (
                        f"Impossible de supprimer « {instance.nom} » : "
                        "des produits y sont encore associés."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
