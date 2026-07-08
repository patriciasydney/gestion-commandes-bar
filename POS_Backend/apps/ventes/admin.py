from django.contrib import admin

from .models import Caisse, DetailVente, Vente

admin.site.register(Caisse)
admin.site.register(Vente)
admin.site.register(DetailVente)
