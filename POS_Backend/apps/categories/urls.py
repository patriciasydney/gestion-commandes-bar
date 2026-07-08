from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CategorieViewSet

router = DefaultRouter()
router.register(r"", CategorieViewSet, basename="categorie")

urlpatterns = [
    path("", include(router.urls)),
]
