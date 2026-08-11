"""Détection et création d'alertes stock / caisse / commandes serveur."""
from datetime import timedelta

from django.utils import timezone

from .models import Notification


def _prefixe_produit(type_alerte: str, nom_produit: str) -> str:
    if type_alerte == "rupture":
        return f"Rupture de stock : {nom_produit}"
    return f"Stock faible : {nom_produit}"


def signaler_alerte_stock(stock) -> Notification | None:
    """
    Après un mouvement de stock : crée une notification globale (utilisateur_id=NULL)
    si rupture (qty=0) ou stock faible (qty <= seuil). Résout les alertes si le stock
    remonte au-dessus du seuil.

    Visible par tous les rôles via GET /api/notifications/.
    """
    stock.refresh_from_db()
    produit = stock.produit
    qty = stock.quantite_disponible
    nom = getattr(produit, "nom", None) or f"produit #{stock.produit_id}"

    if qty > stock.seuil_alerte:
        for type_alerte in ("stock_faible", "rupture"):
            Notification.objects.filter(
                type=type_alerte,
                lu=False,
                message__startswith=_prefixe_produit(type_alerte, nom),
            ).update(lu=True)
        return None

    if qty <= 0:
        type_alerte = "rupture"
        message = f"Rupture de stock : {nom} (0 restant)"
    else:
        type_alerte = "stock_faible"
        message = (
            f"Stock faible : {nom} "
            f"({qty} restant, seuil {stock.seuil_alerte})"
        )

    prefixe = _prefixe_produit(type_alerte, nom)
    existante = (
        Notification.objects.filter(
            type=type_alerte,
            lu=False,
            message__startswith=prefixe,
        )
        .order_by("-date_notification")
        .first()
    )
    if existante:
        if existante.message != message:
            existante.message = message
            existante.date_notification = timezone.now()
            existante.save(update_fields=["message", "date_notification"])
        return existante

    if type_alerte == "rupture":
        Notification.objects.filter(
            type="stock_faible",
            lu=False,
            message__startswith=_prefixe_produit("stock_faible", nom),
        ).update(lu=True)

    return Notification.objects.create(
        type=type_alerte,
        message=message,
        utilisateur_id=None,
    )


def signaler_commande_en_attente(vente) -> Notification:
    """
    Alerte destinée aux caissiers / gérants / admins quand un serveur
    envoie une commande (statut en_attente).
    """
    client_nom = str(vente.client) if vente.client_id else "Client inconnu"
    nb_articles = vente.details.count() if hasattr(vente, "details") else 0
    message = (
        f"Nouvelle commande {vente.reference} — {client_nom} "
        f"— {vente.montant_total} FCFA"
        f"{f' ({nb_articles} article(s))' if nb_articles else ''}"
    )
    return Notification.objects.create(
        type="commande_attente",
        message=message[:255],
        utilisateur_id=None,
    )


def resoudre_notifications_commande(vente) -> int:
    """Marque comme lues les alertes liées à une commande (encaissement / annulation)."""
    return Notification.objects.filter(
        type="commande_attente",
        lu=False,
        message__contains=vente.reference,
    ).update(lu=True)


def detecter_stock_faible():
    """Scan complet (appelé au GET notifications) — filet de sécurité."""
    from apps.stocks.models import Stock

    for s in Stock.objects.select_related("produit").all():
        signaler_alerte_stock(s)


def detecter_caisses_ouvertes():
    from apps.ventes.models import Caisse

    seuil = timezone.now() - timedelta(hours=24)
    for c in Caisse.objects.filter(statut="ouverte", date_ouverture__lte=seuil):
        message = f"Caisse #{c.id_caisse} ouverte depuis plus de 24h"
        deja_signale = Notification.objects.filter(
            type="caisse_ouverte", message=message, lu=False
        ).exists()
        if not deja_signale:
            Notification.objects.create(
                type="caisse_ouverte",
                message=message,
                utilisateur_id=None,
            )


def detecter_alertes():
    detecter_stock_faible()
    detecter_caisses_ouvertes()
