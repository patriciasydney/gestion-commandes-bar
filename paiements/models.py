from django.db import models


class Paiement(models.Model):
    """Table `paiements` — règlement associé à une vente.

    Une vente peut avoir plusieurs paiements (paiement mixte : une partie en
    espèces + une partie Mobile Money par exemple) → chaque paiement est une
    ligne distincte, pas une somme unique.
    """

    MODE_ESPECES = 'especes'
    MODE_MOBILE_MONEY = 'mobile_money'
    MODE_CARTE_BANCAIRE = 'carte_bancaire'
    MODE_MIXTE = 'mixte'
    MODE_CHOICES = [
        (MODE_ESPECES, 'Espèces'),
        (MODE_MOBILE_MONEY, 'Mobile Money'),
        (MODE_CARTE_BANCAIRE, 'Carte bancaire'),
        (MODE_MIXTE, 'Mixte'),
    ]

    id_paiement = models.BigAutoField(primary_key=True)
    vente = models.ForeignKey(
        'ventes.Vente',
        on_delete=models.CASCADE,
        db_column='id_vente',
        related_name='paiements',
    )
    mode_paiement = models.CharField(max_length=20, choices=MODE_CHOICES)
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    reference_transaction = models.CharField(max_length=100, blank=True, null=True)
    date_paiement = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = False
        db_table = 'paiements'
        constraints = [
            models.CheckConstraint(
                check=models.Q(montant__gte=0), name='chk_paiements_montant'
            ),
        ]

    def __str__(self):
        return f"{self.get_mode_paiement_display()} — {self.montant} (vente #{self.vente_id})"
