# Généré pour le module Notifications (Laetitia / branche Sindiely)
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Notification",
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
                (
                    "type",
                    models.CharField(
                        choices=[
                            ("stock_faible", "Stock faible"),
                            ("rupture", "Rupture de stock"),
                            ("caisse_ouverte", "Caisse non clôturée"),
                        ],
                        max_length=30,
                    ),
                ),
                ("message", models.CharField(max_length=255)),
                ("date_notification", models.DateTimeField(auto_now_add=True)),
                ("lu", models.BooleanField(default=False)),
                ("utilisateur_id", models.BigIntegerField(blank=True, null=True)),
            ],
            options={
                "db_table": "notifications",
                "ordering": ["-date_notification"],
            },
        ),
    ]
