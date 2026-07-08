# État Django pour AUTH_USER_MODEL — tables gérées par database/schema.sql
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("auth", "0012_alter_user_first_name_max_length"),
    ]

    operations = [
        migrations.CreateModel(
            name="Role",
            fields=[
                ("id_role", models.BigAutoField(primary_key=True, serialize=False)),
                ("nom_role", models.CharField(max_length=50, unique=True)),
                ("description", models.CharField(blank=True, max_length=255, null=True)),
                ("actif", models.BooleanField(default=True)),
                ("date_creation", models.DateTimeField()),
            ],
            options={
                "verbose_name": "Rôle",
                "verbose_name_plural": "Rôles",
                "db_table": "roles",
                "managed": False,
            },
        ),
        migrations.CreateModel(
            name="Utilisateur",
            fields=[
                (
                    "last_login",
                    models.DateTimeField(blank=True, null=True, verbose_name="last login"),
                ),
                (
                    "is_superuser",
                    models.BooleanField(
                        default=False,
                        help_text=(
                            "Designates that this user has all permissions "
                            "without explicitly assigning them."
                        ),
                        verbose_name="superuser status",
                    ),
                ),
                (
                    "id",
                    models.BigAutoField(
                        db_column="id_utilisateur",
                        primary_key=True,
                        serialize=False,
                    ),
                ),
                (
                    "username",
                    models.CharField(
                        db_column="nom_utilisateur",
                        max_length=50,
                        unique=True,
                    ),
                ),
                (
                    "password",
                    models.CharField(db_column="mot_de_passe", max_length=255),
                ),
                ("nom", models.CharField(max_length=100)),
                ("prenom", models.CharField(max_length=100)),
                (
                    "telephone",
                    models.CharField(blank=True, max_length=20, null=True, unique=True),
                ),
                ("email", models.EmailField(max_length=150, unique=True)),
                (
                    "statut",
                    models.CharField(
                        choices=[
                            ("actif", "Actif"),
                            ("inactif", "Inactif"),
                            ("suspendu", "Suspendu"),
                        ],
                        default="actif",
                        max_length=20,
                    ),
                ),
                ("date_creation", models.DateTimeField()),
                ("photo", models.CharField(blank=True, max_length=255, null=True)),
                ("is_staff", models.BooleanField(default=False)),
                ("is_active", models.BooleanField(default=True)),
                (
                    "role",
                    models.ForeignKey(
                        db_column="id_role",
                        on_delete=django.db.models.deletion.RESTRICT,
                        related_name="utilisateurs",
                        to="utilisateurs.role",
                    ),
                ),
            ],
            options={
                "verbose_name": "Utilisateur",
                "verbose_name_plural": "Utilisateurs",
                "db_table": "utilisateurs",
                "managed": False,
            },
        ),
    ]
