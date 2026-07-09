"""
Tests d'intégration — flux vente + stock + paiement (Phase 2).
Nécessite PostgreSQL avec schema.sql + seed.sql appliqués.
"""
import unittest
from decimal import Decimal

from django.db import connection
from django.test import TestCase
from rest_framework.test import APIClient

from apps.produits.models import Produit
from apps.stocks.models import Stock
from apps.utilisateurs.models import Utilisateur
from apps.ventes.models import Caisse, Vente


def _postgres_disponible():
    try:
        connection.ensure_connection()
        return connection.vendor == "postgresql"
    except Exception:
        return False


def _utilisateur_existe(username):
    try:
        return Utilisateur.objects.filter(username=username).exists()
    except Exception:
        return False


@unittest.skipUnless(_postgres_disponible(), "PostgreSQL requis pour les tests d'intégration")
@unittest.skipUnless(_utilisateur_existe("caissier1"), "seed.sql requis (utilisateur caissier1)")
class FluxVenteIntegrationTest(TestCase):
    """Parcours : ouverture caisse → vente → paiement → validation stock."""

    def setUp(self):
        self.client = APIClient()
        self.caissier = Utilisateur.objects.get(username="caissier1")
        self.client.force_authenticate(user=self.caissier)
        self.produit = Produit.objects.filter(actif=True).first()
        self.assertIsNotNone(self.produit, "Aucun produit actif en base (seed.sql ?)")
        self.stock_initial = Stock.objects.get(produit=self.produit).quantite_disponible

    def test_flux_vente_paiement_stock(self):
        # 1. Ouvrir une caisse
        rep_caisse = self.client.post(
            "/api/caisses/",
            {"montant_initial": "10000.00"},
            format="json",
        )
        self.assertEqual(rep_caisse.status_code, 201, rep_caisse.content)
        id_caisse = rep_caisse.data["id_caisse"]

        # 2. Créer une vente (utilisateur injecté depuis request.user)
        reference = f"TEST-{Vente.objects.count() + 1}"
        rep_vente = self.client.post(
            "/api/ventes/",
            {
                "reference": reference,
                "remise": "0.00",
                "caisse": id_caisse,
                "details": [
                    {
                        "produit": self.produit.id_produit,
                        "quantite": 1,
                    }
                ],
            },
            format="json",
        )
        self.assertEqual(rep_vente.status_code, 201, rep_vente.content)
        id_vente = rep_vente.data["id_vente"]
        montant_total = Decimal(rep_vente.data["montant_total"])

        # 3. Stock décrémenté
        self.stock_initial -= 1
        stock_apres = Stock.objects.get(produit=self.produit).quantite_disponible
        self.assertEqual(stock_apres, self.stock_initial)

        # 4. Encaisser le paiement
        rep_paiement = self.client.post(
            "/api/paiements/",
            {
                "vente": id_vente,
                "mode_paiement": "especes",
                "montant": str(montant_total),
            },
            format="json",
        )
        self.assertEqual(rep_paiement.status_code, 201, rep_paiement.content)

        # 5. Vente validée après paiement complet
        vente = Vente.objects.get(pk=id_vente)
        self.assertEqual(vente.statut, Vente.STATUT_VALIDEE)

        # 6. Fermer la caisse
        rep_fermer = self.client.post(
            f"/api/caisses/{id_caisse}/fermer/",
            {"montant_final": str(montant_total + Decimal("10000"))},
            format="json",
        )
        self.assertEqual(rep_fermer.status_code, 200, rep_fermer.content)
        caisse = Caisse.objects.get(pk=id_caisse)
        self.assertEqual(caisse.statut, Caisse.STATUT_FERMEE)


@unittest.skipUnless(_postgres_disponible(), "PostgreSQL requis")
class PermissionsRBACTest(TestCase):
    """Un caissier ne peut pas créer un achat (réservé magasinier/gérant)."""

    def setUp(self):
        self.client = APIClient()
        if not _utilisateur_existe("caissier1"):
            self.skipTest("seed.sql requis")
        self.caissier = Utilisateur.objects.get(username="caissier1")
        self.client.force_authenticate(user=self.caissier)

    def test_caissier_refuse_sur_achats(self):
        rep = self.client.get("/api/achats/")
        self.assertEqual(rep.status_code, 403)
