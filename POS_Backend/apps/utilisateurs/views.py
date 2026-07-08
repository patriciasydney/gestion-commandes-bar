from rest_framework import permissions, viewsets
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import Role, Utilisateur
from .serializers import (
    CustomTokenObtainPairSerializer,
    RoleSerializer,
    UtilisateurCreationSerializer,
    UtilisateurSerializer,
)


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


class RoleViewSet(viewsets.ModelViewSet):
    queryset = Role.objects.all().order_by("nom_role")
    serializer_class = RoleSerializer
    permission_classes = [permissions.IsAuthenticated]


class UtilisateurViewSet(viewsets.ModelViewSet):
    queryset = Utilisateur.objects.all().select_related("role")
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action == "create":
            return UtilisateurCreationSerializer
        return UtilisateurSerializer
