"""Tests unitaires RBAC — sans accès base de données."""
from types import SimpleNamespace

from django.test import SimpleTestCase

from apps.utilisateurs.permissions import (
    IsAdministrateur,
    IsAchatOperator,
    IsCaissier,
    IsGerantOrAdmin,
    RoleNames,
)


def _fake_request(nom_role):
    role = SimpleNamespace(nom_role=nom_role)
    user = SimpleNamespace(role=role, is_authenticated=True)
    return SimpleNamespace(user=user)


class PermissionsUnitTest(SimpleTestCase):
    def test_administrateur_autorise(self):
        self.assertTrue(
            IsAdministrateur().has_permission(_fake_request(RoleNames.ADMINISTRATEUR), None)
        )

    def test_caissier_refuse_admin(self):
        self.assertFalse(
            IsAdministrateur().has_permission(_fake_request(RoleNames.CAISSIER), None)
        )

    def test_caissier_autorise_ventes(self):
        self.assertTrue(
            IsCaissier().has_permission(_fake_request(RoleNames.CAISSIER), None)
        )

    def test_caissier_refuse_achats(self):
        self.assertFalse(
            IsAchatOperator().has_permission(_fake_request(RoleNames.CAISSIER), None)
        )

    def test_gerant_autorise_catalogue(self):
        self.assertTrue(
            IsGerantOrAdmin().has_permission(_fake_request(RoleNames.GERANT), None)
        )
