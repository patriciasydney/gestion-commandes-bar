from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import CanManageDepenses

from .models import Depense
from .serializers import DepenseSerializer


class DepenseViewSet(viewsets.ModelViewSet):
    queryset = Depense.objects.order_by("-date_depense")
    serializer_class = DepenseSerializer
    permission_classes = [IsAuthenticated, CanManageDepenses]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["categorie", "utilisateur"]
