from django.db import models


class Fournisseur(models.Model):
    id_fournisseur = models.BigAutoField(primary_key=True)
    raison_sociale = models.CharField(max_length=150)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    adresse = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(max_length=150, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "fournisseurs"
        verbose_name = "Fournisseur"
        verbose_name_plural = "Fournisseurs"

    def __str__(self):
        return self.raison_sociale
