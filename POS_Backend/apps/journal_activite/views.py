from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from .models import JournalActivite
from .serializers import JournalActiviteSerializer


class JournalActiviteViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = JournalActivite.objects.select_related("utilisateur").all()
    serializer_class = JournalActiviteSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["utilisateur", "action"]
