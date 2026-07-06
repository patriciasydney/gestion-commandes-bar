from rest_framework.routers import DefaultRouter

from .views import StockViewSet, MouvementStockViewSet

router = DefaultRouter()
router.register('stocks', StockViewSet, basename='stock')
router.register('mouvements-stock', MouvementStockViewSet, basename='mouvement-stock')

urlpatterns = router.urls
