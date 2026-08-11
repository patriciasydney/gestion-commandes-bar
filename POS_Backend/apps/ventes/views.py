from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.journal_activite.services import enregistrer_journal
from apps.utilisateurs.permissions import (
    IsCaissier,
    IsCaissierOrAdmin,
    IsGerantOrAdmin,
    IsOwnerOrAdmin,
    IsVenteOperator,
    RoleNames,
    get_user_role_name,
)
from apps.utils.mixins import RoleActionPermissionMixin

from .models import Caisse, Vente
from .serializers import (
    CaisseFermetureSerializer,
    CaisseSerializer,
    VenteAnnulationSerializer,
    VenteCreateSerializer,
    VenteEncaissementSerializer,
    VenteSerializer,
)


class CaisseViewSet(RoleActionPermissionMixin, viewsets.ModelViewSet):
    queryset = Caisse.objects.all().order_by("-date_ouverture")
    serializer_class = CaisseSerializer

    role_permissions = {
        "list": [IsVenteOperator],
        "retrieve": [IsVenteOperator],
        "create": [IsCaissierOrAdmin],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "fermer": [IsCaissierOrAdmin],
        "default": [IsVenteOperator],
    }

    def get_permissions(self):
        if self.action == "fermer":
            return [IsCaissierOrAdmin(), IsOwnerOrAdmin()]
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
    queryset = Vente.objects.all().select_related(
        "utilisateur", "client", "caisse"
    ).prefetch_related("details__produit", "paiements").order_by("-date_vente")
    serializer_class = VenteSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["statut", "caisse", "utilisateur"]

    role_permissions = {
        "list": [IsVenteOperator],
        "retrieve": [IsVenteOperator],
        "create": [IsVenteOperator],
        "update": [IsGerantOrAdmin],
        "partial_update": [IsGerantOrAdmin],
        "destroy": [IsGerantOrAdmin],
        "annuler": [IsVenteOperator],
        "encaisser": [IsCaissier],
        "default": [IsVenteOperator],
    }

    def get_serializer_class(self):
        if self.action == "create":
            return VenteCreateSerializer
        if self.action == "encaisser":
            return VenteEncaissementSerializer
        return VenteSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["request"] = self.request
        return context

    def get_queryset(self):
        qs = super().get_queryset()
        role = get_user_role_name(self.request.user)
        # Le serveur ne voit que ses propres commandes/ventes.
        if role == RoleNames.SERVEUR:
            qs = qs.filter(utilisateur=self.request.user)

        date_debut = self.request.query_params.get("date_debut")
        date_fin = self.request.query_params.get("date_fin")
        if date_debut:
            qs = qs.filter(date_vente__date__gte=date_debut)
        if date_fin:
            qs = qs.filter(date_vente__date__lte=date_fin)
        return qs

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        vente = serializer.save()
        return Response(VenteSerializer(vente).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def encaisser(self, request, pk=None):
        vente = self.get_object()
        serializer = VenteEncaissementSerializer(
            data=request.data,
            context={"vente": vente, "request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        vente.refresh_from_db()
        return Response(VenteSerializer(vente).data)

    @action(detail=True, methods=["post"])
    def annuler(self, request, pk=None):
        vente = self.get_object()
        role = get_user_role_name(request.user)
        if role == RoleNames.SERVEUR and vente.utilisateur_id != request.user.id:
            return Response(
                {"detail": "Vous ne pouvez annuler que vos propres commandes."},
                status=status.HTTP_403_FORBIDDEN,
            )
        if role == RoleNames.SERVEUR and vente.statut != Vente.STATUT_EN_ATTENTE:
            return Response(
                {"detail": "Seules les commandes en attente peuvent être annulées."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = VenteAnnulationSerializer(
            data={},
            context={"vente": vente, "vente_request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        vente.refresh_from_db()
        return Response(VenteSerializer(vente).data)
