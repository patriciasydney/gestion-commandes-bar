# Intégré depuis la branche Sindiely (Laetitia) — module Rapports §5.13
from django.db.models import Count, Sum
from django.db.models.functions import TruncDate
from django.utils.dateparse import parse_date
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.depenses.models import Depense
from apps.utilisateurs.permissions import IsGerantOrComptable
from apps.ventes.models import DetailVente, Vente


def _parse_periode(request):
    debut = parse_date(request.query_params.get("date_debut", ""))
    fin = parse_date(request.query_params.get("date_fin", ""))
    return debut, fin


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsGerantOrComptable])
def rapport_ventes(request):
    debut, fin = _parse_periode(request)
    qs = Vente.objects.filter(statut="validee")
    if debut:
        qs = qs.filter(date_vente__date__gte=debut)
    if fin:
        qs = qs.filter(date_vente__date__lte=fin)

    total = qs.aggregate(total=Sum("montant_total"))["total"] or 0
    nombre = qs.aggregate(count=Count("id_vente"))["count"] or 0

    par_jour = (
        qs.annotate(jour=TruncDate("date_vente"))
        .values("jour")
        .annotate(total_jour=Sum("montant_total"), tickets=Count("id_vente"))
        .order_by("jour")
    )

    return Response(
        {
            "periode": {
                "debut": str(debut) if debut else None,
                "fin": str(fin) if fin else None,
            },
            "total_ventes": total,
            "nombre_ventes": nombre,
            "detail_par_jour": list(par_jour),
        }
    )


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsGerantOrComptable])
def rapport_produits(request):
    debut, fin = _parse_periode(request)
    qs = DetailVente.objects.filter(vente__statut="validee")
    if debut:
        qs = qs.filter(vente__date_vente__date__gte=debut)
    if fin:
        qs = qs.filter(vente__date_vente__date__lte=fin)

    top_produits = (
        qs.values("produit__nom")
        .annotate(
            quantite_totale=Sum("quantite"),
            chiffre_affaires=Sum("sous_total"),
        )
        .order_by("-quantite_totale")[:10]
    )

    return Response(
        {
            "periode": {
                "debut": str(debut) if debut else None,
                "fin": str(fin) if fin else None,
            },
            "top_produits": list(top_produits),
        }
    )


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsGerantOrComptable])
def rapport_depenses(request):
    debut, fin = _parse_periode(request)
    qs = Depense.objects.all()
    if debut:
        qs = qs.filter(date_depense__date__gte=debut)
    if fin:
        qs = qs.filter(date_depense__date__lte=fin)

    total = qs.aggregate(total=Sum("montant"))["total"] or 0
    par_categorie = (
        qs.values("categorie")
        .annotate(total_categorie=Sum("montant"))
        .order_by("-total_categorie")
    )

    return Response(
        {
            "periode": {
                "debut": str(debut) if debut else None,
                "fin": str(fin) if fin else None,
            },
            "total_depenses": total,
            "par_categorie": list(par_categorie),
        }
    )
