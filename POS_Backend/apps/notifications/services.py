from django.utils import timezone
from datetime import timedelta

from .models import Notification


def detecter_stock_faible():
    from apps.stocks.models import Stock

    for s in Stock.objects.select_related("produit").all():
        if s.en_alerte:
            message = (
                f"Stock faible : {s.produit.nom} "
                f"({s.quantite_disponible} restant, seuil {s.seuil_alerte})"
            )
            deja_signale = Notification.objects.filter(
                type="stock_faible", message=message, lu=False
            ).exists()
            if not deja_signale:
                Notification.objects.create(type="stock_faible", message=message)


def detecter_caisses_ouvertes():
    from apps.ventes.models import Caisse

    seuil = timezone.now() - timedelta(hours=24)
    for c in Caisse.objects.filter(statut="ouverte", date_ouverture__lte=seuil):
        message = f"Caisse #{c.id_caisse} ouverte depuis plus de 24h"
        deja_signale = Notification.objects.filter(
            type="caisse_ouverte", message=message, lu=False
        ).exists()
        if not deja_signale:
            Notification.objects.create(type="caisse_ouverte", message=message)


def detecter_alertes():
    detecter_stock_faible()
    detecter_caisses_ouvertes()
