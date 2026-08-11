"""Crée / met à jour les utilisateurs de développement pour tous les rôles métier."""
from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.utilisateurs.models import Role, Utilisateur

# Aligné sur database/seed.sql + README_DEMARRAGE.md
DEV_USERS = (
    {
        "username": "admin",
        "password": "admin123",
        "nom_role": "Administrateur",
        "nom": "Fotso",
        "prenom": "Michel",
        "email": "michel.fotso@possarl.cm",
        "telephone": "+237690111111",
        "is_staff": True,
        "is_superuser": True,
    },
    {
        "username": "gerant1",
        "password": "gerant123",
        "nom_role": "Gérant",
        "nom": "Nguema",
        "prenom": "Sylvie",
        "email": "sylvie.nguema@possarl.cm",
        "telephone": "+237690222222",
    },
    {
        "username": "caissier1",
        "password": "caissier123",
        "nom_role": "Caissier",
        "nom": "Biya",
        "prenom": "Paul",
        "email": "paul.biya.k@possarl.cm",
        "telephone": "+237690333333",
    },
    {
        "username": "magasinier1",
        "password": "magasin123",
        "nom_role": "Magasinier",
        "nom": "Owona",
        "prenom": "Marie",
        "email": "marie.owona@possarl.cm",
        "telephone": "+237690444444",
    },
    {
        "username": "serveur1",
        "password": "serveur123",
        "nom_role": "Serveur",
        "nom": "Essomba",
        "prenom": "Jean",
        "email": "jean.essomba@possarl.cm",
        "telephone": "+237690555555",
    },
    {
        "username": "comptable1",
        "password": "compta123",
        "nom_role": "Comptable",
        "nom": "Kamga",
        "prenom": "Claire",
        "email": "claire.kamga@possarl.cm",
        "telephone": "+237690666666",
    },
)

ROLE_DEFS = (
    ("Administrateur", "Accès complet à la configuration et à la supervision du système"),
    ("Gérant", "Supervision commerciale, produits, fournisseurs et stocks"),
    ("Caissier", "Enregistrement des ventes, paiements et gestion de caisse"),
    ("Magasinier", "Gestion physique des stocks, inventaires et approvisionnements"),
    ("Serveur", "Prise de commandes clients et transmission au caissier"),
    ("Comptable", "Consultation des rapports financiers, dépenses et statistiques"),
)


class Command(BaseCommand):
    help = "Assure les 6 rôles métier et les comptes de test (mots de passe hashés)."

    def handle(self, *args, **options):
        for nom_role, description in ROLE_DEFS:
            role, created = Role.objects.get_or_create(
                nom_role=nom_role,
                defaults={
                    "description": description,
                    "actif": True,
                    "date_creation": timezone.now(),
                },
            )
            if not created and not role.actif:
                role.actif = True
                role.save(update_fields=["actif"])
            action = "créé" if created else "présent"
            self.stdout.write(f"Rôle « {nom_role} » {action}.")

        for spec in DEV_USERS:
            role = Role.objects.get(nom_role=spec["nom_role"])
            utilisateur, created = Utilisateur.objects.get_or_create(
                username=spec["username"],
                defaults={
                    "nom": spec["nom"],
                    "prenom": spec["prenom"],
                    "email": spec["email"],
                    "telephone": spec["telephone"],
                    "statut": "actif",
                    "role": role,
                    "date_creation": timezone.now(),
                    "is_staff": spec.get("is_staff", False),
                    "is_superuser": spec.get("is_superuser", False),
                },
            )
            utilisateur.set_password(spec["password"])
            utilisateur.role = role
            utilisateur.statut = "actif"
            utilisateur.is_active = True
            utilisateur.is_staff = spec.get("is_staff", utilisateur.is_staff)
            utilisateur.is_superuser = spec.get("is_superuser", utilisateur.is_superuser)
            utilisateur.nom = spec["nom"]
            utilisateur.prenom = spec["prenom"]
            utilisateur.email = spec["email"]
            utilisateur.telephone = spec["telephone"]
            utilisateur.save()
            verb = "créé" if created else "mis à jour"
            self.stdout.write(
                self.style.SUCCESS(
                    f"Utilisateur « {spec['username']} » {verb} "
                    f"({spec['nom_role']}) — {spec['username']} / {spec['password']}"
                )
            )
