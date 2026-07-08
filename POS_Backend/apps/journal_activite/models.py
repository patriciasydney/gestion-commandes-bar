from django.db import models


class JournalActivite(models.Model):
    id_journal = models.BigAutoField(primary_key=True)
    utilisateur = models.ForeignKey(
        "utilisateurs.Utilisateur",
        on_delete=models.SET_NULL,
        db_column="id_utilisateur",
        related_name="journal_activites",
        null=True,
        blank=True,
    )
    action = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    date_action = models.DateTimeField(auto_now_add=True)
    adresse_ip = models.CharField(max_length=45, blank=True, null=True)

    class Meta:
        managed = False
        db_table = "journal_activite"
        verbose_name = "Entrée journal"
        verbose_name_plural = "Journal d'activité"
        ordering = ["-date_action"]

    def __str__(self):
        return f"{self.action} ({self.date_action})"
