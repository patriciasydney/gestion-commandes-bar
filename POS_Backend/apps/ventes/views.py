from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.journal_activite.services import enregistrer_journal
from apps.utilisateurs.permissions import (
    IsCaissier,
    IsGerantOrAdmin,
    IsOwnerOrAdmin,
    IsVenteOperator,
)
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Caisse, Vente
from .serializers import (
    CaisseFermetureSerializer,
    CaisseSerializer,
    VenteAnnulationSerializer,
    VenteCreateSerializer,
    VenteSerializer,
)


class CaisseViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Caisse.objects.all().order_by("-date_ouverture")
    serializer_class = CaisseSerializer

    role_permissions = {
        "list": [IsVenteOperator],
        "retrieve": [IsVenteOperator],
        "create": [IsCaissier],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "fermer": [IsCaissier],
        "default": [IsVenteOperator],
    }

    def get_permissions(self):
        if self.action == "fermer":
            return [IsCaissier(), IsOwnerOrAdmin()]
        return super().get_permissions()

    def perform_create(self, serializer):
        caisse = serializer.save(utilisateur=self.request.user)
        enregistrer_journal(
            self.request,
            "caisse.ouvrir",
            f"Ouverture caisse #{caisse.id_caisse}",
        )

    @action(detail=True, methods=["post"])
    def fermer(self, request, pk=None):
        caisse = self.get_object()
        self.check_object_permissions(request, caisse)
        serializer = CaisseFermetureSerializer(
            data=request.data, context={"caisse": caisse}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        enregistrer_journal(
            request,
            "caisse.fermer",
            f"Fermeture caisse #{caisse.id_caisse}",
        )
        return Response(CaisseSerializer(caisse).data)


class VenteViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Vente.objects.all().order_by("-date_vente")
    serializer_class = VenteSerializer

    role_permissions = {
        "list": [IsVenteOperator],
        "retrieve": [IsVenteOperator],
        "create": [IsCaissier],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "annuler": [IsGerantOrAdmin],
        "default": [IsVenteOperator],
    }

    def get_serializer_class(self):
        if self.action == "create":
            return VenteCreateSerializer
        return VenteSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        vente = serializer.save()
        return Response(VenteSerializer(vente).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def annuler(self, request, pk=None):
        vente = self.get_object()
        serializer = VenteAnnulationSerializer(
            data={},
            context={"vente": vente, "vente_request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(VenteSerializer(vente).data)
