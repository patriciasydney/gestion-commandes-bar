"""
Mixins partagés — permissions par action et injection utilisateur.
"""
from rest_framework.permissions import IsAuthenticated

from apps.utilisateurs.permissions import IsAdministrateur


class RoleActionPermissionMixin:
    """
    Associe chaque action DRF à une liste de classes de permission.
    Exemple :
        role_permissions = {
            "create": [IsAdministrateur],
            "default": [IsAuthenticated],
        }
    """

    role_permissions: dict = {}

    def get_permissions(self):
        classes = self.role_permissions.get(
            self.action,
            self.role_permissions.get("default", [IsAuthenticated]),
        )
        return [permission() for permission in classes]
