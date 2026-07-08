# Intégré depuis la branche Sindiely (Laetitia) — module Dashboard §5.14
from django.db.models import Count, Sum
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.depenses.models import Depense
from apps.stocks.models import Stock
from apps.utilisateurs.permissions import IsGerantOrComptable
from apps.ventes.models import Vente


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsGerantOrComptable])
def dashboard_summary(request):
    today = timezone.now().date()

    ventes_jour = Vente.objects.filter(date_vente__date=today, statut="validee")
    chiffre_affaires = ventes_jour.aggregate(total=Sum("montant_total"))["total"] or 0
    nombre_tickets = ventes_jour.aggregate(count=Count("id_vente"))["count"] or 0

    depenses_jour = Depense.objects.filter(date_depense__date=today)
    total_depenses = depenses_jour.aggregate(total=Sum("montant"))["total"] or 0

    stocks_faibles = [
        s for s in Stock.objects.select_related("produit").all() if s.en_alerte
    ]

    return Response(
        {
            "date": str(today),
            "chiffre_affaires_jour": chiffre_affaires,
            "nombre_tickets_jour": nombre_tickets,
            "depenses_jour": total_depenses,
            "produits_stock_faible": [
                {
                    "produit": s.produit.nom,
                    "quantite": s.quantite_disponible,
                    "seuil": s.seuil_alerte,
                }
                for s in stocks_faibles
            ],
        }
    )
