"""Tests unitaires des permissions RBAC (sans base de données)."""
from unittest.mock import Mock

from django.test import SimpleTestCase
from rest_framework.test import APIRequestFactory

from apps.utilisateurs.permissions import (
    CanManageAchats,
    CanManageCatalog,
    CanManageDepenses,
    IsCaisseOperator,
    IsGerantOrComptable,
    IsPosUser,
    RoleNames,
)


def _request(method, role_name):
    user = Mock(is_authenticated=True)
    user.role = Mock(nom_role=role_name)
    factory = APIRequestFactory()
    return factory.generic(method, "/", data={}), user


class RolePermissionsTest(SimpleTestCase):
    def test_dashboard_refuse_caissier(self):
        request, user = _request("GET", RoleNames.CAISSIER)
        request.user = user
        perm = IsGerantOrComptable()
        self.assertFalse(perm.has_permission(request, None))

    def test_dashboard_autorise_comptable(self):
        request, user = _request("GET", RoleNames.COMPTABLE)
        request.user = user
        perm = IsGerantOrComptable()
        self.assertTrue(perm.has_permission(request, None))

    def test_pos_autorise_serveur(self):
        request, user = _request("POST", RoleNames.SERVEUR)
        request.user = user
        perm = IsPosUser()
        self.assertTrue(perm.has_permission(request, None))

    def test_caisse_refuse_serveur(self):
        request, user = _request("POST", RoleNames.SERVEUR)
        request.user = user
        perm = IsCaisseOperator()
        self.assertFalse(perm.has_permission(request, None))

    def test_catalogue_lecture_magasinier(self):
        request, user = _request("GET", RoleNames.MAGASINIER)
        request.user = user
        perm = CanManageCatalog()
        self.assertTrue(perm.has_permission(request, None))

    def test_catalogue_ecriture_refuse_caissier(self):
        request, user = _request("POST", RoleNames.CAISSIER)
        request.user = user
        perm = CanManageCatalog()
        self.assertFalse(perm.has_permission(request, None))

    def test_achats_ecriture_magasinier(self):
        request, user = _request("POST", RoleNames.MAGASINIER)
        request.user = user
        perm = CanManageAchats()
        self.assertTrue(perm.has_permission(request, None))

    def test_depenses_comptable(self):
        request, user = _request("POST", RoleNames.COMPTABLE)
        request.user = user
        perm = CanManageDepenses()
        self.assertTrue(perm.has_permission(request, None))

    def test_depenses_refuse_serveur(self):
        request, user = _request("GET", RoleNames.SERVEUR)
        request.user = user
        perm = CanManageDepenses()
        self.assertFalse(perm.has_permission(request, None))
