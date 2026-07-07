from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import viewsets, permissions

from .models import Utilisateur
from .serializers import (
    UtilisateurSerializer,
    UtilisateurCreationSerializer,
    CustomTokenObtainPairSerializer,
)


class CustomTokenObtainPairView(TokenObtainPairView):
    """
    Endpoint de connexion (POST /api/auth/login/) qui renvoie access + refresh token,
    en utilisant notre serializer personnalisé (avec infos utilisateur incluses).
    """
    serializer_class = CustomTokenObtainPairSerializer


class UtilisateurViewSet(viewsets.ModelViewSet):
    """
    CRUD complet sur les utilisateurs (réservé aux administrateurs en pratique,
    à restreindre via des permissions personnalisées selon les rôles).
    """
    queryset = Utilisateur.objects.all().select_related("role")
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action == "create":
            return UtilisateurCreationSerializer
        return UtilisateurSerializer
