from django.db.models import Q
from drf_spectacular.utils import OpenApiResponse, extend_schema
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.utilisateurs.permissions import RoleNames, get_user_role_name

from .models import Notification
from .serializers import NotificationSerializer
from .services import detecter_alertes

# Alertes commandes serveur : visibles uniquement par les opérateurs caisse.
_ROLES_COMMANDES = {
    RoleNames.ADMINISTRATEUR,
    RoleNames.GERANT,
    RoleNames.CAISSIER,
}


@extend_schema(responses=NotificationSerializer(many=True))
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def liste_notifications(request):
    detecter_alertes()
    qs = Notification.objects.all().order_by("-date_notification")
    role = get_user_role_name(request.user)
    if role not in _ROLES_COMMANDES:
        qs = qs.exclude(type="commande_attente")
    else:
        # Les alertes globales (utilisateur_id NULL) + éventuelles ciblées.
        qs = qs.filter(Q(utilisateur_id__isnull=True) | Q(utilisateur_id=request.user.id))

    lu_param = request.query_params.get("lu")
    if lu_param is not None:
        qs = qs.filter(lu=(lu_param.lower() == "true"))
    return Response(NotificationSerializer(qs, many=True).data)


@extend_schema(
    request=None,
    responses={
        200: NotificationSerializer,
        404: OpenApiResponse(description="Notification introuvable"),
    },
)
@api_view(["PATCH"])
@permission_classes([IsAuthenticated])
def marquer_lue(request, pk):
    try:
        notif = Notification.objects.get(pk=pk)
    except Notification.DoesNotExist:
        return Response({"error": "Notification introuvable"}, status=404)
    notif.lu = True
    notif.save()
    return Response(NotificationSerializer(notif).data)
