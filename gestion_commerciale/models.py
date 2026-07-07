from django.db import models

class Categorie(models.Model):
    nom = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.nom

class Fournisseur(models.Model):
    raison_sociale = models.CharField(max_length=150)
    telephone = models.CharField(max_length=20)
    adresse = models.TextField(blank=True, null=True)
    email = models.EmailField(blank=True, null=True)

    def __str__(self):
        return self.raison_sociale

class Produit(models.Model):
    code = models.CharField(max_length=50, unique=True)
    code_barres = models.CharField(max_length=100, unique=True, blank=True, null=True)
    nom = models.CharField(max_length=150)
    description = models.TextField(blank=True, null=True)
    prix_achat = models.DecimalField(max_digits=10, decimal_places=2)
    prix_vente = models.DecimalField(max_digits=10, decimal_places=2)
    stock_minimum = models.IntegerField(default=5)
    image = models.ImageField(upload_to='produits/', blank=True, null=True)
    
    # Clés étrangères (Relations)
    categorie = models.ForeignKey(Categorie, on_delete=models.PROTECT, related_name='produits')
    fournisseur = models.ForeignKey(Fournisseur, on_delete=models.SET_NULL, null=True, related_name='produits')
    
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nom

class Client(models.Model):
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100, blank=True, null=True)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.nom} {self.prenom or ''}".strip()
