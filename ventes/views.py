from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Caisse, Vente
from .serializers import (
    CaisseSerializer, CaisseFermetureSerializer,
    VenteSerializer, VenteCreateSerializer, VenteAnnulationSerializer,
)


class CaisseViewSet(viewsets.ModelViewSet):
    queryset = Caisse.objects.all().order_by('-date_ouverture')
    serializer_class = CaisseSerializer

    @action(detail=True, methods=['post'])
    def fermer(self, request, pk=None):
        caisse = self.get_object()
        serializer = CaisseFermetureSerializer(
            data=request.data, context={'caisse': caisse}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(CaisseSerializer(caisse).data)


class VenteViewSet(viewsets.ModelViewSet):
    queryset = Vente.objects.all().order_by('-date_vente')
    serializer_class = VenteSerializer

    def get_serializer_class(self):
        if self.action == 'create':
            return VenteCreateSerializer
        return VenteSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        vente = serializer.save()
        return Response(
            VenteSerializer(vente).data, status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['post'])
    def annuler(self, request, pk=None):
        vente = self.get_object()
        serializer = VenteAnnulationSerializer(data={}, context={'vente': vente})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(VenteSerializer(vente).data)
