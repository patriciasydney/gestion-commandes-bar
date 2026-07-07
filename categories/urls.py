from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CategoryViewSet # (Assurez-vous d'avoir un CategoryViewSet dans vos views)

router = DefaultRouter()
router.register(r'', CategoryViewSet, basename='category')

urlpatterns = [
    path('', include(router.urls)),
]