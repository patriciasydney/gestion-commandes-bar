from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.utilisateurs.models import Role, Utilisateur


class Command(BaseCommand):
    help = "Crée ou met à jour l'utilisateur de développement admin/admin123."

    def add_arguments(self, parser):
        parser.add_argument(
            "--username",
            default="admin",
            help="Nom d'utilisateur (champ DRF : username)",
        )
        parser.add_argument(
            "--password",
            default="admin123",
            help="Mot de passe en clair (hashé via set_password)",
        )

    def handle(self, *args, **options):
        username = options["username"]
        password = options["password"]

        role, _ = Role.objects.get_or_create(
            nom_role="Administrateur",
            defaults={
                "description": "Accès complet",
                "actif": True,
                "date_creation": timezone.now(),
            },
        )

        utilisateur, created = Utilisateur.objects.get_or_create(
            username=username,
            defaults={
                "nom": "Admin",
                "prenom": "Test",
                "email": f"{username}@pos.test",
                "telephone": "+237690000000",
                "statut": "actif",
                "role": role,
                "date_creation": timezone.now(),
                "is_staff": True,
                "is_superuser": True,
            },
        )

        utilisateur.set_password(password)
        utilisateur.role = role
        utilisateur.statut = "actif"
        utilisateur.is_active = True
        utilisateur.save()

        action = "créé" if created else "mis à jour"
        self.stdout.write(
            self.style.SUCCESS(
                f"Utilisateur « {username} » {action}. Connexion : {username} / {password}"
            )
        )
