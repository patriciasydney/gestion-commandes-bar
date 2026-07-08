from django.db import models


class Client(models.Model):
    id_client = models.BigAutoField(primary_key=True)
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100, blank=True, null=True)
    telephone = models.CharField(max_length=20, blank=True, null=True, unique=True)
    email = models.EmailField(max_length=150, blank=True, null=True)
    adresse = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "clients"
        verbose_name = "Client"
        verbose_name_plural = "Clients"

    def __str__(self):
        return f"{self.nom} {self.prenom or ''}".strip()
