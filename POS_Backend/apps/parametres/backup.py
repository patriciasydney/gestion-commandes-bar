"""Export / restauration JSON des données métier (admin uniquement)."""
from __future__ import annotations

import json
from datetime import datetime
from decimal import Decimal
from pathlib import Path

from django.conf import settings
from django.db import connection
from django.utils import timezone

# Tables métier + paramètres — ordre de restauration (dépendances FK)
BACKUP_TABLES = (
    "roles",
    "utilisateurs",
    "categories",
    "fournisseurs",
    "clients",
    "produits",
    "stocks",
    "caisses",
    "achats",
    "detail_achats",
    "ventes",
    "detail_ventes",
    "paiements",
    "mouvements_stock",
    "depenses",
    "journal_activite",
    "notifications",
    "parametres_systeme",
)


def _backup_dir() -> Path:
    path = Path(settings.BASE_DIR) / "backups"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _json_default(value):
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, memoryview):
        return bytes(value).hex()
    raise TypeError(f"Type non sérialisable : {type(value)!r}")


def list_backups() -> list[dict]:
    items = []
    for file in sorted(_backup_dir().glob("sauvegarde_*.json"), reverse=True):
        stat = file.stat()
        items.append(
            {
                "nom": file.name,
                "taille": stat.st_size,
                "date_creation": datetime.fromtimestamp(
                    stat.st_mtime, tz=timezone.get_current_timezone()
                ),
            }
        )
    return items


def create_backup() -> dict:
    payload = {
        "version": 1,
        "created_at": timezone.now().isoformat(),
        "tables": {},
    }
    with connection.cursor() as cursor:
        for table in BACKUP_TABLES:
            cursor.execute(
                "SELECT EXISTS (SELECT 1 FROM information_schema.tables "
                "WHERE table_schema = 'public' AND table_name = %s)",
                [table],
            )
            if not cursor.fetchone()[0]:
                continue
            cursor.execute(f'SELECT * FROM "{table}"')
            columns = [col[0] for col in cursor.description]
            rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
            payload["tables"][table] = {"columns": columns, "rows": rows}

    stamp = timezone.now().strftime("%Y%m%d_%H%M%S")
    filename = f"sauvegarde_{stamp}.json"
    path = _backup_dir() / filename
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, default=_json_default),
        encoding="utf-8",
    )
    stat = path.stat()
    return {
        "nom": filename,
        "taille": stat.st_size,
        "date_creation": datetime.fromtimestamp(
            stat.st_mtime, tz=timezone.get_current_timezone()
        ),
        "chemin": str(path),
    }


def restore_backup(filename: str) -> dict:
    path = _backup_dir() / Path(filename).name
    if not path.exists() or not path.is_file():
        raise FileNotFoundError(f"Sauvegarde introuvable : {filename}")

    payload = json.loads(path.read_text(encoding="utf-8"))
    tables = payload.get("tables") or {}

    with connection.cursor() as cursor:
        cursor.execute("SET session_replication_role = replica")
        try:
            for table in reversed(BACKUP_TABLES):
                if table not in tables:
                    continue
                cursor.execute(f'TRUNCATE TABLE "{table}" CASCADE')

            for table in BACKUP_TABLES:
                data = tables.get(table)
                if not data:
                    continue
                columns = data["columns"]
                rows = data["rows"]
                if not rows:
                    continue
                col_list = ", ".join(f'"{c}"' for c in columns)
                placeholders = ", ".join(["%s"] * len(columns))
                sql = f'INSERT INTO "{table}" ({col_list}) VALUES ({placeholders})'
                for row in rows:
                    values = [row.get(c) for c in columns]
                    cursor.execute(sql, values)
        finally:
            cursor.execute("SET session_replication_role = DEFAULT")

    return {"nom": path.name, "tables_restaurees": list(tables.keys())}
