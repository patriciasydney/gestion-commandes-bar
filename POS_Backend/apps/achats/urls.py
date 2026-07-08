from rest_framework.routers import DefaultRouter

from .views import AchatViewSet

router = DefaultRouter()
router.register("achats", AchatViewSet, basename="achat")

urlpatterns = router.urls
