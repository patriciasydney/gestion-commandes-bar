"""
Modèles mappés sur roles / utilisateurs (database/schema.sql).
managed = False : le schéma SQL reste la source de vérité.
"""
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


class UtilisateurManager(BaseUserManager):
    def get_by_natural_key(self, username):
        return self.get(**{self.model.USERNAME_FIELD: username})

    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError("Le nom d'utilisateur est obligatoire.")
        extra_fields.setdefault("date_creation", timezone.now())
        if extra_fields.get("role") is None:
            extra_fields["role"] = Role.objects.get(nom_role="Administrateur")
        user = self.model(username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("statut", "actif")
        return self.create_user(username, password, **extra_fields)


class Role(models.Model):
    id_role = models.BigAutoField(primary_key=True)
    nom_role = models.CharField(max_length=50, unique=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "roles"
        verbose_name = "Rôle"
        verbose_name_plural = "Rôles"

    def __str__(self):
        return self.nom_role


class Utilisateur(AbstractBaseUser, PermissionsMixin):
    class Statut(models.TextChoices):
        ACTIF = "actif", "Actif"
        INACTIF = "inactif", "Inactif"
        SUSPENDU = "suspendu", "Suspendu"

    id = models.BigAutoField(primary_key=True, db_column="id_utilisateur")
    username = models.CharField(max_length=50, unique=True, db_column="nom_utilisateur")
    password = models.CharField(max_length=255, db_column="mot_de_passe")

    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    telephone = models.CharField(max_length=20, blank=True, null=True, unique=True)
    email = models.EmailField(max_length=150, unique=True)
    statut = models.CharField(
        max_length=20,
        choices=Statut.choices,
        default=Statut.ACTIF,
    )
    date_creation = models.DateTimeField()
    photo = models.CharField(max_length=255, blank=True, null=True)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    role = models.ForeignKey(
        Role,
        on_delete=models.RESTRICT,
        db_column="id_role",
        related_name="utilisateurs",
    )

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["email", "nom", "prenom"]

    objects = UtilisateurManager()

    class Meta:
        managed = False
        db_table = "utilisateurs"
        verbose_name = "Utilisateur"
        verbose_name_plural = "Utilisateurs"
        constraints = [
            models.CheckConstraint(
                condition=models.Q(statut__in=["actif", "inactif", "suspendu"]),
                name="chk_utilisateurs_statut",
            ),
        ]

    def __str__(self):
        return f"{self.nom} {self.prenom} ({self.username})"

    @property
    def est_actif(self):
        return self.statut == self.Statut.ACTIF
