#!/usr/bin/env python
"""
Point d'entrée à la racine du monorepo — délègue à POS_Backend.
"""
import os
import sys

POS_BACKEND = os.path.join(os.path.dirname(os.path.abspath(__file__)), "POS_Backend")
sys.path.insert(0, POS_BACKEND)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.development")

<<<<<<< HEAD
def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pos_backend.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
=======
from django.core.management import execute_from_command_line  # noqa: E402

if __name__ == "__main__":
>>>>>>> 08c1517 (Itegration d'equipe phase 1)
    execute_from_command_line(sys.argv)
