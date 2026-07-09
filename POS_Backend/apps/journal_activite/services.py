"""Journal d'activité — écriture depuis les opérations métier."""


def enregistrer_journal(request, action, description=""):
    """
    Enregistre une entrée dans journal_activite (table SQL Michel).
    Ne lève pas d'exception si l'écriture échoue (journal non bloquant).
    """
    from apps.journal_activite.models import JournalActivite

    utilisateur = None
    adresse_ip = None
    if request is not None:
        if getattr(request, "user", None) and request.user.is_authenticated:
            utilisateur = request.user
        adresse_ip = request.META.get("REMOTE_ADDR")

    try:
        JournalActivite.objects.create(
            utilisateur=utilisateur,
            action=action,
            description=description or None,
            adresse_ip=adresse_ip,
        )
    except Exception:
        pass
