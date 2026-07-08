from django.test import TestCase
from rest_framework.test import APIClient
from notifications.models import Notification


class NotificationsTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_liste_repond_200(self):
        response = self.client.get('/api/notifications/')
        self.assertEqual(response.status_code, 200)

    def test_marquer_lue(self):
        notif = Notification.objects.create(type='stock_faible', message='Test stock faible')
        response = self.client.patch(f'/api/notifications/{notif.id}/lue/')
        self.assertEqual(response.status_code, 200)
        notif.refresh_from_db()
        self.assertTrue(notif.lu)
