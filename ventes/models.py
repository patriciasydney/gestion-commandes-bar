from django.db import models


class Caisse(models.Model):
    """Table `caisses` — session d'ouverture/fermeture de caisse d'un caissier.

    Placée dans l'app `ventes` car indissociable du cycle de vente POS.
    À déplacer si l'architecte (Verone) préfère une app dédiée.
    """

    STATUT_OUVERTE = 'ouverte'
    STATUT_FERMEE = 'fermee'
    STATUT_CHOICES = [
        (STATUT_OUVERTE, 'Ouverte'),
        (STATUT_FERMEE, 'Fermée'),
    ]

    id_caisse = models.BigAutoField(primary_key=True)
    date_ouverture = models.DateTimeField(auto_now_add=True)
    date_fermeture = models.DateTimeField(null=True, blank=True)
    montant_initial = models.DecimalField(max_digits=10, decimal_places=2)
    montant_final = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default=STATUT_OUVERTE)
    utilisateur = models.ForeignKey(
        'utilisateurs.Utilisateur',
        on_delete=models.RESTRICT,
        db_column='id_utilisateur',
        related_name='caisses',
    )

    class Meta:
        managed = False
        db_table = 'caisses'
        constraints = [
            models.CheckConstraint(
                condition=models.Q(montant_initial__gte=0),
                name='chk_caisses_montant_initial',
            ),
            models.CheckConstraint(
                condition=models.Q(montant_final__isnull=True) | models.Q(montant_final__gte=0),
                name='chk_caisses_montant_final',
            ),
        ]

    def __str__(self):
        return f"Caisse #{self.id_caisse} ({self.get_statut_display()})"


class Vente(models.Model):
    """Table `ventes` — transaction commerciale (ticket de caisse)."""

    STATUT_EN_ATTENTE = 'en_attente'
    STATUT_VALIDEE = 'validee'
    STATUT_ANNULEE = 'annulee'
    STATUT_CHOICES = [
        (STATUT_EN_ATTENTE, 'En attente'),
        (STATUT_VALIDEE, 'Validée'),
        (STATUT_ANNULEE, 'Annulée'),
    ]

    id_vente = models.BigAutoField(primary_key=True)
    reference = models.CharField(max_length=50, unique=True)
    date_vente = models.DateTimeField(auto_now_add=True)
    montant_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    remise = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default=STATUT_VALIDEE)
    utilisateur = models.ForeignKey(
        'utilisateurs.Utilisateur',
        on_delete=models.RESTRICT,
        db_column='id_utilisateur',
        related_name='ventes',
    )
    client = models.ForeignKey(
        'clients.Client',
        on_delete=models.SET_NULL,
        db_column='id_client',
        related_name='ventes',
        null=True,
        blank=True,
    )
    caisse = models.ForeignKey(
        Caisse, on_delete=models.RESTRICT, db_column='id_caisse', related_name='ventes'
    )

    class Meta:
        managed = False
        db_table = 'ventes'
        constraints = [
            models.CheckConstraint(
                condition=models.Q(montant_total__gte=0), name='chk_ventes_montant_total'
            ),
            models.CheckConstraint(
                condition=models.Q(remise__gte=0), name='chk_ventes_remise'
            ),
        ]

    def __str__(self):
        return self.reference


class DetailVente(models.Model):
    """Table `detail_ventes` — lignes de produits composant une vente.

    `sous_total` est généré par PostgreSQL (voir note dans achats/models.py
    pour DetailAchat — même principe, Django >= 5.0 requis pour GeneratedField).
    """

    id_detail = models.BigAutoField(primary_key=True)
    vente = models.ForeignKey(
        Vente, on_delete=models.CASCADE, db_column='id_vente', related_name='details'
    )
    produit = models.ForeignKey(
        'produits.Produit',
        on_delete=models.RESTRICT,
        db_column='id_produit',
        related_name='detail_ventes',
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
        db_table = 'detail_ventes'
        constraints = [
            models.CheckConstraint(
                condition=models.Q(quantite__gt=0), name='chk_detail_ventes_quantite'
            ),
            models.CheckConstraint(
                condition=models.Q(prix_unitaire__gte=0),
                name='chk_detail_ventes_prix_unitaire',
            ),
        ]

    def __str__(self):
        return f"{self.produit} x{self.quantite} (vente #{self.vente_id})"
