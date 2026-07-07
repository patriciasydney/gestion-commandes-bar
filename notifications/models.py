from django.db import models


class Notification(models.Model):
    TYPE_CHOICES = [
        ('stock_faible', 'Stock faible'),
        ('rupture', 'Rupture de stock'),
        ('caisse_ouverte', 'Caisse non clôturée'),
    ]
    type = models.CharField(max_length=30, choices=TYPE_CHOICES)
    message = models.CharField(max_length=255)
    date_notification = models.DateTimeField(auto_now_add=True)
    lu = models.BooleanField(default=False)
    utilisateur_id = models.BigIntegerField(null=True, blank=True)

    class Meta:
        db_table = 'notifications'

    def __str__(self):
        return f"[{self.type}] {self.message}"
