from django.test import TestCase
from rest_framework.test import APIClient


class DashboardSummaryTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_endpoint_repond_401_sans_auth(self):
        response = self.client.get("/api/dashboard/summary/")
        self.assertEqual(response.status_code, 401)
