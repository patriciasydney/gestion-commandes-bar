from django.db import models


class Produit(models.Model):
    id_produit = models.BigAutoField(primary_key=True)
    code = models.CharField(max_length=30, unique=True)
    code_barres = models.CharField(max_length=50, unique=True, blank=True, null=True)
    nom = models.CharField(max_length=150)
    description = models.TextField(blank=True, null=True)
    prix_achat = models.DecimalField(max_digits=10, decimal_places=2)
    prix_vente = models.DecimalField(max_digits=10, decimal_places=2)
    contenance = models.CharField(max_length=30, blank=True, null=True)
    stock_minimum = models.IntegerField(default=0)
    image = models.CharField(max_length=255, blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField(auto_now_add=True)
    categorie = models.ForeignKey('categories.Categorie', on_delete=models.RESTRICT, db_column='id_categorie', related_name='produits')
    fournisseur = models.ForeignKey('fournisseurs.Fournisseur', on_delete=models.SET_NULL, db_column='id_fournisseur', related_name='produits', null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'produits'

    def __str__(self):
        return self.nom
