from django.db import models


class Depense(models.Model):
    id_depense = models.BigAutoField(primary_key=True)
    libelle = models.CharField(max_length=150)
    categorie = models.CharField(max_length=50)
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    date_depense = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(
        "utilisateurs.Utilisateur",
        on_delete=models.RESTRICT,
        db_column="id_utilisateur",
        related_name="depenses",
    )

    class Meta:
        managed = False
        db_table = "depenses"
        constraints = [
            models.CheckConstraint(
<<<<<<< HEAD:depenses/models.py
                condition=models.Q(montant__gte=0), name='chk_depenses_montant'
=======
                condition=models.Q(montant__gte=0),
                name="chk_depenses_montant",
>>>>>>> 08c1517 (Itegration d'equipe phase 1):POS_Backend/apps/depenses/models.py
            ),
        ]

    def __str__(self):
        return f"{self.libelle} — {self.montant} ({self.categorie})"
