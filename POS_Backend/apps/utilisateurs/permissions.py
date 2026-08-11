"""
Permissions DRF basées sur roles.nom_role (alignées sur le cahier des charges §4.1).
"""
from rest_framework.permissions import SAFE_METHODS, BasePermission


class RoleNames:
    ADMINISTRATEUR = "Administrateur"
    GERANT = "Gérant"
    CAISSIER = "Caissier"
    MAGASINIER = "Magasinier"
    SERVEUR = "Serveur"
    COMPTABLE = "Comptable"


ALL_ROLES = (
    RoleNames.ADMINISTRATEUR,
    RoleNames.GERANT,
    RoleNames.CAISSIER,
    RoleNames.MAGASINIER,
    RoleNames.SERVEUR,
    RoleNames.COMPTABLE,
)


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


class RoleReadWritePermission(BasePermission):
    """Lecture et écriture avec listes de rôles distinctes."""

    read_roles = ()
    write_roles = ()
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

        allowed = self.read_roles if request.method in SAFE_METHODS else self.write_roles
        if role_name not in allowed:
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


class IsPosUser(BaseRolePermission):
    """Point de vente : prise de commande / vente."""

    allowed_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
        RoleNames.SERVEUR,
    )


class IsCaisseOperator(BaseRolePermission):
    """Ouverture / fermeture de caisse et encaissement."""

    allowed_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
    )


class IsGerantOrComptable(BaseRolePermission):
    """Dashboard et rapports financiers."""

    allowed_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.COMPTABLE,
    )


class CanManageCatalog(RoleReadWritePermission):
    read_roles = ALL_ROLES
    write_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT)


class CanReadStock(RoleReadWritePermission):
    read_roles = ALL_ROLES
    write_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.MAGASINIER,
    )


class CanManageFournisseurs(RoleReadWritePermission):
    read_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.MAGASINIER,
        RoleNames.COMPTABLE,
    )
    write_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT)


class CanManageClients(RoleReadWritePermission):
    read_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
        RoleNames.SERVEUR,
        RoleNames.COMPTABLE,
    )
    write_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
        RoleNames.SERVEUR,
    )


class CanManageAchats(RoleReadWritePermission):
    read_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.MAGASINIER,
        RoleNames.COMPTABLE,
    )
    write_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.MAGASINIER,
    )


class CanManageDepenses(RoleReadWritePermission):
    read_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.COMPTABLE,
    )
    write_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.COMPTABLE,
    )


class CanManagePaiements(RoleReadWritePermission):
    read_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
        RoleNames.COMPTABLE,
    )
    write_roles = (
        RoleNames.ADMINISTRATEUR,
        RoleNames.GERANT,
        RoleNames.CAISSIER,
    )


class CanViewJournal(BaseRolePermission):
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT)


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
