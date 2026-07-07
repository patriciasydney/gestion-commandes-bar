from rest_framework import viewsets
from .models import Categorie, Fournisseur, Produit, Client
from .serializers import CategorieSerializer, FournisseurSerializer, ProduitSerializer, ClientSerializer

class CategorieViewSet(viewsets.ModelViewSet):
    queryset = Categorie.objects.all().order_by('nom')
    serializer_class = CategorieSerializer

class FournisseurViewSet(viewsets.ModelViewSet):
    queryset = Fournisseur.objects.all().order_by('raison_sociale')
    serializer_class = FournisseurSerializer

class ProduitViewSet(viewsets.ModelViewSet):
    queryset = Produit.objects.all().order_by('-date_creation')
    serializer_class = ProduitSerializer

class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all().order_by('nom')
    serializer_class = ClientSerializer
