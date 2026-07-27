"""
Initialise ou réinitialise les comptes de démonstration avec des mots de passe Django valides.

Usage (depuis POS_Backend/) :
    python manage.py ensure_dev_users

Après un seed SQL, les hashes factices ($2b$12$FAKEHASH...) ne permettent pas
la connexion JWT. Cette commande applique de vrais mots de passe via set_password().
"""
from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.utilisateurs.models import Role, Utilisateur

DEV_USERS = (
    {
        "username": "admin",
        "password": "admin123",
        "role": "Administrateur",
        "nom": "Fotso",
        "prenom": "Michel",
        "email": "michel.fotso@possarl.cm",
        "telephone": "+237690111111",
    },
    {
        "username": "gerant1",
        "password": "gerant123",
        "role": "Gérant",
        "nom": "Nguema",
        "prenom": "Sylvie",
        "email": "sylvie.nguema@possarl.cm",
        "telephone": "+237690222222",
    },
    {
        "username": "caissier1",
        "password": "caissier123",
        "role": "Caissier",
        "nom": "Biya",
        "prenom": "Paul",
        "email": "paul.biya.k@possarl.cm",
        "telephone": "+237690333333",
    },
    {
        "username": "magasinier1",
        "password": "magasin123",
        "role": "Magasinier",
        "nom": "Ekanga",
        "prenom": "Brice",
        "email": "brice.ekanga@possarl.cm",
        "telephone": "+237690444444",
    },
    {
        "username": "serveur1",
        "password": "serveur123",
        "role": "Serveur",
        "nom": "Manga",
        "prenom": "Claire",
        "email": "claire.manga@possarl.cm",
        "telephone": "+237690555555",
    },
    {
        "username": "comptable1",
        "password": "comptable123",
        "role": "Comptable",
        "nom": "Owona",
        "prenom": "Denise",
        "email": "denise.owona@possarl.cm",
        "telephone": "+237690666666",
    },
)


class Command(BaseCommand):
    help = "Crée ou met à jour les comptes de démo avec des mots de passe JWT valides."

    def add_arguments(self, parser):
        parser.add_argument(
            "--admin-only",
            action="store_true",
            help="Ne traiter que le compte administrateur.",
        )

    def handle(self, *args, **options):
        users_spec = DEV_USERS
        if options["admin_only"]:
            users_spec = (DEV_USERS[0],)

        for spec in users_spec:
            role = Role.objects.filter(nom_role=spec["role"]).first()
            if role is None:
                self.stderr.write(
                    self.style.ERROR(
                        f"Rôle « {spec['role']} » introuvable — exécutez d'abord database/seed.sql"
                    )
                )
                continue

            utilisateur = Utilisateur.objects.filter(username=spec["username"]).first()
            created = utilisateur is None

            if created:
                utilisateur = Utilisateur(
                    username=spec["username"],
                    nom=spec["nom"],
                    prenom=spec["prenom"],
                    email=spec["email"],
                    telephone=spec["telephone"],
                    statut=Utilisateur.Statut.ACTIF,
                    date_creation=timezone.now(),
                    role=role,
                    is_active=True,
                    is_staff=spec["role"] == "Administrateur",
                )
            else:
                utilisateur.role = role
                utilisateur.statut = Utilisateur.Statut.ACTIF
                utilisateur.is_active = True
                if spec["role"] == "Administrateur":
                    utilisateur.is_staff = True

            utilisateur.set_password(spec["password"])
            utilisateur.save()

            action = "Créé" if created else "Mot de passe mis à jour"
            self.stdout.write(
                self.style.SUCCESS(
                    f"{action} : {spec['username']} ({spec['role']}) — mot de passe : {spec['password']}"
                )
            )

        self.stdout.write(
            self.style.WARNING(
                "\nComptes prêts pour la démo. Connectez-vous avec admin / admin123 "
                "puis créez les autres utilisateurs depuis Paramètres → Utilisateurs."
            )
        )
