from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.journal_activite.services import enregistrer_journal
from apps.utilisateurs.permissions import IsAdministrateur

from . import backup as backup_service
from .models import ParametreSysteme
from .serializers import ParametreSystemeSerializer, SauvegardeMetaSerializer


@api_view(["GET", "PUT", "PATCH"])
@permission_classes([IsAuthenticated])
def parametres_detail(request):
    """
    GET : lecture des paramètres (tout utilisateur authentifié).
    PUT/PATCH : modification (administrateur uniquement).
    """
    obj = ParametreSysteme.get_solo()

    if request.method == "GET":
        return Response(ParametreSystemeSerializer(obj).data)

    if not IsAdministrateur().has_permission(request, None):
        return Response(
            {"detail": "Seuls les administrateurs peuvent modifier les paramètres."},
            status=status.HTTP_403_FORBIDDEN,
        )

    serializer = ParametreSystemeSerializer(obj, data=request.data, partial=True)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    enregistrer_journal(request, "parametres.modifier", "Mise à jour des paramètres système")
    return Response(serializer.data)


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdministrateur])
def liste_sauvegardes(request):
    serializer = SauvegardeMetaSerializer(backup_service.list_backups(), many=True)
    return Response(serializer.data)


@api_view(["POST"])
@permission_classes([IsAuthenticated, IsAdministrateur])
def creer_sauvegarde(request):
    meta = backup_service.create_backup()
    params = ParametreSysteme.get_solo()
    params.derniere_sauvegarde = timezone.now()
    params.save(update_fields=["derniere_sauvegarde", "date_modification"])
    enregistrer_journal(
        request,
        "parametres.sauvegarde",
        f"Sauvegarde créée : {meta['nom']}",
    )
    return Response(SauvegardeMetaSerializer(meta).data, status=status.HTTP_201_CREATED)


@api_view(["POST"])
@permission_classes([IsAuthenticated, IsAdministrateur])
def restaurer_sauvegarde(request):
    nom = (request.data or {}).get("nom")
    if not nom:
        return Response(
            {"detail": "Le champ « nom » de la sauvegarde est requis."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    try:
        result = backup_service.restore_backup(nom)
    except FileNotFoundError as exc:
        return Response({"detail": str(exc)}, status=status.HTTP_404_NOT_FOUND)
    except Exception as exc:  # noqa: BLE001 — surface l'erreur SQL au client admin
        return Response(
            {"detail": f"Échec de la restauration : {exc}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    enregistrer_journal(
        request,
        "parametres.restaurer",
        f"Restauration depuis {nom}",
    )
    return Response(result)
