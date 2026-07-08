from django.utils import timezone
from django.db.models import Sum, Count
from rest_framework.decorators import api_view
from rest_framework.response import Response
from ventes.models import Vente
from stocks.models import Stock
from depenses.models import Depense


@api_view(['GET'])
def dashboard_summary(request):
    today = timezone.now().date()

    ventes_jour = Vente.objects.filter(date_vente__date=today, statut='validee')
    chiffre_affaires = ventes_jour.aggregate(total=Sum('montant_total'))['total'] or 0
    nombre_tickets = ventes_jour.aggregate(count=Count('id_vente'))['count'] or 0

    depenses_jour = Depense.objects.filter(date_depense__date=today)
    total_depenses = depenses_jour.aggregate(total=Sum('montant'))['total'] or 0

    stocks_faibles = [
        s for s in Stock.objects.select_related('produit').all()
        if s.quantite_disponible <= s.seuil_alerte
    ]

    return Response({
        'date': str(today),
        'chiffre_affaires_jour': chiffre_affaires,
        'nombre_tickets_jour': nombre_tickets,
        'depenses_jour': total_depenses,
        'produits_stock_faible': [
            {'produit': s.produit.nom, 'quantite': s.quantite_disponible, 'seuil': s.seuil_alerte}
            for s in stocks_faibles
        ],
    })
