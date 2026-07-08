from django.db import models


class Categorie(models.Model):
    id_categorie = models.BigAutoField(primary_key=True)
    nom = models.CharField(max_length=100, unique=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)

    class Meta:
        managed = False
        db_table = 'categories'

    def __str__(self):
        return self.nom
