from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import FournisseurViewSet

router = DefaultRouter()
router.register(r"", FournisseurViewSet, basename="fournisseur")

urlpatterns = [
    path("", include(router.urls)),
]
