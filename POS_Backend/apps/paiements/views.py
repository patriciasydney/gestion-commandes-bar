from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from .models import Paiement
from .serializers import PaiementSerializer


class PaiementViewSet(viewsets.ModelViewSet):
    queryset = Paiement.objects.select_related("vente").order_by("-date_paiement")
    serializer_class = PaiementSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["vente", "mode_paiement"]
