from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.utilisateurs.permissions import (
    IsCaisseOperator,
    IsGerantOrAdmin,
    IsPosUser,
)

from .models import Caisse, Vente
from .serializers import (
    CaisseFermetureSerializer,
    CaisseSerializer,
    VenteAnnulationSerializer,
    VenteCreateSerializer,
    VenteSerializer,
)


class CaisseViewSet(viewsets.ModelViewSet):
    queryset = Caisse.objects.all().order_by("-date_ouverture")
    serializer_class = CaisseSerializer

    def get_permissions(self):
        if self.action in ("create", "update", "partial_update", "destroy", "fermer"):
            return [IsAuthenticated(), IsCaisseOperator()]
        return [IsAuthenticated(), IsPosUser()]

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsCaisseOperator])
    def fermer(self, request, pk=None):
        caisse = self.get_object()
        serializer = CaisseFermetureSerializer(
            data=request.data, context={"caisse": caisse}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(CaisseSerializer(caisse).data)


class VenteViewSet(viewsets.ModelViewSet):
    queryset = Vente.objects.all().order_by("-date_vente")
    serializer_class = VenteSerializer

    def get_permissions(self):
        if self.action == "annuler":
            return [IsAuthenticated(), IsGerantOrAdmin()]
        if self.action in ("create", "update", "partial_update", "destroy"):
            return [IsAuthenticated(), IsPosUser()]
        return [IsAuthenticated(), IsPosUser()]

    def get_serializer_class(self):
        if self.action == "create":
            return VenteCreateSerializer
        return VenteSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        vente = serializer.save()
        return Response(VenteSerializer(vente).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, IsGerantOrAdmin])
    def annuler(self, request, pk=None):
        vente = self.get_object()
        serializer = VenteAnnulationSerializer(data={}, context={"vente": vente})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(VenteSerializer(vente).data)
