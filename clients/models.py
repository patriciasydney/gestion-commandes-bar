from django.db import models


class Client(models.Model):
    id_client = models.BigAutoField(primary_key=True)
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100, blank=True, null=True)
    telephone = models.CharField(max_length=20, unique=True, blank=True, null=True)
    email = models.EmailField(max_length=150, blank=True, null=True)
    adresse = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = False
        db_table = 'clients'

    def __str__(self):
        return f"{self.prenom or ''} {self.nom}".strip()
