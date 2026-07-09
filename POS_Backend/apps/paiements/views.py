from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from apps.utilisateurs.permissions import IsCaissier, IsPaiementReader
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Paiement
from .serializers import PaiementSerializer


class PaiementViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Paiement.objects.select_related("vente").order_by("-date_paiement")
    serializer_class = PaiementSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["vente", "mode_paiement"]

    role_permissions = {
        "list": [IsPaiementReader],
        "retrieve": [IsPaiementReader],
        "create": [IsCaissier],
        "update": [IsCaissier],
        "partial_update": [IsCaissier],
        "destroy": [IsCaissier],
        "default": [IsPaiementReader],
    }

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context

    http_method_names = ["get", "post", "head", "options"]
