from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Notification
from .serializers import NotificationSerializer
from .services import detecter_alertes


@api_view(['GET'])
def liste_notifications(request):
    detecter_alertes()  # rafraîchit les alertes avant de lister
    qs = Notification.objects.all().order_by('-date_notification')
    lu_param = request.query_params.get('lu')
    if lu_param is not None:
        qs = qs.filter(lu=(lu_param.lower() == 'true'))
    return Response(NotificationSerializer(qs, many=True).data)


@api_view(['PATCH'])
def marquer_lue(request, pk):
    try:
        notif = Notification.objects.get(pk=pk)
    except Notification.DoesNotExist:
        return Response({'error': 'Notification introuvable'}, status=404)
    notif.lu = True
    notif.save()
    return Response(NotificationSerializer(notif).data)
