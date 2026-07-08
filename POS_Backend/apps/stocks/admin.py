from django.contrib import admin

from .models import MouvementStock, Stock

admin.site.register(Stock)
admin.site.register(MouvementStock)
