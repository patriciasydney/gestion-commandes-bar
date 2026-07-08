from django.db import models


class Utilisateur(models.Model):
    STATUT_CHOICES = [('actif', 'Actif'), ('inactif', 'Inactif'), ('suspendu', 'Suspendu')]

    id_utilisateur = models.BigAutoField(primary_key=True)
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    telephone = models.CharField(max_length=20, unique=True, blank=True, null=True)
    email = models.EmailField(max_length=150, unique=True)
    nom_utilisateur = models.CharField(max_length=50, unique=True)
    mot_de_passe = models.CharField(max_length=255)
    photo = models.CharField(max_length=255, blank=True, null=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='actif')
    date_creation = models.DateTimeField(auto_now_add=True)
    role = models.ForeignKey('roles.Role', on_delete=models.RESTRICT, db_column='id_role', related_name='utilisateurs')

    class Meta:
        managed = False
        db_table = 'utilisateurs'

    def __str__(self):
        return f"{self.prenom} {self.nom}"
