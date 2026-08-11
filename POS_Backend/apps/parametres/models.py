from django.db import models


class ParametreSysteme(models.Model):
    """
    Singleton des paramètres applicatifs (cahier des charges §10.9).
    Une seule ligne attendue — id forcé à 1.
    """

    nom_entreprise = models.CharField(max_length=150, default="Bar Le Relais")
    adresse = models.CharField(max_length=255, blank=True, default="")
    telephone = models.CharField(max_length=30, blank=True, default="")
    email = models.EmailField(blank=True, default="")
    rccm = models.CharField(max_length=80, blank=True, default="")
    nif = models.CharField(max_length=80, blank=True, default="")

    tva_active = models.BooleanField(default=True)
    tva_taux = models.DecimalField(max_digits=5, decimal_places=2, default=19.25)
    taxe_boisson_active = models.BooleanField(default=False)
    taxe_boisson_taux = models.DecimalField(max_digits=5, decimal_places=2, default=5.0)

    imprimantes = models.JSONField(default=list, blank=True)
    sauvegarde_auto = models.BooleanField(default=True)
    derniere_sauvegarde = models.DateTimeField(null=True, blank=True)

    date_modification = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "parametres_systeme"
        verbose_name = "Paramètre système"
        verbose_name_plural = "Paramètres système"

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        pass

    @classmethod
    def get_solo(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj

    def __str__(self):
        return f"Paramètres — {self.nom_entreprise}"
