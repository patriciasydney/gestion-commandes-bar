from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    # Auth & utilisateurs (Michel / Yohan)
    path("api/", include("apps.utilisateurs.urls")),
    # Opérations métier (Gildas / Paul)
    path("api/", include("apps.ventes.urls")),
    path("api/", include("apps.achats.urls")),
    path("api/", include("apps.stocks.urls")),
    path("api/", include("apps.paiements.urls")),
    path("api/", include("apps.depenses.urls")),
    path("api/", include("apps.journal_activite.urls")),
    # Catalogue (Patricia)
    path("api/categories/", include("apps.categories.urls")),
    path("api/produits/", include("apps.produits.urls")),
    path("api/fournisseurs/", include("apps.fournisseurs.urls")),
    path("api/clients/", include("apps.clients.urls")),
    # Dashboard, rapports, notifications (Sindiely / Laetitia)
    path("api/dashboard/", include("apps.dashboard.urls")),
    path("api/reports/", include("apps.reports.urls")),
    path("api/notifications/", include("apps.notifications.urls")),
    # Documentation OpenAPI (Sindiely)
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
]
