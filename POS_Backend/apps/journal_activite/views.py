from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from apps.utilisateurs.permissions import IsJournalReader
from apps.utils.mixins import RoleActionPermissionMixin

from .models import JournalActivite
from .serializers import JournalActiviteSerializer


class JournalActiviteViewSet(RoleActionPermissionMixin, viewsets.ReadOnlyModelViewSet):
    queryset = JournalActivite.objects.select_related("utilisateur").all()
    serializer_class = JournalActiviteSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["utilisateur", "action"]

    role_permissions = {
        "list": [IsJournalReader],
        "retrieve": [IsJournalReader],
        "default": [IsJournalReader],
    }
