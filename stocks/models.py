from django.db import models


class Stock(models.Model):
    """Table `stocks` — relation 1-1 avec produits."""

    id_stock = models.BigAutoField(primary_key=True)
    produit = models.OneToOneField(
        'produits.Produit',
        on_delete=models.CASCADE,
        db_column='id_produit',
        related_name='stock',
    )
    quantite_disponible = models.IntegerField(default=0)
    seuil_alerte = models.IntegerField(default=0)
    date_maj = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'stocks'
        constraints = [
            models.CheckConstraint(
                check=models.Q(quantite_disponible__gte=0),
                name='chk_stocks_quantite',
            ),
            models.CheckConstraint(
                check=models.Q(seuil_alerte__gte=0),
                name='chk_stocks_seuil',
            ),
        ]

    def __str__(self):
        return f"Stock produit #{self.produit_id} : {self.quantite_disponible}"

    @property
    def en_alerte(self):
        """True si le stock est descendu au niveau (ou en dessous) du seuil d'alerte."""
        return self.quantite_disponible <= self.seuil_alerte


class MouvementStock(models.Model):
    """Table `mouvements_stock` — historique de toutes les entrées/sorties."""

    TYPE_ENTREE = 'entree'
    TYPE_SORTIE = 'sortie'
    TYPE_AJUSTEMENT = 'ajustement'
    TYPE_VENTE = 'vente'
    TYPE_ACHAT = 'achat'
    TYPE_CHOICES = [
        (TYPE_ENTREE, 'Entrée'),
        (TYPE_SORTIE, 'Sortie'),
        (TYPE_AJUSTEMENT, 'Ajustement'),
        (TYPE_VENTE, 'Vente'),
        (TYPE_ACHAT, 'Achat'),
    ]

    id_mouvement = models.BigAutoField(primary_key=True)
    produit = models.ForeignKey(
        'produits.Produit',
        on_delete=models.RESTRICT,
        db_column='id_produit',
        related_name='mouvements_stock',
    )
    type_mouvement = models.CharField(max_length=20, choices=TYPE_CHOICES)
    quantite = models.IntegerField()
    date_mouvement = models.DateTimeField(auto_now_add=True)
    utilisateur = models.ForeignKey(
        'utilisateurs.Utilisateur',
        on_delete=models.RESTRICT,
        db_column='id_utilisateur',
        related_name='mouvements_stock',
    )
    reference_operation = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mouvements_stock'
        constraints = [
            models.CheckConstraint(
                check=~models.Q(quantite=0),
                name='chk_mouvements_quantite',
            ),
        ]

    def __str__(self):
        return f"{self.get_type_mouvement_display()} — produit #{self.produit_id} ({self.quantite:+d})"
