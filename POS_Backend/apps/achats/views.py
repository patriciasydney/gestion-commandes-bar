from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.utilisateurs.permissions import IsAchatOperator, IsGerantOrAdmin
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Achat
from .serializers import (
    AchatAnnulationSerializer,
    AchatCreateSerializer,
    AchatSerializer,
)


class AchatViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Achat.objects.all().order_by("-date_achat")
    serializer_class = AchatSerializer

    role_permissions = {
        "list": [IsAchatOperator],
        "retrieve": [IsAchatOperator],
        "create": [IsAchatOperator],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "annuler": [IsGerantOrAdmin],
        "default": [IsAchatOperator],
    }

    def get_serializer_class(self):
        if self.action == "create":
            return AchatCreateSerializer
        return AchatSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        achat = serializer.save()
        return Response(AchatSerializer(achat).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def annuler(self, request, pk=None):
        achat = self.get_object()
        serializer = AchatAnnulationSerializer(
            data={},
            context={"achat": achat, "achat_request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(AchatSerializer(achat).data)
