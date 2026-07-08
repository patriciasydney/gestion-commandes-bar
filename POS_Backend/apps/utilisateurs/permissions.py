"""
Permissions DRF basées sur roles.nom_role (alignées sur database/seed.sql).
"""
from rest_framework.permissions import BasePermission


class RoleNames:
    ADMINISTRATEUR = "Administrateur"
    GERANT = "Gérant"
    CAISSIER = "Caissier"
    MAGASINIER = "Magasinier"
    SERVEUR = "Serveur"
    COMPTABLE = "Comptable"


def get_user_role_name(user):
    role = getattr(user, "role", None)
    if role is None:
        return None
    return getattr(role, "nom_role", None)


class BaseRolePermission(BasePermission):
    allowed_roles = ()
    message = "Vous n'avez pas les permissions nécessaires pour effectuer cette action."

    def has_permission(self, request, view):
        user = getattr(request, "user", None)
        if user is None or not user.is_authenticated:
            self.message = "Authentification requise pour accéder à cette ressource."
            return False

        role_name = get_user_role_name(user)
        if role_name is None:
            self.message = "Aucun rôle n'est associé à votre compte. Contactez un administrateur."
            return False

        if role_name not in self.allowed_roles:
            self.message = (
                f"Accès refusé : votre rôle ({role_name}) n'est pas autorisé "
                f"pour cette opération."
            )
            return False

        return True


class IsAdministrateur(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR,)


class IsGerantOrAdmin(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT)


class IsCaissier(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT, RoleNames.CAISSIER)


class IsCaissierStrict(BaseRolePermission):
    allowed_roles = (RoleNames.CAISSIER,)


class IsMagasinier(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.MAGASINIER)


class IsMagasinierStrict(BaseRolePermission):
    allowed_roles = (RoleNames.MAGASINIER,)


class IsServeur(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT, RoleNames.SERVEUR)


class IsComptable(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.COMPTABLE)


class IsGerantOrComptable(BaseRolePermission):
    """Dashboard et rapports : gérant, comptable ou administrateur."""
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT, RoleNames.COMPTABLE)


class IsOwnerOrAdmin(BasePermission):
    message = "Vous ne pouvez accéder qu'à vos propres ressources."

    def has_permission(self, request, view):
        user = getattr(request, "user", None)
        return bool(user and user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        user = request.user
        role_name = get_user_role_name(user)
        if role_name == RoleNames.ADMINISTRATEUR:
            return True
        if obj == user:
            return True
        owner = getattr(obj, "utilisateur", None)
        return owner == user
