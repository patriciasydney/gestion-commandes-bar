from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Achat
from .serializers import (
    AchatAnnulationSerializer,
    AchatCreateSerializer,
    AchatSerializer,
)


class AchatViewSet(viewsets.ModelViewSet):
    queryset = Achat.objects.all().order_by("-date_achat")
    serializer_class = AchatSerializer

    def get_serializer_class(self):
        if self.action == "create":
            return AchatCreateSerializer
        return AchatSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        achat = serializer.save()
        return Response(AchatSerializer(achat).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def annuler(self, request, pk=None):
        achat = self.get_object()
        serializer = AchatAnnulationSerializer(data={}, context={"achat": achat})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(AchatSerializer(achat).data)
