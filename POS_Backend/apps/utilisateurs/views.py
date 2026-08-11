from rest_framework import permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import Role, Utilisateur
from .permissions import IsAdministrateur
from .serializers import (
    CustomTokenObtainPairSerializer,
    RoleSerializer,
    UtilisateurCreationSerializer,
    UtilisateurSerializer,
)


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


@api_view(["GET"])
@permission_classes([permissions.IsAuthenticated])
def utilisateur_courant(request):
    """Profil de l'utilisateur connecté — rafraîchissement session Flutter."""
    utilisateur = Utilisateur.objects.select_related("role").get(pk=request.user.pk)
    return Response(UtilisateurSerializer(utilisateur).data)


class RoleViewSet(viewsets.ModelViewSet):
    queryset = Role.objects.all().order_by("nom_role")
    serializer_class = RoleSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdministrateur]


class UtilisateurViewSet(viewsets.ModelViewSet):
    queryset = Utilisateur.objects.all().select_related("role")
    permission_classes = [permissions.IsAuthenticated, IsAdministrateur]

    def get_serializer_class(self):
        if self.action == "create":
            return UtilisateurCreationSerializer
        return UtilisateurSerializer
