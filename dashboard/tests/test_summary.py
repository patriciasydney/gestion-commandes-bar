from django.test import TestCase
from rest_framework.test import APIClient


class DashboardSummaryTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_endpoint_repond_200(self):
        response = self.client.get('/api/dashboard/summary/')
        self.assertEqual(response.status_code, 200)

    def test_contient_les_champs_attendus(self):
        response = self.client.get('/api/dashboard/summary/')
        data = response.json()
        for champ in ['chiffre_affaires_jour', 'nombre_tickets_jour', 'depenses_jour', 'produits_stock_faible']:
            self.assertIn(champ, data)
