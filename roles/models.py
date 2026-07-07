from django.db import models


class Role(models.Model):
    id_role = models.BigAutoField(primary_key=True)
    nom_role = models.CharField(max_length=50, unique=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = False
        db_table = 'roles'

    def __str__(self):
        return self.nom_role
