from rest_framework.routers import DefaultRouter

from .views import CaisseViewSet, VenteViewSet

router = DefaultRouter()
router.register("caisses", CaisseViewSet, basename="caisse")
router.register("ventes", VenteViewSet, basename="vente")

urlpatterns = router.urls
