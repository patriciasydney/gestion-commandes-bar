from django.db import models
from django.db.models import F


class Caisse(models.Model):
    STATUT_OUVERTE = "ouverte"
    STATUT_FERMEE = "fermee"
    STATUT_CHOICES = [
        (STATUT_OUVERTE, "Ouverte"),
        (STATUT_FERMEE, "Fermée"),
    ]

    id_caisse = models.BigAutoField(primary_key=True)
    date_ouverture = models.DateTimeField(auto_now_add=True)
    date_fermeture = models.DateTimeField(null=True, blank=True)
    montant_initial = models.DecimalField(max_digits=10, decimal_places=2)
    montant_final = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default=STATUT_OUVERTE)
    utilisateur = models.ForeignKey(
        "utilisateurs.Utilisateur",
        on_delete=models.RESTRICT,
        db_column="id_utilisateur",
        related_name="caisses",
    )

    class Meta:
        managed = False
        db_table = "caisses"
        constraints = [
            models.CheckConstraint(
                condition=models.Q(montant_initial__gte=0),
<<<<<<< HEAD:ventes/models.py
                name='chk_caisses_montant_initial',
            ),
            models.CheckConstraint(
                condition=models.Q(montant_final__isnull=True) | models.Q(montant_final__gte=0),
                name='chk_caisses_montant_final',
=======
                name="chk_caisses_montant_initial",
            ),
            models.CheckConstraint(
                condition=models.Q(montant_final__isnull=True) | models.Q(montant_final__gte=0),
                name="chk_caisses_montant_final",
            ),
            models.CheckConstraint(
                condition=models.Q(date_fermeture__isnull=True)
                | models.Q(date_fermeture__gte=F("date_ouverture")),
                name="chk_caisses_dates",
            ),
            models.CheckConstraint(
                condition=models.Q(statut__in=["ouverte", "fermee"]),
                name="chk_caisses_statut",
>>>>>>> 08c1517 (Itegration d'equipe phase 1):POS_Backend/apps/ventes/models.py
            ),
        ]

    def __str__(self):
        return f"Caisse #{self.id_caisse} ({self.get_statut_display()})"


class Vente(models.Model):
    STATUT_EN_ATTENTE = "en_attente"
    STATUT_VALIDEE = "validee"
    STATUT_ANNULEE = "annulee"
    STATUT_CHOICES = [
        (STATUT_EN_ATTENTE, "En attente"),
        (STATUT_VALIDEE, "Validée"),
        (STATUT_ANNULEE, "Annulée"),
    ]

    id_vente = models.BigAutoField(primary_key=True)
    reference = models.CharField(max_length=50, unique=True)
    date_vente = models.DateTimeField(auto_now_add=True)
    montant_total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    remise = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default=STATUT_VALIDEE)
    utilisateur = models.ForeignKey(
        "utilisateurs.Utilisateur",
        on_delete=models.RESTRICT,
        db_column="id_utilisateur",
        related_name="ventes",
    )
    client = models.ForeignKey(
        "clients.Client",
        on_delete=models.SET_NULL,
        db_column="id_client",
        related_name="ventes",
        null=True,
        blank=True,
    )
    caisse = models.ForeignKey(
        Caisse,
        on_delete=models.RESTRICT,
        db_column="id_caisse",
        related_name="ventes",
    )

    class Meta:
        managed = False
        db_table = "ventes"
        constraints = [
            models.CheckConstraint(
<<<<<<< HEAD:ventes/models.py
                condition=models.Q(montant_total__gte=0), name='chk_ventes_montant_total'
            ),
            models.CheckConstraint(
                condition=models.Q(remise__gte=0), name='chk_ventes_remise'
=======
                condition=models.Q(montant_total__gte=0),
                name="chk_ventes_montant_total",
            ),
            models.CheckConstraint(
                condition=models.Q(remise__gte=0),
                name="chk_ventes_remise",
            ),
            models.CheckConstraint(
                condition=models.Q(statut__in=["en_attente", "validee", "annulee"]),
                name="chk_ventes_statut",
>>>>>>> 08c1517 (Itegration d'equipe phase 1):POS_Backend/apps/ventes/models.py
            ),
        ]

    def __str__(self):
        return self.reference


class DetailVente(models.Model):
    id_detail = models.BigAutoField(primary_key=True)
    vente = models.ForeignKey(
        Vente,
        on_delete=models.CASCADE,
        db_column="id_vente",
        related_name="details",
    )
    produit = models.ForeignKey(
        "produits.Produit",
        on_delete=models.RESTRICT,
        db_column="id_produit",
        related_name="detail_ventes",
    )
    quantite = models.IntegerField()
    prix_unitaire = models.DecimalField(max_digits=10, decimal_places=2)
    sous_total = models.GeneratedField(
        expression=models.F("quantite") * models.F("prix_unitaire"),
        output_field=models.DecimalField(max_digits=10, decimal_places=2),
        db_persist=True,
    )

    class Meta:
        managed = False
        db_table = "detail_ventes"
        constraints = [
            models.CheckConstraint(
<<<<<<< HEAD:ventes/models.py
                condition=models.Q(quantite__gt=0), name='chk_detail_ventes_quantite'
            ),
            models.CheckConstraint(
                condition=models.Q(prix_unitaire__gte=0),
                name='chk_detail_ventes_prix_unitaire',
=======
                condition=models.Q(quantite__gt=0),
                name="chk_detail_ventes_quantite",
            ),
            models.CheckConstraint(
                condition=models.Q(prix_unitaire__gte=0),
                name="chk_detail_ventes_prix_unitaire",
>>>>>>> 08c1517 (Itegration d'equipe phase 1):POS_Backend/apps/ventes/models.py
            ),
        ]

    def __str__(self):
        return f"{self.produit} x{self.quantite} (vente #{self.vente_id})"
