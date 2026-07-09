from drf_spectacular.utils import OpenApiResponse, extend_schema
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Notification
from .serializers import NotificationSerializer
from .services import detecter_alertes


@extend_schema(responses=NotificationSerializer(many=True))
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def liste_notifications(request):
    detecter_alertes()
    qs = Notification.objects.all().order_by("-date_notification")
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
