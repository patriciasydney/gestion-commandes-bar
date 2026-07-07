"""
Application : users
Fichier : permissions.py

Classes de permissions DRF basées sur le champ `role` du modèle Utilisateur
(voir users/models.py). Chaque classe vérifie :
1. que l'utilisateur est authentifié (sinon accès refusé, jamais d'exception
   levée par erreur sur un utilisateur anonyme) ;
2. que l'utilisateur possède un rôle assigné ;
3. que ce rôle correspond (ou appartient) aux rôles autorisés pour l'action.

Rôles définis dans le cahier des charges (chapitre 4.1) :
    ADMINISTRATEUR, GERANT, CAISSIER, MAGASINIER, SERVEUR, COMPTABLE
"""

from rest_framework.permissions import BasePermission


# ------------------------------------------------------------------
# Constantes des noms de rôles (à faire correspondre avec le champ
# `nom_role` de la table Role en base de données).
# ------------------------------------------------------------------
class RoleNames:
    ADMINISTRATEUR = "ADMINISTRATEUR"
    GERANT = "GERANT"
    CAISSIER = "CAISSIER"
    MAGASINIER = "MAGASINIER"
    SERVEUR = "SERVEUR"
    COMPTABLE = "COMPTABLE"


def get_user_role_name(user):
    """
    Fonction utilitaire qui retourne le nom du rôle de l'utilisateur,
    ou None si l'utilisateur n'a pas de rôle assigné (évite les
    AttributeError si `user.role` est None).
    """
    role = getattr(user, "role", None)
    if role is None:
        return None
    return getattr(role, "nom_role", None)


class BaseRolePermission(BasePermission):
    """
    Classe de base factorisant la logique commune :
    - refuse l'accès si l'utilisateur n'est pas authentifié ;
    - refuse l'accès si l'utilisateur n'a pas de rôle ;
    - autorise l'accès si le rôle de l'utilisateur figure dans `allowed_roles`.

    Les sous-classes définissent simplement l'attribut `allowed_roles`.
    """

    allowed_roles = ()
    message = "Vous n'avez pas les permissions nécessaires pour effectuer cette action."

    def has_permission(self, request, view):
        user = getattr(request, "user", None)

        # Utilisateur non authentifié (AnonymousUser) ou absent de la requête
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


# ------------------------------------------------------------------
# Permissions spécifiques par rôle / module
# ------------------------------------------------------------------

class IsAdministrateur(BaseRolePermission):
    """
    Accès total au système : gestion des utilisateurs, des rôles,
    des paramètres, supervision générale.
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR,)


class IsGerantOrAdmin(BaseRolePermission):
    """
    Gestion des produits, catégories, fournisseurs, achats,
    consultation des stocks et des rapports.
    Le gérant et l'administrateur ont ce niveau d'accès.
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT)


class IsCaissier(BaseRolePermission):
    """
    Limité aux opérations du module POS : création de vente,
    encaissement des paiements, ouverture/clôture de caisse,
    impression des reçus.

    L'administrateur et le gérant conservent l'accès (supervision),
    en plus du caissier lui-même.
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT, RoleNames.CAISSIER)


class IsCaissierStrict(BaseRolePermission):
    """
    Variante stricte : uniquement le caissier (aucune supervision
    automatique par le gérant/administrateur). À utiliser si une
    action doit être réservée exclusivement au caissier connecté
    (ex. clôture de sa propre caisse).
    """
    allowed_roles = (RoleNames.CAISSIER,)


class IsMagasinier(BaseRolePermission):
    """
    Limité strict aux entrées/sorties de stock et aux inventaires.
    Seuls le magasinier et l'administrateur y ont accès
    (le gérant peut consulter mais pas modifier — voir IsGerantOrAdmin
    pour la consultation si besoin).
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.MAGASINIER)


class IsMagasinierStrict(BaseRolePermission):
    """
    Variante stricte réservée uniquement au magasinier, sans
    supervision automatique de l'administrateur.
    """
    allowed_roles = (RoleNames.MAGASINIER,)


class IsServeur(BaseRolePermission):
    """
    Limité à la création et à la consultation des commandes clients
    avant transmission au caissier.
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.GERANT, RoleNames.SERVEUR)


class IsComptable(BaseRolePermission):
    """
    Accès aux rapports financiers, dépenses, ventes et statistiques
    nécessaires au suivi comptable.
    """
    allowed_roles = (RoleNames.ADMINISTRATEUR, RoleNames.COMPTABLE)


class IsOwnerOrAdmin(BasePermission):
    """
    Permission au niveau objet (has_object_permission) : autorise l'accès
    si l'utilisateur est l'administrateur ou s'il est le propriétaire
    de la ressource (ex. un caissier consultant sa propre caisse,
    un utilisateur modifiant son propre profil).

    Nécessite que l'objet cible possède un attribut `utilisateur`
    (FK vers Utilisateur) ou soit directement une instance Utilisateur.
    """

    message = "Vous ne pouvez accéder qu'à vos propres ressources."

    def has_permission(self, request, view):
        user = getattr(request, "user", None)
        return bool(user and user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        user = request.user

        role_name = get_user_role_name(user)
        if role_name == RoleNames.ADMINISTRATEUR:
            return True

        # Cas où l'objet est directement l'utilisateur (ex. profil)
        if obj == user:
            return True

        # Cas où l'objet référence un utilisateur via une FK `utilisateur`
        owner = getattr(obj, "utilisateur", None)
        return owner == user
