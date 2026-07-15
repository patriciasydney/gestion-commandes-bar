from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.utilisateurs.permissions import CanReadStock

from .models import MouvementStock, Stock
from .serializers import AjustementStockSerializer, MouvementStockSerializer, StockSerializer


class StockViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Stock.objects.select_related("produit").all()
    serializer_class = StockSerializer
    permission_classes = [IsAuthenticated, CanReadStock]

    @action(detail=False, methods=["get"], permission_classes=[IsAuthenticated, CanReadStock])
    def alertes(self, request):
        queryset = [s for s in self.get_queryset() if s.en_alerte]
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated, CanReadStock])
    def ajuster(self, request, pk=None):
        stock = self.get_object()
        serializer = AjustementStockSerializer(
            data=request.data, context={"stock": stock}
        )
        serializer.is_valid(raise_exception=True)
        stock = serializer.save()
        return Response(StockSerializer(stock).data)


class MouvementStockViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = MouvementStock.objects.select_related(
        "produit", "utilisateur"
    ).order_by("-date_mouvement")
    serializer_class = MouvementStockSerializer
    permission_classes = [IsAuthenticated, CanReadStock]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["produit", "type_mouvement"]
