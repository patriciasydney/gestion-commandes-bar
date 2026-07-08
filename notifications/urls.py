from django.urls import path
from .views import liste_notifications, marquer_lue

urlpatterns = [
    path('', liste_notifications),
    path('<int:pk>/lue/', marquer_lue),
]
