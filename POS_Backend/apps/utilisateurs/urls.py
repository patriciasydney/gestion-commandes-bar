from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from .views import CustomTokenObtainPairView, RoleViewSet, UtilisateurViewSet

router = DefaultRouter()
router.register(r"roles", RoleViewSet, basename="role")
router.register(r"utilisateurs", UtilisateurViewSet, basename="utilisateur")

urlpatterns = [
    path("auth/login/", CustomTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("", include(router.urls)),
]
