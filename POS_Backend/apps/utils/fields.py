from rest_framework import serializers


class MontantDecimalField(serializers.DecimalField):
    """Montant NUMERIC(10,2) — aligné sur database/schema.sql."""

    def __init__(self, **kwargs):
        kwargs.setdefault("max_digits", 10)
        kwargs.setdefault("decimal_places", 2)
        super().__init__(**kwargs)
