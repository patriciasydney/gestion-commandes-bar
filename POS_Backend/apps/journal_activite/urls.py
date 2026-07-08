from rest_framework.routers import DefaultRouter

from .views import JournalActiviteViewSet

router = DefaultRouter()
router.register("journal-activite", JournalActiviteViewSet, basename="journal-activite")

urlpatterns = router.urls
