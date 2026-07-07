from django.utils import timezone
from datetime import timedelta
from .models import Notification


def detecter_stock_faible():
    from stocks.models import Stock

    stocks = Stock.objects.select_related('produit').all()
    for s in stocks:
        if s.quantite_disponible <= s.seuil_alerte:
            message = f"Stock faible : {s.produit.nom} ({s.quantite_disponible} restant, seuil {s.seuil_alerte})"
            deja_signale = Notification.objects.filter(
                type='stock_faible', message=message, lu=False
            ).exists()
            if not deja_signale:
                Notification.objects.create(type='stock_faible', message=message)


def detecter_caisses_ouvertes():
    from ventes.models import Caisse

    seuil = timezone.now() - timedelta(hours=24)
    caisses = Caisse.objects.filter(statut='ouverte', date_ouverture__lte=seuil)
    for c in caisses:
        message = f"Caisse #{c.id_caisse} ouverte depuis plus de 24h"
        deja_signale = Notification.objects.filter(
            type='caisse_ouverte', message=message, lu=False
        ).exists()
        if not deja_signale:
            Notification.objects.create(type='caisse_ouverte', message=message)


def detecter_alertes():
    detecter_stock_faible()
    detecter_caisses_ouvertes()
