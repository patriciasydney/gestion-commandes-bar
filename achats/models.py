from django.db import models


class Achat(models.Model):
    """Table `achats` — opération d'approvisionnement auprès d'un fournisseur."""

    STATUT_EN_ATTENTE = 'en_attente'
    STATUT_VALIDE = 'valide'
    STATUT_ANNULE = 'annule'
    STATUT_CHOICES = [
        (STATUT_EN_ATTENTE, 'En attente'),
        (STATUT_VALIDE, 'Validé'),
        (STATUT_ANNULE, 'Annulé'),
    ]

    id_achat = models.BigAutoField(primary_key=True)
    date_achat = models.DateTimeField(auto_now_add=True)
    montant_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default=STATUT_VALIDE)
    fournisseur = models.ForeignKey(
        'fournisseurs.Fournisseur',
        on_delete=models.RESTRICT,
        db_column='id_fournisseur',
        related_name='achats',
    )
    utilisateur = models.ForeignKey(
        'utilisateurs.Utilisateur',
        on_delete=models.RESTRICT,
        db_column='id_utilisateur',
        related_name='achats',
    )

    class Meta:
        managed = False
        db_table = 'achats'
        constraints = [
            models.CheckConstraint(
                check=models.Q(montant_total__gte=0),
                name='chk_achats_montant_total',
            ),
        ]

    def __str__(self):
        return f"Achat #{self.id_achat} — {self.fournisseur}"


class DetailAchat(models.Model):
    """Table `detail_achats` — lignes de produits composant un achat.

    IMPORTANT : `sous_total` est une colonne PostgreSQL générée
    (GENERATED ALWAYS AS (quantite * prix_unitaire) STORED). On la déclare en
    GeneratedField pour que Django l'exclue automatiquement des INSERT/UPDATE
    et se contente de la lire depuis la BDD.

    ⚠️ Nécessite Django >= 5.0. Si le projet est en Django < 5.0, remplacer ce
    champ par une simple @property Python (non persistée) et lire la vraie
    valeur stockée via une requête .raw() ou .annotate() si besoin exact.
    """

    id_detail = models.BigAutoField(primary_key=True)
    achat = models.ForeignKey(
        Achat, on_delete=models.CASCADE, db_column='id_achat', related_name='details'
    )
    produit = models.ForeignKey(
        'produits.Produit',
        on_delete=models.RESTRICT,
        db_column='id_produit',
        related_name='detail_achats',
    )
    quantite = models.IntegerField()
    prix_unitaire = models.DecimalField(max_digits=10, decimal_places=2)
    sous_total = models.GeneratedField(
        expression=models.F('quantite') * models.F('prix_unitaire'),
        output_field=models.DecimalField(max_digits=10, decimal_places=2),
        db_persist=True,
    )

    class Meta:
        managed = False
        db_table = 'detail_achats'
        constraints = [
            models.CheckConstraint(
                check=models.Q(quantite__gt=0), name='chk_detail_achats_quantite'
            ),
            models.CheckConstraint(
                check=models.Q(prix_unitaire__gte=0),
                name='chk_detail_achats_prix_unitaire',
            ),
        ]

    def __str__(self):
        return f"{self.produit} x{self.quantite} (achat #{self.achat_id})"
