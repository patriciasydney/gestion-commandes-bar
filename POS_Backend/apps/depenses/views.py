from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from apps.utilisateurs.permissions import IsFinanceOperator
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Depense
from .serializers import DepenseSerializer


class DepenseViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Depense.objects.order_by("-date_depense")
    serializer_class = DepenseSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["categorie", "utilisateur"]

    role_permissions = {
        "list": [IsFinanceOperator],
        "retrieve": [IsFinanceOperator],
        "create": [IsFinanceOperator],
        "update": [IsFinanceOperator],
        "partial_update": [IsFinanceOperator],
        "destroy": [IsFinanceOperator],
        "default": [IsFinanceOperator],
    }

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context
