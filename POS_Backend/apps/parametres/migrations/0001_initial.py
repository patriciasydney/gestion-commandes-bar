from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="ParametreSysteme",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("nom_entreprise", models.CharField(default="Bar Le Relais", max_length=150)),
                ("adresse", models.CharField(blank=True, default="", max_length=255)),
                ("telephone", models.CharField(blank=True, default="", max_length=30)),
                ("email", models.EmailField(blank=True, default="", max_length=254)),
                ("rccm", models.CharField(blank=True, default="", max_length=80)),
                ("nif", models.CharField(blank=True, default="", max_length=80)),
                ("tva_active", models.BooleanField(default=True)),
                (
                    "tva_taux",
                    models.DecimalField(decimal_places=2, default=19.25, max_digits=5),
                ),
                ("taxe_boisson_active", models.BooleanField(default=False)),
                (
                    "taxe_boisson_taux",
                    models.DecimalField(decimal_places=2, default=5.0, max_digits=5),
                ),
                ("imprimantes", models.JSONField(blank=True, default=list)),
                ("sauvegarde_auto", models.BooleanField(default=True)),
                ("derniere_sauvegarde", models.DateTimeField(blank=True, null=True)),
                ("date_modification", models.DateTimeField(auto_now=True)),
            ],
            options={
                "verbose_name": "Paramètre système",
                "verbose_name_plural": "Paramètres système",
                "db_table": "parametres_systeme",
            },
        ),
    ]
