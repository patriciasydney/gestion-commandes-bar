#!/usr/bin/env python
"""
Point d'entrée à la racine du monorepo — délègue à POS_Backend.
"""
import os
import sys

POS_BACKEND = os.path.join(os.path.dirname(os.path.abspath(__file__)), "POS_Backend")
sys.path.insert(0, POS_BACKEND)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.development")

from django.core.management import execute_from_command_line  # noqa: E402

if __name__ == "__main__":
    execute_from_command_line(sys.argv)
