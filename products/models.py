from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_length=10, decimal_places=2, max_digits=10)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name
